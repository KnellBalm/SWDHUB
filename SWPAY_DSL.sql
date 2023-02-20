# 데이터 기준일, trg : 자동실행
| typecast REFERENCEDATE DATE 
| sql "select  date_format(max(REFERENCEDATE),"yyyyMM") as last_udt from angora"
| replace last_udt " " ""
| substr last_udt 0 4 as year
| substr last_udt 5 2 as month


# 업종 대분류 콤보박스, 자동실행
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}'
| case when TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = 'T&E' then '여행 및 숙박' otherwise TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION as TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
| calculate add all 
| fillna ADMINISTRATION_DONG_NAME '수원시 전체', GENERATION '전체', SEX_DISTINCTION '전체', TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체', TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION '전체'
{% if combo_5 != '전체' %}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_5}'
{% else %}

{% endif %}
| DISTINCT TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION
| sort +TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION
| fields TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION


#성연령별 집계 - 남자, trg : 데이터기준일
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}' AND SEX_DISTINCTION = '남' 
| stats sum(SETTLEMENT_AMOUNT) as cnt by GENERATION, SEX_DISTINCTION 
| pivot sum(cnt) SPLITCOL SEX_DISTINCTION SPLITROW GENERATION
| sort +GENERATION
| calculate 남 / 1000000 as 남
| round 0 col =남
| typecast 남 INTEGER
| concat GENERATION,"대"
| fields GENERATION as 세대, 남 as 사용액(백만원)

#성연령별 집계 - 여자, trg : 데이터기준일
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}' AND SEX_DISTINCTION = '여' 
| stats sum(SETTLEMENT_AMOUNT) as cnt by GENERATION, SEX_DISTINCTION 
| pivot sum(cnt) SPLITCOL SEX_DISTINCTION SPLITROW GENERATION
| sort +GENERATION
| calculate 여 / 1000000 as 여
| round 0 col =여
| typecast 여 INTEGER
| concat GENERATION,"대"
| fields GENERATION as 세대, 여 as 사용액(백만원)


# 연령대, 성별 결제 금액
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}' 
| case when TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = 'T&E' then '여행 및 숙박' otherwise TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION as TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
{% if combo_1 == '전체' and combo_2 == '전체' and combo_6 == '전체' %}
| calculate add all 
| fillna ADMINISTRATION_DONG_NAME '수원시 전체', GENERATION '전체', SEX_DISTINCTION '전체', TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체', TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION '전체'
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '전체' 
| calculate SETTLEMENT_AMOUNT / 1000000 as total
{% elseif combo_1 != '전체' and combo_2 != '전체' and combo_6 !='전체' %}
| where SEX_DISTINCTION = '${combo_2}' AND GENERATION = '${combo_1}' AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 1000000 as total
{% elseif combo_1 != '전체' and combo_2 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}' AND GENERATION = '${combo_1}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 1000000 as total
{% elseif combo_1 != '전체' and combo_6 != '전체' %}
| where GENERATION = '${combo_1}' AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 1000000 as total
{% elseif combo_2 != '전체' and combo_6 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}'  AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 1000000 as total
{% elseif combo_2 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}' 
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 1000000 as total
{% elseif combo_1 != '전체' %}
| where GENERATION = '${combo_1}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 1000000 as total
{% elseif combo_6 != '전체'%}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 1000000 as total
{% endif %}
| round 0 col = total
| typecast total INTEGER
| fields total

# 이용자 조건 검색 - 최다 방문 가맹점 업종
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}' 
| case when TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = 'T&E' then '여행 및 숙박' otherwise TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION as TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
{% if combo_1 == '전체' and combo_2 == '전체' and combo_6 == '전체' %}
| calculate add all 
| fillna ADMINISTRATION_DONG_NAME '수원시 전체', GENERATION '전체', SEX_DISTINCTION '전체', TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체', TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION '전체'
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '전체' 

