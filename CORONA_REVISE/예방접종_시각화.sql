# 1차 일반인 예방접종 데이터 사용

# common_data 28 old
| join outer '2차 일반인 예방접종' 1차 일반인 예방접종.REFERENCEDATE = 2차 일반인 예방접종.REFERENCEDATE 
| fields REFERENCEDATE, CNT1, 2차 일반인 예방접종_CNT2 as CNT2  
| sql "select REFERENCEDATE as DATE, sum(CNT1) over (order by REFERENCEDATE) as GCOM1, 
  sum(CNT2) over (order by REFERENCEDATE) as GCOM2 from angora " 
| join outer '수원시 예방접종 현황' 1차 일반인 예방접종.DATE= 수원시 예방접종 현황.REFERENCEDATE
| fields 수원시 예방접종 현황_REFERENCEDATE as REFERENCEDATE, GCOM1, GCOM2, 
  수원시 예방접종 현황_1차접종완료 as COM1, 수원시 예방접종 현황_2차접종완료 as COM2 
| sql "select *, case when GCOM1 is null then max(GCOM1) over (order by REFERENCEDATE) else GCOM1 END as GGCOM1,
  case when GCOM2 is null then max(GCOM2) over (order by REFERENCEDATE) else GCOM2 END as GGCOM2 from angora" 
| fillna GGCOM1 0, GGCOM2 0 
| sql " select REFERENCEDATE, GGCOM1+COM1 as ALLCOM1, GGCOM2+COM2 as ALLCOM2 from angora" 
| join outer  '수원시 코로나 확진자' as CORONA 1차 일반인 예방접종.REFERENCEDATE = CORONA.POSITIVITY_DISPATCH 
| sql "select ALLCOM1 `1차 접종자 수`, ALLCOM2 `2차 접종자 수`, CORONA_COUNT `당일 확진자 수`,
  case when CORONA_POSITIVITY_DISPATCH is null then REFERENCEDATE else CORONA_POSITIVITY_DISPATCH END as DATETIME  from angora" 
| where DATETIME like '2021%'
| substr DATETIME 6 8 as DATETIME 
| replace DATETIME "-" "." 
| sort DATETIME



# common_data 28 REVISE(ver. since 21)

| join outer '2차 일반인 예방접종' 1차 일반인 예방접종.REFERENCEDATE = 2차 일반인 예방접종.REFERENCEDATE 
| fields REFERENCEDATE, CNT1, 2차 일반인 예방접종_CNT2 as CNT2  
| sql "select REFERENCEDATE as DATE, sum(CNT1) over (order by REFERENCEDATE) as GCOM1, sum(CNT2) over (order by REFERENCEDATE) as GCOM2 from angora " 
| join outer '수원시 예방접종 현황_2' 1차 일반인 예방접종.DATE= 수원시 예방접종 현황_2.REFERENCEDATE
| fields 수원시 예방접종 현황_2_REFERENCEDATE as REFERENCEDATE, GCOM1, GCOM2, 수원시 예방접종 현황_2_1차접종완료 as COM1, 수원시 예방접종 현황_2_2차접종완료 as COM2 
| fields REFERENCEDATE, GCOM1, GCOM2
| where REFERENCEDATE NOT LIKE 'NULL'
| sort +REFERENCEDATE
| join outer  '수원시 코로나 확진자' as CORONA 1차 일반인 예방접종.REFERENCEDATE = CORONA.POSITIVITY_DISPATCH 
| sort +CORONA_POSITIVITY_DISPATCH
| where REFERENCEDATE IS NOT NULL
| substr REFERENCEDATE 3 8 as REFERENCEDATE
| replace REFERENCEDATE "-" "."
| fields REFERENCEDATE as 기준일자, GCOM1 as 1차 접종자 수, GCOM2 as 2차 접종자 수, CORONA_POSITIVITY_DISPATCH as  확진일자, CORONA_COUNT as 확진자 수


# common_data 28 REVISE(ver. since 20)

| join outer '2차 일반인 예방접종' 1차 일반인 예방접종.REFERENCEDATE = 2차 일반인 예방접종.REFERENCEDATE 
| fields REFERENCEDATE, CNT1, 2차 일반인 예방접종_CNT2 as CNT2  
| sql "select REFERENCEDATE as DATE, sum(CNT1) over (order by REFERENCEDATE) as GCOM1, sum(CNT2) over (order by REFERENCEDATE) as GCOM2 from angora " 
| join outer '수원시 예방접종 현황_2' 1차 일반인 예방접종.DATE= 수원시 예방접종 현황_2.REFERENCEDATE
| fields 수원시 예방접종 현황_2_REFERENCEDATE as REFERENCEDATE, GCOM1, GCOM2, 수원시 예방접종 현황_2_1차접종완료 as COM1, 수원시 예방접종 현황_2_2차접종완료 as COM2 
| fields REFERENCEDATE, GCOM1, GCOM2
| where REFERENCEDATE NOT LIKE 'NULL'
| sort +REFERENCEDATE
| join outer  '수원시 코로나 확진자' as CORONA 1차 일반인 예방접종.REFERENCEDATE = CORONA.POSITIVITY_DISPATCH 
| sort +CORONA_POSITIVITY_DISPATCH
| where REFERENCEDATE IS NOT NULL
| fields REFERENCEDATE as 기준일자, GCOM1 as 1차 접종자 수, GCOM2 as 2차 접종자 수, CORONA_POSITIVITY_DISPATCH as  확진일자, CORONA_COUNT as 확진자 수


