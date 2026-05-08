
-- ticket link
-- https://3clogic.atlassian.net/browse/INA-703

Reporting Type - v2


CALL contact_history_records('2023-08-01 00:00:00','2026-08-29 23:59:59','DESC',100,0);

CALL missed_interactions('2023-08-01 00:00:00','2026-08-29 23:59:59','DESC',100,0);

CALL agent_status_records('2023-08-01 00:00:00','2026-08-29 23:59:59','ASC',100,0);

CALL agent_session_records('2023-08-01 00:00:00','2026-08-29 23:59:59','DESC',100,0);

CALL flow_dnis_queue_report('2023-08-01 00:00:00','2026-08-29 23:59:59','DESC',100,0);



CALL get_ccclogic_CHR(
    '2025-08-01 00:00:00',   -- start_time
    '2025-08-29 23:59:59',   -- end_time
    'DESC',                  -- sort_direction ('ASC' or 'DESC')
    100,                     -- limit
    0                        -- offset
);



-- RDS
-- password length is 50
INSERT INTO reporting_7x_db.customer
(id,kit, name, call_center_id, authorization_token, authorization_url, queue_child_cdr_url, 
agent_child_cdr_url, is_active, alert_recipient)
VALUES(121,'USW', 'United Gaming', 88, '3ldSu1zNiAx519nzfNOJRajK949j3cyBOmX6IAhgXHcHMF9ihu', 
'https://sailor-usw.3ccloud.com/api/v1/callcenters/88/users/tokens/refresh', 
'https://analytics-usw.3ccloud.com/api/v1/callcenters/88/views/50005/portlets/20/conversations', 
'https://analytics-usw.3ccloud.com/api/v1/callcenters/88/views/50005/portlets/20/conversations',
1, 'aygoel@3clogic.com');




INSERT INTO reporting_7x_db.database_detail
(customer_id, db_host, db_username, db_password, db_name)
VALUES(121, 'rds-usw-replication.3ccloud.com', 'unig', 'UNIG%^78', 'rep_88');


-- Customer Details

KIT - USW
CCid - 88
Key - 3ldSu1zNiAx519nzfNOJRajK949j3cyBOmX6IAhgXHcHMF9ihu
Name - United Gaming
customer id - 121
URL - https://webhooks-or.3ccloud.com/reporting-7x/api/v2/customer/121/get-customer-details