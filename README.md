# SQL_skills

### Аналіз користувацької активності та ефективності email-кампаній

- Розробила SQL-запит для збору агрегованих даних з метою аналізу динаміки створення акаунтів, активності користувачів за email-листами (відправлення, відкриття, переходи) та поведінкових ознак (інтервал відправлення, верифікація акаунта, статус підписки).
- Сформувала звіт з такими показниками:
  - `date`, `country`, `send_interval`, `is_verified`, `is_unsubscribed`
  - `account_cnt`, `sent_msg`, `open_msg`, `visit_msg`
  - `total_country_account_cnt`, `total_country_sent_cnt`
  - `rank_total_country_account_cnt`, `rank_total_country_sent_cnt`
- Реалізувала фільтрацію даних: залишено лише країни, що входять у топ-10 за кількістю створених акаунтів або відправлених листів.
- Побудувала інтерактивну візуалізацію в Looker Studio:
  - загальні значення в розрізі країн (`account_cnt`, `total_country_sent_cnt`, `rank_total_country_account_cnt`, `rank_total_country_sent_cnt`);
  - динаміка за часом для показника `sent_msg`.
 

![Візуалізація](https://snipboard.io/7ipfcg.jpg)
