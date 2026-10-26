CREATE DATABASE CRIME_INDIA;
USE CRIME_INDIA;
CREATE TABLE ipc_crimes(State_UT VARCHAR (50),
 DISTRICT VARCHAR(50), 
YEAR INT,
MURDER INT,
ATTEMPT_TO_MURDER INT,
CULPABLE_HOMICIDE_NOT_AMOUNTING_TO_MURDER INT,
RAPE INT,
CUSTODIAL_RAPE INT,
OTHER_RAPE INT,
KIDNAPPING_ABDUCTION INT,
KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS INT,
KIDNAPPING_AND_ABDUCTION_OF_OTHERS INT,
DACOITY INT,
PREPARATION_AND_ASSEMBLY_FOR_DACOITY INT,
ROBBERY INT,
BURGLARY INT,
THEFT INT,
AUTO_THEFT INT,
OTHER_THEFT INT,
RIOTS INT,
CRIMINAL_BREACH_OF_TRUST INT,
CHEATING INT,
COUNTERFIETING INT,
ARSON INT,
HURT_GREVIOUS_HURT INT,
DOWRY_DEATHS INT,
ASSAULT_ON_WOMEN_WITH_INTENT_TO_OUTRAGE_HER_MODESTY INT,
INSULT_TO_MODESTY_OF_WOMEN INT,
CRUELTY_BY_HUSBAND_OR_HIS_RELATIVES INT,
IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES INT,
CAUSING_DEATH_BY_NEGLIGENCE INT,
OTHER_IPC_CRIMES INT,
TOTAL_IPC_CRIMES INT
);
select * from ipc_crimes;


/*--------------------DATA CLEANING---------------------*/
/* to modify table first we hav to create another table(just copy of raw data)*/
create table first_crimes like ipc_crimes;/*copied table created*/
insert into  first_crimes select * from ipc_crimes; /* values inserted*/


/* --------------------REMOVE DUPLICATES------------------*/
SELECT COUNT(*) FROM ipc_crimes; /* TO COUNT NUMBER OF RECORDS*/
WITH DUP AS (
SELECT *, row_number() OVER(partition by State_UT, DISTRICT, YEAR) AS ROW_NUM FROM ipc_crimes 
)
SELECT * FROM DUP WHERE ROW_NUM>1; /* at there i found only one duplicate record of jammu*/
select * from ipc_crimes WHERE State_UT='JAMMU & KASHMIR' AND YEAR=2010 AND DISTRICT='RAILWAYS';/*DUPLICATE RECORD*/

