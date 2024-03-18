/* query 1 */
SELECT u.language,
  COUNT (DISTINCT u.user_id) AS users,
  COUNT (CASE WHEN e.event_name IS NULL THEN 1 END) AS uses_who_never_engaged_in_application,
  COUNT (DISTINCT e.user_id) AS users_who_engaged_in_app,
  COUNT (CASE WHEN e.event_name = 'search_run' THEN 1 END) AS searches_ran,
  COUNT (CASE WHEN e.event_name ilike 'search_click_%' THEN 1 END) AS search_results_that_users_selected
FROM tutorial.yammer_users u
LEFT JOIN tutorial.yammer_events e
ON u.user_id = e.user_id
GROUP BY 1
ORDER BY 3

/* query 2 */
SELECT u.language,
  COUNT (DISTINCT u.user_id) AS users,
  COUNT (CASE WHEN e.event_name IS NULL THEN 1 END) AS uses_who_never_engaged_in_application,
  COUNT (DISTINCT e.user_id) AS users_who_engaged_in_app,
  COUNT (CASE WHEN e.event_name = 'search_run' THEN 1 END) AS searches_ran,
  COUNT (CASE WHEN e.event_name = 'search_autocomplete' THEN 1 END) AS autocomplete_results_selected
FROM tutorial.yammer_users u
LEFT JOIN tutorial.yammer_events e
ON u.user_id = e.user_id
GROUP BY 1
ORDER BY 3

/* query 3 */
SELECT 
  location,
  DATE_TRUNC('week', occurred_at) AS week,
  COUNT(CASE WHEN event_name = 'search_run' THEN 1 END) AS searches_ran,
  LAG(COUNT(*)) OVER (PARTITION BY location ORDER BY DATE_TRUNC('week', occurred_at)) AS previous_week_searches,
  COUNT(CASE WHEN event_name = 'search_run' THEN 1 END) - LAG(COUNT(*)) OVER (PARTITION BY location ORDER BY DATE_TRUNC('week', occurred_at)) AS difference_in_searches
FROM tutorial.yammer_events
WHERE event_name = 'search_run' 
GROUP BY location, DATE_TRUNC('week', occurred_at)
ORDER BY 5

/* query 4 */
SELECT
  DATE_TRUNC('week', sub.occurred_at) AS week,
  COUNT(*) AS searches_started,
  COUNT(CASE WHEN sub.next_search_time < sub.occurred_at + INTERVAL '5 minutes' THEN 1 END) AS searches_within_5_minutes
FROM (
  SELECT 
    user_id,
    occurred_at,
    LEAD(occurred_at) OVER (PARTITION BY user_id ORDER BY occurred_at) AS next_search_time
  FROM 
    tutorial.yammer_events
  WHERE 
    event_name = 'search_run'
) sub
GROUP BY 1

/* query 5 */
SELECT
  DATE_TRUNC('week', sub.occurred_at) AS week,
  COUNT(*) AS searches_started,
  COUNT(CASE WHEN sub.next_search_time < sub.occurred_at + INTERVAL '5 minutes' THEN 1 END) AS searches_within_5_minutes
FROM (
  SELECT 
    user_id,
    occurred_at,
    LEAD(occurred_at) OVER (PARTITION BY user_id ORDER BY occurred_at) AS next_search_time
  FROM 
    tutorial.yammer_events
  WHERE 
    event_name = 'search_autocomplete'
) sub
GROUP BY 1

/* query 6 */
SELECT
    DATE_TRUNC('week', sub.occurred_at) AS week,
    COUNT (CASE WHEN sub.event_name = 'search_run' THEN 1 END) AS searches_ran,
    COUNT (CASE WHEN sub.event_name IN ('search_click_result_1', 'search_click_result_2', 'search_click_result_3') 
    AND sub.next_search_time < sub.occurred_at + INTERVAL '5 minutes' THEN 1 ELSE NULL END) AS top_3_seletected,
    COUNT (CASE WHEN sub.event_name IN ('search_click_result_4', 'search_click_result_5', 'search_click_result_6', 
    'search_click_result_7', 'search_click_result_8', 'search_click_result_9', 'search_click_result_10') 
    AND sub.next_search_time < sub.occurred_at + INTERVAL '5 minutes' THEN 1 ELSE NULL END) AS remaining_7_selected
FROM (
  SELECT 
    user_id,
    occurred_at,
    event_name,
    LEAD(occurred_at) OVER (PARTITION BY user_id ORDER BY occurred_at) AS next_search_time
  FROM  tutorial.yammer_events
  WHERE event_name = 'search_run' OR event_name ilike 'search_click_result_%'
) sub
GROUP BY 1





















































































