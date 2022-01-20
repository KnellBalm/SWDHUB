| join left '수원시 예방접종 현황_2' 수원시 코로나 확진자.POSITIVITY_DISPATCH = 수원시 예방접종 현황_2.REFERENCEDATE
| concat POSITIVITY_DISPATCH, "" as DATE
| FIELDS DATE, count as 당일 확진자 수, 수원시 예방접종 현황_2_REFERENCEDATE as REFERENCEDATE, 수원시 예방접종 현황_2_접종수요 as 접종수요, 수원시 예방접종 현황_2_1차접종완료 as 1차 접종자 수, 수원시 예방접종 현황_2_2차접종완료 as 2차 접종자 수
| where DATE >= '2021'
| substr DATE 3 8 as DATE
| replace DATE "-" "."
| sort DATE