{% elseif combo_1 != '전체' and combo_2 != '전체' and combo_6 !='전체' %}
| where SEX_DISTINCTION = '${combo_2}' AND GENERATION = '${combo_1}' AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 
| TOP 1 -total
{% elseif combo_1 != '전체' and combo_2 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}' AND GENERATION = '${combo_1}'
| stats sum(SETTLEMENT_AMOUNT) as total by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 
| TOP 1 -total
{% elseif combo_1 != '전체' and combo_6 != '전체' %}
| where GENERATION = '${combo_1}' AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 
| TOP 1 -total
{% elseif combo_2 != '전체' and combo_6 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}'  AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 
| TOP 1 -total
{% elseif combo_2 != '전체'%}
| where SEX_DISTINCTION = '${combo_2}' 
| stats sum(SETTLEMENT_AMOUNT) as total by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 
| TOP 1 -total
{% elseif combo_1 != '전체'%}
| where GENERATION = '${combo_1}'
| stats sum(SETTLEMENT_AMOUNT) as total by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 
| TOP 1 -total
{% elseif combo_6 != '전체'%}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 
| TOP 1 -total
{% endif %}

# 이용자 조건 검색 - 최다 방문 가맹점 유형
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}' 
| case when TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = 'T&E' then '여행 및 숙박' otherwise TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION as TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
{% if combo_1 == '전체' and combo_2 == '전체' and combo_6 == '전체' %}
| calculate add all 
| fillna ADMINISTRATION_DONG_NAME '수원시 전체', GENERATION '전체', SEX_DISTINCTION '전체', TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체', TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION '전체'
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION != '전체' 

{% elseif combo_1 != '전체' and combo_2 != '전체' and combo_6 !='전체' %}
| where SEX_DISTINCTION = '${combo_2}' AND GENERATION = '${combo_1}' AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
{% elseif combo_1 != '전체' and combo_2 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}' AND GENERATION = '${combo_1}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
{% elseif combo_1 != '전체' and combo_6 != '전체' %}
| where GENERATION = '${combo_1}' AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
{% elseif combo_2 != '전체' and combo_6 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}'  AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
{% elseif combo_2 != '전체'%}
| where SEX_DISTINCTION = '${combo_2}' 
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
{% elseif combo_1 != '전체'%}
| where GENERATION = '${combo_1}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
{% elseif combo_6 != '전체'%}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
{% endif %}


#이용자 조건 검색 - 월평균결제금액
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}' 
| case when TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = 'T&E' then '여행 및 숙박' otherwise TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION as TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
{% if combo_1 == '전체' and combo_2 == '전체' and combo_6 == '전체' %}
| calculate add all 
| fillna ADMINISTRATION_DONG_NAME '수원시 전체', GENERATION '전체', SEX_DISTINCTION '전체', TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체', TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION '전체'
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '전체' 
| calculate SETTLEMENT_AMOUNT / 30000000 as total
{% elseif combo_1 != '전체' and combo_2 != '전체' and combo_6 !='전체' %}
| where SEX_DISTINCTION = '${combo_2}' AND GENERATION = '${combo_1}' AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 30000000 as total
{% elseif combo_1 != '전체' and combo_2 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}' AND GENERATION = '${combo_1}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 30000000 as total
{% elseif combo_1 != '전체' and combo_6 != '전체' %}
| where GENERATION = '${combo_1}' AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 30000000 as total
{% elseif combo_2 != '전체' and combo_6 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}'  AND TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 30000000 as total
{% elseif combo_2 != '전체' %}
| where SEX_DISTINCTION = '${combo_2}' 
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 30000000 as total
{% elseif combo_1 != '전체' %}
| where GENERATION = '${combo_1}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 30000000 as total
{% elseif combo_6 != '전체'%}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_6}'
| stats sum(SETTLEMENT_AMOUNT) as total by  TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 
| top 1 -total
| calculate total / 30000000 as total
{% endif %}
| round 0 col = total
| typecast total INTEGER
| fields total

# 하단 가맹점 분석 - 가맹점 총매출 - trg : combo박스들, 최신 데이터 조회
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}' 
| case when TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = 'T&E' then '여행 및 숙박' otherwise TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION as TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
| calculate add all 
| fillna ADMINISTRATION_DONG_NAME '수원시 전체', GENERATION '전체', SEX_DISTINCTION '전체', TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체', TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION '전체'
{% if combo_5 ==  '전체' %}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION != '${combo_4}'
{% elseif combo_4 == '전체' and combo_5 == '전체' %}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_4}'
{% else %}
| where TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION = '${combo_5}'
{% endif %}
| stats sum(SETTLEMENT_AMOUNT) as total
| calculate total / 30  as month
| calculate total/1000000 as total
| round [0,0] col=[total,month]
| typecast total INTEGER
| typecast month INTEGER


