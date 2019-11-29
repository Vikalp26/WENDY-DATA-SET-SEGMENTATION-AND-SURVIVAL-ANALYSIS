/*
Authors: Vikalp Upadhyay, Ankit Raina, Yajaria 
Date of Creation: November 17, 2019
Description: Wendy's Customer Segmentation
*/;

/* clustering code begins */

* Reading the data set;
DATA wen_data;
	SET 'C:\Users\aar180001\Desktop\wen.sas7bdat';
RUN;

* Printing first 10 observations of the data;
PROC PRINT DATA=wen_data(obs = 10);
RUN;

* Descriptive Statistics;
PROC MEANS DATA=wen_data;
RUN;

* Printing first 10 observations of the data;
PROC PRINT DATA=wen_data(OBS = 10);
RUN;

DATA wen_data;
    SET wen_data;
    RENAME DYPT_PCT_LU = LU;
    RENAME DYPT_PCT_AF = AF;
	RENAME DYPT_PCT_DINNER = DI;
	RENAME DYPT_PCT_NITE = NIT;
RUN;

* Printing first 10 observations of the data;
PROC PRINT DATA=wen_data(OBS = 10);
RUN;

/* Perfoming Cluster Analysis */
ODS GRAPHICS ON;
PROC CLUSTER DATA=wen_data CCC PRINT=15 OUTTREE=Tree METHOD=ward;
	VAR SIZE_HH HH_INCOME REDEEM_WELCOME LU AF DI NIT BAKERY_PCT 
		CHICKN_PCT HAMBRGR_PCT FRSTY_PCT OTHER_PCT AVG_PRICE;
RUN;
ODS GRAPHICS OFF;

/* From the Cubic Clustering Criterion, we see that the optimal no. of clusters is 5; 
/* Retaining 5 clusters */
PROC TREE DATA=Tree NCL=5 OUT=out;
	COPY SIZE_HH--AVG_PRICE;
RUN;

/* To create a Scatterplot */
PROC CANDISC DATA=out OUT = can;
	CLASS cluster;
	VAR SIZE_HH HH_INCOME REDEEM_WELCOME LU AF DI NIT BAKERY_PCT 
		CHICKN_PCT HAMBRGR_PCT FRSTY_PCT OTHER_PCT AVG_PRICE;
RUN;

PROC SGPLOT DATA = can;
	TITLE "Customer Segmentation";
	SCATTER y = can2 x = can1 / group = cluster;
RUN;


/*Frequency of Clusters*/
PROC FREQ DATA=out;
RUN;
	
* Creating Decision Tree;
ods graphics on;

proc hpsplit data=out maxdepth=5;
   class cluster;
   model cluster = REDEEM_WELCOME LU AF DI NIT BAKERY_PCT 
		CHICKN_PCT HAMBRGR_PCT FRSTY_PCT OTHER_PCT AVG_PRICE;
   prune costcomplexity;
   partition fraction(validate=0.3 seed=123);
   code file='wendy_segmentation_tree.sas';
   rules file='rules.txt';
run;

/* clustering code ends */

/* survival analysis code starting */
DATA wen_data;
	SET 'E:\Users\vxu180002\Downloads\project\wen';
RUN;

proc print data = wen_data (obs = 10); run;

data  wen_data;
set wen_data;
IF TENURE < 0 then TENURE = 0;
run;

data wen_data;
set wen_data;
weeks = TENURE*4;
run;

proc means nolabels data=wen_data;
   output out=Meansproc;
run;

DATA  wen_data;
  SET wen_data;
  IF SIZE_HH <= 1 THEN single = 1;
  else  single  = 0;
  IF SIZE_HH <= 2 and SIZE_HH > 1 THEN twopeople = 1; 
  else twopeople=  0;
  IF SIZE_HH <= 3 and SIZE_HH > 2 THEN threepeople = 1; 
	else threepeople = 0;
	IF SIZE_HH <= 4 and SIZE_HH > 3 THEN fourpeople = 1; 
	else fourpeople  = 0;
  IF SIZE_HH <= 5 and SIZE_HH > 4 THEN fivepeople = 1; 
  else fivepeople  = 0;
  IF SIZE_HH <= 6 and SIZE_HH > 5 THEN sixpeople = 1; 
  else sixpeople = 0;
RUN;
proc print data = wen_data (obs = 10); run;

data wen_data;
set wen_data;
if single = 1 or twopeople = 1 then smallfam = 1; else smallfam=0;
run;

/* survival analysis with lifetest */
proc lifetest data=wen_data plots=(s) graphics outsurv=a;
time weeks;
strata smallfam;
symbol1 v=none color=black line=1;
symbol2 v=none color=black line=2;
run;

proc phreg data=wen_data;
model weeks = single twopeople threepeople fourpeople fivepeople sixpeople _SMS _DM HH_INCOME _avg_TB_TRANS NUM_EARN_REDEEM TOT_REWARDS_EARN
			NUM_EARN_REDEEM REDEEM_WELCOME DYPT_PCT_BR DYPT_PCT_LU DYPT_PCT_AF DYPT_PCT_DINNER
			DYPT_PCT_EVEN DYPT_PCT_NITE BAKERY_PCT CHICKN_PCT HAMBRGR_PCT MealDeal_PCT FRSTY_PCT
			SALAD_PCT KID_PCT OTHER_PCT;
run;

/* survival analysis code ending  */

