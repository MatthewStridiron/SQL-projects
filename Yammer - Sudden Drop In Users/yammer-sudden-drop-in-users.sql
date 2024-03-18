/* query 1 */
SELECT EXTRACT ('month' FROM occurred_at) AS month,
  COUNT (CASE WHEN event_name  = 'login' THEN 1 END) AS login,
  COUNT (CASE WHEN event_name  = 'home_page' THEN 1 END) AS home_page,
  COUNT (CASE WHEN event_name  = 'view_inbox' THEN 1 END) AS view_inbox,
  COUNT (CASE WHEN event_name  = 'send_message' THEN 1 END) AS send_message,
  COUNT (CASE WHEN event_name  = 'like_message' THEN 1 END) AS like_message,
  COUNT (CASE WHEN event_name  = 'search_autocomplete' THEN 1 END) AS search_autocomplete,
  COUNT (CASE WHEN event_name  = 'search_run' THEN 1 END) AS search_run,
  COUNT (CASE WHEN event_name ilike 'search_click_result_%' THEN 1 END) AS search_click_result_X,
  COUNT (event_name ) AS total_events
  FROM tutorial.yammer_events
  GROUP BY 1

/* query 2 */
SELECT sub.month,
  100 * login/total_engagement_events AS percent_login,
  100 * home_page/total_engagement_events AS percent_home_page,
  100 * view_inbox/total_engagement_events AS percent_view_inbox,
  100 * send_message/total_engagement_events AS percent_send_message,
  100 * like_message/total_engagement_events AS percent_like_message,
  100 * search_autocomplete/total_engagement_events AS percent_search_autocomplete,
  100 * search_run/total_engagement_events AS percent_search_run,
  100 * search_click_result_X/total_engagement_events AS percent_search_click_result_X
  FROM (
    SELECT EXTRACT ('month' FROM occurred_at) AS month,
    COUNT (CASE WHEN event_name  = 'login' THEN 1 END) AS login,
    COUNT (CASE WHEN event_name  = 'home_page' THEN 1 END) AS home_page,
    COUNT (CASE WHEN event_name  = 'view_inbox' THEN 1 END) AS view_inbox,
    COUNT (CASE WHEN event_name  = 'send_message' THEN 1 END) AS send_message,
    COUNT (CASE WHEN event_name  = 'like_message' THEN 1 END) AS like_message,
    COUNT (CASE WHEN event_name  = 'search_autocomplete' THEN 1 END) AS search_autocomplete,
    COUNT (CASE WHEN event_name  = 'search_run' THEN 1 END) AS search_run,
    COUNT (CASE WHEN event_name  ilike 'search_click_result_%' THEN 1 END) AS search_click_result_X,
    COUNT (CASE WHEN event_type = 'engagement' THEN 1 END) AS total_engagement_events
    FROM tutorial.yammer_events
    GROUP BY 1
  ) sub

/* query 3 */
SELECT EXTRACT ('month' FROM users.created_at) AS month,
  COUNT (DISTINCT users.user_id) AS total_users_created,
  COUNT (DISTINCT e.user_id) AS total_users_retained_next_month,
  COUNT(DISTINCT e.user_id) * 100.0 / COUNT(DISTINCT users.user_id) AS percent_active_next_month
  FROM tutorial.yammer_users users
  LEFT JOIN tutorial.yammer_events e
  ON e.user_id = users.user_id
  AND EXTRACT ('month' FROM e.occurred_at) = EXTRACT('month' FROM users.created_at) + 1
  WHERE EXTRACT ('month' FROM users.created_at) BETWEEN 5 AND 8
  GROUP BY 1

/* query 4 */
SELECT EXTRACT ('month' FROM users.created_at) AS month,
  COUNT (DISTINCT users.user_id) AS total_users_created,
  COUNT (DISTINCT e.user_id) AS total_users_retained_next_month,
  COUNT(DISTINCT e.user_id) * 100.0 / COUNT(DISTINCT users.user_id) AS percent_active_next_month
  FROM tutorial.yammer_users users
  LEFT JOIN tutorial.yammer_events e
  ON e.user_id = users.user_id
  AND EXTRACT ('month' FROM e.occurred_at) = EXTRACT('month' FROM users.created_at) + 2
  WHERE EXTRACT ('month' FROM users.created_at) BETWEEN 5 AND 8
  GROUP BY 1

/* query 5 */
SELECT sub.location,
  sub.july_events_logged,
  sub.august_events_logged
  FROM (
    SELECT location,
    COUNT (CASE WHEN EXTRACT ('month' FROM occurred_at) = 7 THEN 1 END) AS july_events_logged,
    COUNT (CASE WHEN EXTRACT ('month' FROM occurred_at) = 8 THEN 1 END) AS august_events_logged
    FROM tutorial.yammer_events
    GROUP BY 1
  ) sub
  WHERE sub.august_events_logged < sub.july_events_logged
ORDER BY sub.august_events_logged -  sub.july_events_logged

/* query 6 */
SELECT sub.location,
  sub.device,
  sub.july_events_logged,
  sub.august_events_logged
  FROM (
    SELECT location,
    device, 
    COUNT (CASE WHEN EXTRACT ('month' FROM occurred_at) = 7 THEN 1 END) AS july_events_logged,
    COUNT (CASE WHEN EXTRACT ('month' FROM occurred_at) = 8 THEN 1 END) AS august_events_logged
    FROM tutorial.yammer_events
    GROUP BY 1,2
  ) sub
  WHERE sub.august_events_logged < sub.july_events_logged 
  ORDER BY sub.august_events_logged - sub.july_events_logged

/* query 7 */
SELECT sub.location,
  sub.july_incidents,
  sub.august_incidents
  FROM (
    SELECT location,
    COUNT (CASE WHEN EXTRACT ('month' FROM occurred_at) = 7 THEN 1 END) AS july_incidents,
    COUNT (CASE WHEN EXTRACT ('month' FROM occurred_at) = 8 THEN 1 END) AS august_incidents
    FROM tutorial.yammer_events
    GROUP BY 1
  ) sub
  WHERE sub.august_incidents > sub.july_incidents
ORDER BY sub.august_incidents - sub.july_incidents DESC

/* query 8 */
SELECT EXTRACT('week' FROM occurred_at) AS week,
  COUNT(DISTINCT CASE WHEN device IN ('macbook pro','lenovo thinkpad','macbook air','dell inspiron notebook',
          'asus chromebook','dell inspiron desktop','acer aspire notebook','hp pavilion desktop','acer aspire desktop','mac mini')
          THEN user_id ELSE NULL END) AS computer,
  COUNT(DISTINCT CASE WHEN device IN ('iphone 5','samsung galaxy s4','nexus 5','iphone 5s','iphone 4s','nokia lumia 635',
       'htc one','samsung galaxy note','amazon fire phone') THEN user_id ELSE NULL END) AS phone,
  COUNT(DISTINCT CASE WHEN device IN ('ipad air','nexus 7','ipad mini','nexus 10','kindle fire','windows surface',
        'samsumg galaxy tablet') THEN user_id ELSE NULL END) AS tablet
  FROM tutorial.yammer_events
  GROUP BY 1























