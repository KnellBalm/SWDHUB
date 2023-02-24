#월별 운영 현황 - ver.230227
| sql "select *, date_format(date_sub(to_date(max(STANDARD_YEAR_AND_MONTH) over () , 'yyyy-MM'), 365), 'yyyy-MM') as last, max(STANDARD_YEAR_AND_MONTH) over ()  as recent from angora" 
| where STANDARD_YEAR_AND_MONTH >= last AND STANDARD_YEAR_AND_MONTH <= recent
| fields STANDARD_YEAR_AND_MONTH as 기준연월, USE_AMOUNT as 사용금액, RECHARGE_AMOUNT as 충전금액, INCENTIVE_AMOUNT as 인센티브 
| calculate 사용금액 / 1000000 as 사용액
| calculate (충전금액+인센티브) / 1000000 as 발행액
| calculate 인센티브 / 1000000 as 인센티브
| round [0,0,0] col = [사용액,발행액,인센티브]
| typecast 사용액 INTEGER
| typecast 발행액 INTEGER
| typecast 인센티브 INTEGER
| sort +기준연월

#운영 및 이용현황 -ver.230227
| where STANDARD_YEAR_AND_MONTH = '${sw_recent.results[0][0]}'
| calculate RECHARGE_AMOUNT+INCENTIVE_AMOUNT / 1000000 as RECHARGE_AMOUNT 
| calculate INCENTIVE_AMOUNT / 1000000 as INCENTIVE_AMOUNT 
| calculate USE_AMOUNT / 1000000 as USE_AMOUNT 
| calculate USE_AMOUNT / 30 as month 
| round [0,0,0,0] col = [RECHARGE_AMOUNT,INCENTIVE_AMOUNT,USE_AMOUNT,month]
| typecast month INTEGER
| fields RECHARGE_AMOUNT,USE_AMOUNT,,INCENTIVE_AMOUNT,SUBSCRIBER_COUNT,MEMBER_BRANCH_STORE_COUNT,month

#행정동, 사용자 유형별 결제금액 전체 - ver.230227
{% if combo_1 == '전체' and combo_2 == '전체' and combo_6 == '전체' %}
${common_data_13.results[0][1]}
{% else %}
${common_data_6.results[0][0]}
{% endif %}
