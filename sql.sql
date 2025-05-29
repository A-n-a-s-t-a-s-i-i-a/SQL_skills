WITH
 acc_info AS (
 -- select with account metrics
 SELECT
   s.date,
   sp.country,
   a.send_interval,
   a.is_verified,
   a.is_unsubscribed,
   COUNT(a.id) AS account_cnt
 FROM `DA.session` s
 JOIN `DA.session_params` sp
 ON s.ga_session_id = sp.ga_session_id
 JOIN `DA.account_session` acs
 ON sp.ga_session_id = acs.ga_session_id
 JOIN `DA.account` a
 ON acs.account_id = a.id
 GROUP BY 1, 2, 3, 4, 5 ),


 email_info AS (
 -- select with email metrics
 SELECT
   DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
   sp.country,
   a.send_interval,
   a.is_verified,
   a.is_unsubscribed,
   COUNT(DISTINCT es.id_message) AS sent_msg,
   COUNT(DISTINCT eo.id_message) AS open_msg,
   COUNT(DISTINCT ev.id_message) AS visit_msg
 FROM `DA.email_sent` es
 LEFT JOIN `DA.email_open` eo
 ON es.id_message = eo.id_message
 LEFT JOIN `DA.email_visit` ev
 ON es.id_message = ev.id_message
 JOIN `DA.account_session` acs
 ON es.id_account = acs.account_id
 JOIN `DA.account` a
 ON es.id_account = a.id
 JOIN `DA.session_params` sp
 ON acs.ga_session_id = sp.ga_session_id
 JOIN `DA.session` s
 ON acs.ga_session_id = s.ga_session_id
 GROUP BY 1, 2, 3, 4, 5 ),
  total_info AS (


-- select with calculations for total counts
 SELECT
   date,
   country,
   send_interval,
   is_verified,
   is_unsubscribed,
   sum(account_cnt) as account_cnt,
   sum(sent_msg) as sent_msg,
   sum(open_msg) as open_msg,
   sum(visit_msg) as visit_msg,
   sum(SUM(account_cnt)) over(partition by country) AS total_country_account_cnt,
   sum(SUM(sent_msg)) over(partition by country) AS total_country_sent_cnt
 FROM (
   SELECT
       date,
       country,
       send_interval,
       is_verified,
       is_unsubscribed,
       account_cnt,
       0 AS sent_msg,
       0 AS open_msg,
       0 AS visit_msg
   FROM acc_info
   UNION ALL
   SELECT
       date,
       country,
       send_interval,
       is_verified,
       is_unsubscribed,
       0 AS account_cnt,
       sent_msg,
       open_msg,
       visit_msg
   FROM email_info )
 GROUP BY 1, 2, 3, 4, 5),


 rank_info AS (
-- select with calculations for rank counts
 SELECT distinct
   country,
   DENSE_RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
   DENSE_RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
 FROM total_info
)


 SELECT
 date,
 ti.country,
 send_interval,
 is_verified,
 is_unsubscribed,
 account_cnt,
 sent_msg,
 open_msg,
 visit_msg,
 total_country_account_cnt,
 total_country_sent_cnt,
 rank_total_country_account_cnt,
 rank_total_country_sent_cnt
FROM total_info ti
JOIN rank_info ri
ON ti.country = ri.country
WHERE
 (rank_total_country_account_cnt <= 10
 OR rank_total_country_sent_cnt <= 10)
ORDER BY 1, 2
