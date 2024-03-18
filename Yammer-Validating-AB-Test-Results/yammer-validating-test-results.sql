/* query 1 */
SELECT c.experiment,
       c.experiment_group,
       c.users,
       c.total_treated_users,
       ROUND(c.users/c.total_treated_users,4) AS treatment_percent,
       c.total,
       ROUND(c.average,4)::FLOAT AS average,
       ROUND(c.average - c.control_average,4) AS rate_difference,
       ROUND((c.average - c.control_average)/c.control_average,4) AS rate_lift,
       ROUND(c.stdev,4) AS stdev,
       ROUND((c.average - c.control_average) /
          SQRT((c.variance/c.users) + (c.control_variance/c.control_users))
        ,4) AS t_stat,
       (1 - COALESCE(nd.value,1))*2 AS p_value
  FROM (
SELECT *,
       MAX(CASE WHEN b.experiment_group = 'control_group' THEN b.users ELSE NULL END) OVER () AS control_users,
       MAX(CASE WHEN b.experiment_group = 'control_group' THEN b.average ELSE NULL END) OVER () AS control_average,
       MAX(CASE WHEN b.experiment_group = 'control_group' THEN b.total ELSE NULL END) OVER () AS control_total,
       MAX(CASE WHEN b.experiment_group = 'control_group' THEN b.variance ELSE NULL END) OVER () AS control_variance,
       MAX(CASE WHEN b.experiment_group = 'control_group' THEN b.stdev ELSE NULL END) OVER () AS control_stdev,
       SUM(b.users) OVER () AS total_treated_users
  FROM (
SELECT a.experiment,
       a.experiment_group,
       COUNT(a.user_id) AS users,
       AVG(a.metric) AS average,
       SUM(a.metric) AS total,
       STDDEV(a.metric) AS stdev,
       VARIANCE(a.metric) AS variance
  FROM (
SELECT ex.experiment,
       ex.experiment_group,
       ex.occurred_at AS treatment_start,
       u.user_id,
       u.activated_at,
       COUNT(CASE WHEN e.event_name = 'send_message' THEN e.user_id ELSE NULL END) AS metric
  FROM (SELECT user_id,
               experiment,
               experiment_group,
               occurred_at
          FROM tutorial.yammer_experiments
         WHERE experiment = 'publisher_update'
       ) ex
  JOIN tutorial.yammer_users u
    ON u.user_id = ex.user_id
  JOIN tutorial.yammer_events e
    ON e.user_id = ex.user_id
   AND e.occurred_at >= ex.occurred_at
   AND e.occurred_at < '2014-07-01'
   AND e.event_type = 'engagement'
 GROUP BY 1,2,3,4,5
       ) a
 GROUP BY 1,2
       ) b
       ) c
  LEFT JOIN benn.normal_distribution nd
    ON nd.score = ABS(ROUND((c.average - c.control_average)/SQRT((c.variance/c.users) + (c.control_variance/c.control_users)),3))

/* query 2 */
SELECT experiment_group,
  100 * COUNT(DISTINCT CASE WHEN device IN ('macbook pro','lenovo thinkpad','macbook air','dell inspiron notebook',
          'asus chromebook','dell inspiron desktop','acer aspire notebook','hp pavilion desktop','acer aspire desktop','mac mini')
          THEN user_id ELSE NULL END)/COUNT(*) AS computer_percentage,
  100 * COUNT(DISTINCT CASE WHEN device IN ('iphone 5','samsung galaxy s4','nexus 5','iphone 5s','iphone 4s','nokia lumia 635',
       'htc one','samsung galaxy note','amazon fire phone') THEN user_id ELSE NULL END)/COUNT(*) AS phone_percentage,
  100 * COUNT(DISTINCT CASE WHEN device IN ('ipad air','nexus 7','ipad mini','nexus 10','kindle fire','windows surface',
        'samsumg galaxy tablet') THEN user_id ELSE NULL END)/COUNT(*) AS tablet_percentage
  FROM tutorial.yammer_experiments
  GROUP BY 1

/* query 3 */
SELECT sub.account_age,
COUNT (sub.account_age) AS num_participants
FROM (
  SELECT CASE WHEN e.occurred_at < u.created_at + INTERVAL '1 day' THEN 'one_day'
      WHEN e.occurred_at < u.created_at + INTERVAL '1 week' THEN 'one_week'
      WHEN e.occurred_at < u.created_at + INTERVAL '1 month' THEN 'one_month'
      WHEN e.occurred_at < u.created_at + INTERVAL '2 months' THEN 'two_months'
      WHEN e.occurred_at < u.created_at + INTERVAL '3 months' THEN 'three_months'
      WHEN e.occurred_at < u.created_at + INTERVAL '4 months' THEN 'four_months'
      WHEN e.occurred_at < u.created_at + INTERVAL '5 months' THEN 'five_months'
      WHEN e.occurred_at < u.created_at + INTERVAL '6 months' THEN 'six_months'
      WHEN e.occurred_at < u.created_at + INTERVAL '7 months' THEN 'seven_months'
      WHEN e.occurred_at < u.created_at + INTERVAL '8 months' THEN 'eight_months'
      WHEN e.occurred_at < u.created_at + INTERVAL '9 months' THEN 'nine_months'
      WHEN e.occurred_at < u.created_at + INTERVAL '10 months' THEN 'ten_months'
      ELSE 'more_than_ten_months' END AS account_age
  FROM tutorial.yammer_users u
  JOIN tutorial.yammer_experiments e
    ON u.user_id = e.user_id
    AND e.experiment_group = 'test_group'
) sub
GROUP BY 1
ORDER BY 1