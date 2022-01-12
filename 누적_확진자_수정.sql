#common_data_19   old
| timeline POSITIVITY_DISPATCH 1H
| substr key 0 10 as DATE
| sort DATE
| fields DATE, value
| sql "SELECT *,sum(value) over (order by DATE) as sum_total FROM angora"
| where DATE like '2021%'
| substr DATE 6 8 as DATE
| replace DATE "-","."
| fields DATE, sum_total as 수원시 누적 확진

# common_data_19_revise
| timeline POSITIVITY_DISPATCH 1H
| substr key 3 8 as DATE
| sort DATE
| fields DATE, value
| sql "SELECT *,sum(value) over (order by DATE) as sum_total FROM angora"
| replace DATE "-","."
| fields DATE, sum_total as 수원시 누적 확진