# 추이 기간
| sql "select date_format(date_sub(to_date(max(SETTLEMENT_YEAR_AND_MONTH), 'yyyyMM'), 180), 'yyyyMM') as recent, date_format(date_add(to_date(max(SETTLEMENT_YEAR_AND_MONTH), 'yyyyMM'), 180), 'yyyyMM') as after from angora" 


# 하단 가맹점 분석 - 사용액 추이 trg : 추이 기간
*| where SETTLEMENT_YEAR_AND_MONTH >= '${common_data_11.results[0][0]}' and SETTLEMENT_YEAR_AND_MONTH <= '${common_data_11.results[0][1]}' 
| case when TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = 'T&E' then '여행 및 숙박' otherwise TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION as TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
| calculate add all 
| fillna ADMINISTRATION_DONG_NAME '수원시 전체', GENERATION '전체', SEX_DISTINCTION '전체', TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체', TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION '전체'
{% if combo_5 ==  '전체' %}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION != '${combo_4}'
{% elseif combo_4 == '전체' and combo_5 == '전체' %}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_4}'
{% else %}
| where TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION = '${combo_5}'
{% endif %}
| stats sum(SETTLEMENT_AMOUNT) as total by SETTLEMENT_YEAR_AND_MONTH
| calculate total / 1000000 as total
| round 0  col = total
| typecast total INTEGER
| fields SETTLEMENT_YEAR_AND_MONTH as 결제연월, total as 사용액

 # 하단 가맹점 분석  - 사용액 비중
*| where SETTLEMENT_YEAR_AND_MONTH = '${common_data_4.results[0][0]}' 
| case when TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = 'T&E' then '여행 및 숙박' otherwise TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION as TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION

{% if combo_4 == '전체' and combo_5 == '전체' %}
| stats sum(SETTLEMENT_AMOUNT) as cnt by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
| calculate add col
| fillna TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체'
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '전체'
| rename TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 업종

{% elseif combo_4 and combo_5 == '전체' %}
| stats sum(SETTLEMENT_AMOUNT) as cnt by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
| calculate add col
| fillna TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION '전체'
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION IN ('${combo_4}', '전체')
| rename TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 업종
| pivot sum(cnt) SPLITCOL 업종
| calculate `전체` - `${combo_4}` as 그외업종
| unpivot 전체 `그외업종`,`${combo_4}`
| fields col_id as 업종, col_value as cnt


{% else %}
| where TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION = '${combo_4}'
| stats sum(SETTLEMENT_AMOUNT) as cnt by TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION
| calculate add col
| fillna TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION '${combo_4} 전체'
| where TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION IN ('${combo_4} 전체', '${combo_5}')
| rename TYPE_OF_INDUSTRY_MIDDLE_CLASSIFICATION 업종
| pivot sum(cnt) SPLITCOL 업종
| calculate `${combo_4} 전체` - `${combo_5}` as 그외업종
| unpivot `${combo_4} 전체` `그외업종`,`${combo_5}`
| fields col_id as 업종, col_value as cnt

{% endif %}
| calculate cnt / 1000000 as cnt
| round 0 col=cnt
| typecast cnt INTEGER
| rename cnt 액수(백만원)

# 월별 운영 현황 -trg용
| replace REFERENCEDATE "-" ""
| sql "select max(yr) as recent date_format(date_sub(to_date(max(REFERENCEDATE), 'yyyyMM'), 365), 'yyyyMM') as last_yr from angora" 
| sql 
# 월별 운영현황
| replace REFERENCEDATE "-" ""
| where REFERENCEDATE >= ${common_data_1.results[0][0]} AND REFERENCEDATE <= ${common_data_1.results[0][1]}

# 수원페이 가맹 업종별 분포 현황
| where REFERENCEDATE = '${common_data_4.results[0][0]}'
| stats count(사업자등록번호) as 가맹점수 by TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION
| rename TYPE_OF_INDUSTRY_LARGE_CLASSIFICATION 업종분류




