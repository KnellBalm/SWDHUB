## 기준인구
# 데이터 모델 : 수원시 통계 수원시 전체 인구 현황
*| sql "SELECT *, max(BASIS_DATE) over ()  as DATE FROM angora"    # 해당 데이터 최근일자 추출
| WHERE BASIS_DATE = DATE                                          # 최근일자와 같은 데이터만 조회
| WHERE AGE = '합 계' AND SEX_DISTINCTION = '계'                   # 전체 인구 조건
| typecast POPULATION_COUNT INTEGER 

## 백신접종 1,2,3,4차 금일, 누계, 접종률
# 데이터 모델 : 예방접종 세부 실적 추가 접종
*| sql "SELECT *, max(REFERENCEDATE) over () as DATE FROM angora"   # 해당 데이터 최근일자 추출
| WHERE REFERENCEDATE = DATE AND TYPE = '계'                        # 최근일자와 같은 데이터만 조회
| ROUND 2 col = QUARTERNARY_VACCINATION_INOCULATION_RATE            # 4차의 경우 접종자 수 가 적어 소수점 2번째 자리로 반올림

## 백신접종 1,2,3,4차 접종률 Gauge
# 1차
*|sql "SELECT *, max(REFERENCEDATE) over () as DATE FROM angora"
| WHERE REFERENCEDATE = DATE AND TYPE = '계'
| FIELDS PRIMARY_VACCINATION_RATE
# 2차
*|sql "SELECT *, max(REFERENCEDATE) over () as DATE FROM angora"
| WHERE REFERENCEDATE = DATE AND TYPE = '계'
| FIELDS SECONDARY_VACCINATION_RATE
# 3차
*|sql "SELECT *, max(REFERENCEDATE) over () as DATE FROM angora"
| WHERE REFERENCEDATE = DATE AND TYPE = '계'
| FIELDS TERTIARY_VACCINATION_RATE
# 4차
*|sql "SELECT *, max(REFERENCEDATE) over () as DATE FROM angora"
| WHERE REFERENCEDATE = DATE AND TYPE = '계'
| FIELDS QUARTERNARY_VACCINATION_RATE

## 전국/경기도 접종률
# 데이터 모델 : 코로나 예방접종 통계 추가 예방접종
*| sql "SELECT *, max(REFERENCEDATE) over () as DATE FROM angora"      # 최근 날짜 추출
| WHERE REFERENCEDATE = DATE AND CITY_AND_PROVINCES = '전국'           # 최근 날짜와 일치하면서 시도구분이 전국인 데이터 조회
| DISTINCT *                                                           # 중복 데이터 제외
| calculate (ACCUMULATE_PRIMARY_VACCINATION / 51846339) * 100 as VC1   # 전국 인구수 대비 1차 접종자 수 누계
| calculate (ACCUMULATE_SECONDARY_VACCINATION / 51846339) * 100 as VC2   # 전국 인구수 대비 2차 접종자 수 누계
| calculate (ACCUMULATE_TERTIARY_VACCINATION / 51846339) * 100 as VC3   # 전국 인구수 대비 3차 접종자 수 누계
| round 1 col = VC1                                                    # 1차 접종률 소수점 1자리에서 반올림   
| round 1 col = VC2                                                    # 2차 접종률 소수점 1자리에서 반올림
| round 1 col = VC3                                                    # 3차 접종률 소수점 1자리에서 반올림

# 데이터 모델 : 코로나 예방접종 통계 추가 예방접종
*| sql "SELECT *, max(REFERENCEDATE) over () as DATE FROM angora"      # 최근 날짜 추출
| WHERE REFERENCEDATE = DATE AND CITY_AND_PROVINCES = '경기도'           # 최근 날짜와 일치하면서 시도구분이 경기도인 데이터 조회
| DISTINCT *                                                           # 중복 데이터 제외
| calculate (ACCUMULATE_PRIMARY_VACCINATION / 13530519) * 100 as VC1   # 경기도 인구수 대비 1차 접종자 수 누계
| calculate (ACCUMULATE_SECONDARY_VACCINATION / 13530519) * 100 as VC2   # 경기도 인구수 대비 2차 접종자 수 누계
| calculate (ACCUMULATE_TERTIARY_VACCINATION / 13530519) * 100 as VC3   # 경기도 인구수 대비 3차 접종자 수 누계
| round 1 col = VC1                                                    # 1차 접종률 소수점 1자리에서 반올림   
| round 1 col = VC2                                                    # 2차 접종률 소수점 1자리에서 반올림
| round 1 col = VC3                                                    # 3차 접종률 소수점 1자리에서 반올림


