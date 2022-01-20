# common_data 11 old
| stats sum(SUWON_CITY_CONFIRMED_PERSON) as CON, sum(SUWON_CITY_ISOLATION_RELEASE) as `REL`, sum(SUWON_CITY_DEATH) as `DEH`, max(REFERENCEDATE) as REFERENCEDATE, min(REFERENCEDATE) as CITY  
| calculate CON- REL 
| calculate calculated - DEH as ISO 
| typecast CON INTEGER, REL INTEGER, DEH INTEGER, ISO INTEGER 
| fields REFERENCEDATE, DEH, CON, CITY, REL, ISO
| replace CITY "2020-01-20" "수원"
| union '전국 코로나 UNION'
| substr REFERENCEDATE 0 10 as REFERENCEDATE
| where CITY in('합계','경기','수원')
| sql "select *, max(REFERENCEDATE) over (partition by CITY) as DATE from angora"
| where  REFERENCEDATE = DATE
| fields CITY as 구분, CON as `확진자 계`, REL as `격리 해제`, ISO as `격리 중`, DEH as `사망`, REFERENCEDATE
| replace 구분 "합계" "전국"
| case when 구분 = '전국' then 1 when 구분 = '경기' then 2 when 구분 = '수원' then 3 as 순서
| sort 순서


# common_data 11 revise
*| where PARTITION_DATE!='20211224000000' 
| stats sum(SUWON_CITY_CONFIRMED_PERSON) as CON, sum(SUWON_CITY_ISOLATION_RELEASE) as `REL`, sum(SUWON_CITY_DEATH) as `DEH`, max(REFERENCEDATE) as REFERENCEDATE, min(REFERENCEDATE) as CITY  
| calculate CON- REL 
| calculate calculated - DEH as ISO 
| typecast CON INTEGER, REL INTEGER, DEH INTEGER, ISO INTEGER 
| distinct *
| fields REFERENCEDATE, DEH, CON, CITY, REL, ISO
| replace CITY "2020-01-20" "수원"
| union '전국 코로나 UNION'
| substr REFERENCEDATE 0 10 as REFERENCEDATE
| where CITY in('합계','경기','수원')
| sql "select *, max(REFERENCEDATE) over (partition by CITY) as DATE from angora"
| where  REFERENCEDATE = DATE
| fields CITY as 구분, CON as `확진자 계`, REL as `격리 해제`, ISO as `격리 중`, DEH as `사망`, REFERENCEDATE
| replace 구분 "합계" "전국"
| case when 구분 = '전국' then 1 when 구분 = '경기' then 2 when 구분 = '수원' then 3 as 순서
| sort 순서