/*at this time i can not delete duplicate row because it contain some data so we aggregate this data and make it unique*/ 
create table unique_crimes as select State_UT ,
DISTRICT , 
YEAR ,
sum(MURDER ) MURDER,
sum(ATTEMPT_TO_MURDER )ATTEMPT_TO_MURDER,
sum(CULPABLE_HOMICIDE_NOT_AMOUNTING_TO_MURDER) CULPABLE_HOMICIDE_NOT_AMOUNTING_TO_MURDER,
sum(RAPE ) RAPE,
sum(CUSTODIAL_RAPE) CUSTODIAL_RAPE,
sum(OTHER_RAPE )OTHER_RAPE,
sum(KIDNAPPING_ABDUCTION ) KIDNAPPING_ABDUCTION,
sum(KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS ) KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS,
sum(KIDNAPPING_AND_ABDUCTION_OF_OTHERS) KIDNAPPING_AND_ABDUCTION_OF_OTHERS,
sum(DACOITY )DACOITY,
sum(PREPARATION_AND_ASSEMBLY_FOR_DACOITY) PREPARATION_AND_ASSEMBLY_FOR_DACOITY,
sum(ROBBERY ) ROBBERY,
sum(BURGLARY) BURGLARY,
sum(THEFT ) THEFT,
sum(AUTO_THEFT ) AUTO_THEFT,
sum(OTHER_THEFT) OTHER_THEFT,
sum(RIOTS ) RIOTS,
sum(CRIMINAL_BREACH_OF_TRUST) CRIMINAL_BREACH_OF_TRUST,
sum(CHEATING ) CHEATING,
sum(COUNTERFIETING) COUNTERFIETING,
sum(ARSON ) ARSON,
sum(HURT_GREVIOUS_HURT) HURT_GREVIOUS_HURT,
sum(DOWRY_DEATHS ) DOWRY_DEATHS,
sum(ASSAULT_ON_WOMEN_WITH_INTENT_TO_OUTRAGE_HER_MODESTY) ASSAULT_ON_WOMEN_WITH_INTENT_TO_OUTRAGE_HER_MODESTY,
sum(INSULT_TO_MODESTY_OF_WOMEN ) INSULT_TO_MODESTY_OF_WOMEN,
sum(CRUELTY_BY_HUSBAND_OR_HIS_RELATIVES ) CRUELTY_BY_HUSBAND_OR_HIS_RELATIVES,
sum(IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES,
sum(CAUSING_DEATH_BY_NEGLIGENCE) CAUSING_DEATH_BY_NEGLIGENCE,
sum(OTHER_IPC_CRIMES) OTHER_IPC_CRIMES,
sum(TOTAL_IPC_CRIMES ) TOTAL_IPC_CRIMES from first_crimes 
group by state_ut, district, year ; /*table created without having duplicate values and withou loosing any data*/
/* 1 row is removed of duplicate so count is reduced by 1*/


/*-------------------------------STANDARDIZATION OF DATA-------------------------------*/
select distinct(state_ut) from unique_crimes order by state_ut;/* to chek whitespaces or spelling */
select distinct(district) from unique_crimes order by district;/* to chek whitespaces or spelling */
select * from unique_crimes where state_ut like '%island%';
select * from unique_crimes where state_ut like '%havel%';
create table standard_crimes like unique_crimes;/* create a new table to modify records.*/
insert standard_crimes select * from unique_crimes;/* insert data into new table*/

/* fix spelling eroors--- andaman nicobar and d&n haveli both have two different-different spellings.  */
update standard_crimes set state_ut ='A&N ISLANDS' where  state_ut like '%island%';
select distinct(state_ut) from standard_crimes order by state_ut; 
update standard_crimes set state_ut ='D&N HAVELI' where  state_ut like '%haveli%';
select distinct(state_ut) from standard_crimes order by state_ut; 
select * from standard_crimes where district='A and N ISLANDS';

/* fix variable districts of A&N ISLANDS--- A&N have different district for different years so i have combine all in one district having name Andaman & Nicobar. */
create table standard2_crimes like standard_crimes;/* create a new table to modify records.*/
insert standard2_crimes select * from standard_crimes;/* insert data into new table*/
update standard2_crimes set district ='Andaman & Nicobar' where  state_ut = 'A&N ISLANDS' and (district='total' or district='zz total');/* this make single district of andaman*/
delete from standard2_crimes where state_ut = 'A&N ISLANDS'  and district not in ('Andaman & Nicobar');/* this will delete district which are other than Andaman and nicobar*/
select * from standard2_crimes where state_ut = 'A&N ISLANDS';
select * from standard2_crimes ;

/* Standard format */

SELECT DISTINCT state_ut
FROM cleaned_crimes
ORDER BY state_ut;


SELECT DISTINCT state_ut, UPPER(state_ut) AS upper_name
FROM cleaned_crimes;


create table demo like cleaned_crimes;/* create a new table to modify records.*/
insert demo select * from cleaned_crimes;/* insert data into new table*/

select * from demo;

select state_ut, upper(state_ut) from demo where year = 2013;
update demo set state_ut = upper(state_ut) where year = 2013;

select state_ut from cleaned_crimes where year = 2013;
select state_ut from demo where year = 2013;



/*-------------------------NULL & BLANK VALUES--------------------------*/
select * from standard2_crimes where state_ut is null or state_ut ='';
select * from standard2_crimes where district is null or state_ut ='';
select * from standard2_crimes where year is null or state_ut ='';
select * from standard2_crimes where murder is null or state_ut ='';
select * from standard2_crimes where ATTEMPT_TO_MURDER is null or state_ut ='';
select * from standard2_crimes where CULPABLE_HOMICIDE_NOT_AMOUNTING_TO_MURDER is null or state_ut ='';
select * from standard2_crimes where RAPE is null or state_ut ='';
select * from standard2_crimes where CUSTODIAL_RAPE is null or state_ut ='';
select * from standard2_crimes where OTHER_RAPE is null or state_ut ='';
select * from standard2_crimes where KIDNAPPING_ABDUCTION is null or state_ut ='';
select * from standard2_crimes where KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS is null or state_ut ='';
select * from standard2_crimes where KIDNAPPING_AND_ABDUCTION_OF_OTHERS is null or state_ut ='';
select * from standard2_crimes where DACOITY is null or state_ut ='';
select * from standard2_crimes where PREPARATION_AND_ASSEMBLY_FOR_DACOITY is null or state_ut ='';
select * from standard2_crimes where ROBBERY is null or state_ut ='';
select * from standard2_crimes where BURGLARY is null or state_ut ='';
select * from standard2_crimes where THEFT is null or state_ut ='';
select * from standard2_crimes where AUTO_THEFT is null or state_ut ='';
select * from standard2_crimes where OTHER_THEFT is null or state_ut ='';
select * from standard2_crimes where RIOTS is null or state_ut ='';
select * from standard2_crimes where CRIMINAL_BREACH_OF_TRUST is null or state_ut ='';
select * from standard2_crimes where CHEATING is null or state_ut ='';
select * from standard2_crimes where COUNTERFIETING is null or state_ut ='';
select * from standard2_crimes where ARSON is null or state_ut ='';
select * from standard2_crimes where HURT_GREVIOUS_HURT is null or state_ut ='';
select * from standard2_crimes where DOWRY_DEATHS is null or state_ut ='';
select * from standard2_crimes where ASSAULT_ON_WOMEN_WITH_INTENT_TO_OUTRAGE_HER_MODESTY is null or state_ut ='';
select * from standard2_crimes where INSULT_TO_MODESTY_OF_WOMEN is null or state_ut ='';
select * from standard2_crimes where CRUELTY_BY_HUSBAND_OR_HIS_RELATIVES is null or state_ut ='';
select * from standard2_crimes where IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES is null or state_ut ='';
select * from standard2_crimes where CAUSING_DEATH_BY_NEGLIGENCE is null or state_ut ='';
select * from standard2_crimes where OTHER_IPC_CRIMES is null or state_ut ='';
/* No any blank or null value found */



/*-----------------REMOVE ROWS ---------------*/
/*remove rows*/
select * from Unique_crimes  where district='total';/* there is so may rows that has to remove*/
select * from unique_crimes where district like '%zz total%';/* there is so may rows that has to remove*/
select * from Unique_crimes  where state_ut like '%total%';/*no any rows of total*/
select * from unique_crimes where state_ut like '%zz total%';/*no any rows of total*/
/* create new table to delete records */
create table standard3_crimes like standard2_crimes;/* create a new table to modify records.*/
insert standard3_crimes select * from standard2_crimes;/* insert data into new table*/
delete from standard3_crimes where district like '%zz total%' or DISTRICT like '%total%'; /* it delete rows of total or zz total */
select * from standard3_crimes ;
select * from standard3_crimes  where CUSTODIAL_RAPE > 0;



/*-----------------REMOVE COLUMNS ---------------*/
select total_ipc_crimeS from standard3_crimes; /* this is total of all crimes and it is not needed we have to do calculation*/
select * from standard3_crimes  WHERE RAPE != (OTHER_RAPE + CUSTODIAL_RAPE); /* rape column is also an total rape and there is no need of this total rape column*/
select * from standard3_crimes  WHERE KIDNAPPING_ABDUCTION != (KIDNAPPING_AND_ABDUCTION_OF_OTHERS + KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS); /* this is also an aggregated column */
select * from standard3_crimes  WHERE THEFT != (OTHER_THEFT + AUTO_THEFT); /*this is also an aggregated column */
/* delete aggregated columns like rape, theft, kidnapping */

/* first create new copy of table */
create table cleaned_crimes like standard3_crimes;/* create a new table to modify records.*/
insert cleaned_crimes select * from standard3_crimes;/* insert data into new table*/

alter table cleaned_crimes drop column RAPE;
alter table cleaned_crimes drop column KIDNAPPING_ABDUCTION;
alter table cleaned_crimes drop column THEFT;
select * from cleaned_crimes ;




/*EDA */
select * from ipc_crimes where district='unnao';
select state_ut, sum(OTHER_RAPE) from cleaned_crimes group by State_UT order by sum(OTHER_RAPE) desc ;
select state_ut, sum(murder) from cleaned_crimes group by State_UT order by sum(murder) desc ;

select state_ut, sum(KIDNAPPING_AND_ABDUCTION_OF_OTHERS) from cleaned_crimes group by State_UT order by sum(KIDNAPPING_AND_ABDUCTION_OF_OTHERS) desc ;
select state_ut, sum(KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS) from cleaned_crimes group by State_UT order by sum(KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS) desc ;
select state_ut, sum(OTHER_THEFT) from cleaned_crimes group by State_UT order by sum(OTHER_THEFT) desc;
select year , sum(KIDNAPPING_AND_ABDUCTION_OF_OTHERS) from cleaned_crimes group by year order by sum(KIDNAPPING_AND_ABDUCTION_OF_OTHERS) desc;
select year , sum(OTHER_RAPE) from cleaned_crimes group by year order by sum(OTHER_RAPE) desc;
select year , sum(murder) from cleaned_crimes group by year order by sum(murder) desc ;
select state_ut, district , year ,sum( IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) from cleaned_crimes group by state_ut, district , year order by sum(IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) desc ;
select state_ut ,sum( IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) from cleaned_crimes group by state_ut order by sum(IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) desc ;
select  district  ,sum( IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) from cleaned_crimes group by district order by sum(IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) desc ;
select  year ,sum( IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) from cleaned_crimes group by  year order by sum(IMPORTATION_OF_GIRLS_FROM_FOREIGN_COUNTRIES) desc ;

select state_ut, sum(OTHER_RAPE) from ipc_crimes group by State_UT order by sum(OTHER_RAPE) desc limit 1;
select state_ut, sum(OTHER_RAPE) from cleaned_crimes group by State_UT order by sum(OTHER_RAPE) desc limit 1;

select state_ut , sum( murder + other_rape + KIDNAPPING_AND_ABDUCTION_OF_OTHERS + OTHER_THEFT + KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS) from cleaned_crimes
group by state_ut order by sum(murder + other_rape + KIDNAPPING_AND_ABDUCTION_OF_OTHERS + OTHER_THEFT + KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS) desc ;

select district ,state_ut , sum( murder + other_rape + KIDNAPPING_AND_ABDUCTION_OF_OTHERS + OTHER_THEFT + KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS) from cleaned_crimes
 group by district ,state_ut order by sum(murder + other_rape + KIDNAPPING_AND_ABDUCTION_OF_OTHERS + OTHER_THEFT + KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS) desc limit 10;

select year , sum( murder + other_rape + KIDNAPPING_AND_ABDUCTION_OF_OTHERS + OTHER_THEFT + KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS) from cleaned_crimes
 group by year order by sum(murder + other_rape + KIDNAPPING_AND_ABDUCTION_OF_OTHERS + OTHER_THEFT + KIDNAPPING_AND_ABDUCTION_OF_WOMEN_AND_GIRLS) desc ;