## 연령별 접종 현황
# 데이터 모델 : 일반인 예방접종 현황
*| SUBSTR REFERENCEDATE 0 4 AS TOYEAR                                        # 데이터 기준일자의 연도 추출
| CASE WHEN LIFESTYLE_YEAR < 10 THEN LIFESTYLE_YEAR AS AGE                   # 10년생 미만은 따로 분류
| CONCAT "200", AGE as A                                                     # 200# 년생
| CONCAT "19", LIFESTYLE_YEAR AS B                                           # 19## 년생
| CASE WHEN B < 1000 THEN A OTHERWISE B                                      # A와 B 한 컬럼(result)으로 병합
| calculate (TOYEAR - result)                                                # 데이터기준일자의 연도에서 출생연도 차감 = 나이
| SUBSTR calculated 0 1                                                      # 나이 앞글자를 뽑아 연령대 추출
| CONCAT SUBSTRED, "0대" AS 나이                                             # 연령대 + 0대 = #0대
| FIELDS VACCINATION_COMPLETION AS 차수, 나이, TYPE                           # 백신 완료 차수, 나이, 개수를 세기 위한 컬럼
| STATS COUNT(TYPE) as 접종자수 by 나이, 차수                                  # 연령대와 차수별로 집계
| SORT +나이, 차수                                                            # 나이와 차수별로 오름차순 정렬
| PIVOT sum(접종자수) SPLITROW 나이 SPLITCOL 차수                             # 행 : 나이 / 열 : 차수 / 값 : 접종자수 합계 로 pivot table 생성
| SORT +나이                                                                 # 나이 오름차순 정렬
| FIELDS 나이, 1차, 2차, 3차, 4차                                             # 나이, 1,2,3,4차 필드만 조회
| CASE WHEN 나이 = '10대' THEN '10대 이하' WHEN 나이 IN('80대','90'대) THEN '80대 이상' OTHERWISE 나이 AS NEW_AGE    # 10대와 8,90대는 이상/이하를 붙여주고 나머지는 그대로
| STATS SUM(1차) as 1차, SUM(2차) as 2차, SUM(3차) as 3차, SUM(4차) as 4차 by NEW_AGE  # 새로운 연령대별 합계
| FIELDS NEW_AGE AS 나이, 1차,2차,3차,4차                                      # 필요한 컬럼만 추출
| SORT +나이                                                                  # 나이 오름차순 정렬

## 코로나 예방접종&확진자 추이
# 데이터 모델 : 일반인 예방접종 현황
# 데이터 모델 뷰 : 1차 일반인 예방접종 / 2차 일반인 예방접종 / 3차 일반인 예방접종 / 4차 일반인 예방접종 / 코로나발생_2
# 대상 데이터 모델 : 1차 일반인 예방접종 
### n차 일반인 예방접종
*| WHERE VACCINATION_COMPLETION = 'n차'
| STATS COUNT(TYPE) AS CNTn BY REFERENCEDATE
| SORT REFERENCEDATE

### 코로나발생_2
*| WHERE CONFIRM_DATE IS NOT NULL
| STATS COUNT(NUMBER) AS COUNT BY CONFIRM_DATE
| SORT CONFIRM_DATE

# 추이 차트
| JOIN OUTER '2차 일반인 예방접종' 1차 일반인 예방접종.REFERENCEDATE = 2차 일반인 예방접종.REFERENCEDATE              # 1차 일반인 예방접종과 2차 일반인 예방접종 OUTER JOIN
| JOIN OUTER '3차 일반인 예방접종' 1차 일반인 예방접종.REFERENCEDATE = 3차 일반인 예방접종.REFERENCEDATE              # 1차 일반인 예방접종과 3차 일반인 예방접종 OUTER JOIN
| JOIN OUTER '4차 일반인 예방접종' 1차 일반인 예방접종.REFERENCEDATE = 4차 일반인 예방접종.REFERENCEDATE              # 1차 일반인 예방접종과 4차 일반인 예방접종 OUTER JOIN
| WHERE REFERENCEDATE IS NOT NULL                                                                                 # 데이터 기준일자가 비어있는 값은 제외
| FIELDS REFERENCEDATE, CNT1, 2차 일반인 예방접종_CNT2 AS CNT2, 3차 일반인 예방접종_CNT3 AS CNT3, 4차 일반인 예방접종_CNT4 AS CNT4       # 필요한 컬럼만 추출
| sql "SELECT REFERENCEDATE AS DATE, sum(CNT1) OVER(ORDER BY REFERENCEDATE) AS GCOM1, 
sum(CNT2) OVER(ORDER BY REFERENCEDATE) AS GCOM2, sum(CNT3) OVER(ORDER BY REFERENCEDATE) AS GCOM3, 
sum(CNT4) OVER(ORDER BY REFERENCEDATE) AS GCOM4 FROM angora"                                                      # 1,2,3,4차 날짜순서대로 누계값 조회
| SORT +REFERENCEDATE                                                                                             # 기준일자 오름차순 정렬
| JOIN_OUTER '코로나발생_2' as CORONA 1차 일반인 예방접종.DATE = CORONA.CONFIRM_DATE                                # 코로나 확진자 데이터와 OUTER JOIN
| SORT +CORONA_CONFIRM_DATE                                                                                       # 코로나 확진자데이터의 기준일자 기준 오름차순 정렬
| WHERE DATE IS NOT NULL                                                                                          # 기준일자가 비어있는 값은 제외
| FIELDS DATE AS 기준일자, CORONA_COUNT AS 확진자수, GCOM1 AS 1차접종, GCOM2 AS 2차접종, GCOM3 AS 3차접종, GCOM4 AS 4차접종   # 필요한 컬럼만 추출
| SORT +기준일자                                                                                                   # 기준일자 오름차순 정렬
| SUBSTR 기준일자 3 8 AS 기준일자                                                                                   # 2022-01-01 > 22-01-01 으로 변경
| REPLACE 기준일자 "-" "."                                                                                         # 22-01-01 > 22.01.01 으로 변경









