# 이전 일자 뽑아내기
############# DATE_SUB 사용 ##############


## 이전 일자
*| sql "SELECT *, max(REFERENCEDATE) OVER () AS TODAY FROM angora"              # 최신 일자
| fields REFERENCEDATE, TODAY                                                   # 기준일자와 오늘일자만 추출
| sql "SELECT REFERENCEDATE, TODAY, DATE_SUB(TODAY,1) as YESTERDAY FROM angora" # 최신 일자와 최신일자 하루 전날
| where REFERENCEDATE = YESTERDAY                                               # 하루 전날과 일치하는 내용

## 이전 년도

*| substr STANDARD_DATE_NAME 0 4 as YEAR                   # 기준 일자의 맨 앞 4자리를 연도로 사용
| sql "SELECT *, max(YEAR) over() as TODAY FROM angora"    # 기준 일자
| sql "SELECT *, DATE_SUB(TODAY,365) as LYEAR FROM angora" # 기준일자와 365일(1년) 이전 일자 추출
| substr LYEAR 0 4 as LYEAR                                # 1년 이전 일자에서 4자리만 이전 년도로 사용
