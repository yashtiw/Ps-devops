
-- ticket link
-- https://3clogic.atlassian.net/browse/INA-643

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
VALUES(119,'USW', 'UMMS IT', 94, '94nZ4yE02PL2kdO2ceqj6CO8lcJxeESKCyHz04uPU9hvxewIGu', 
'https://sailor-usw.3ccloud.com/api/v1/callcenters/94/users/tokens/refresh', 
'https://analytics-usw.3ccloud.com/api/v1/callcenters/94/views/50005/portlets/20/conversations', 
'https://analytics-usw.3ccloud.com/api/v1/callcenters/94/views/50005/portlets/20/conversations',
1, 'aygoel@3clogic.com');




INSERT INTO reporting_7x_db.database_detail
(customer_id, db_host, db_username, db_password, db_name)
VALUES(119, 'rds-usw-replication.3ccloud.com', 'ummt', 'UMMT%^78', 'rep_94');


-- Customer Details

KIT - USW
CCid - 94
Key - 94nZ4yE02PL2kdO2ceqj6CO8lcJxeESKCyHz04uPU9hvxewIGu
Name - UMMS IT
customer id - 119
URL - https://webhooks-or.3ccloud.com/reporting-7x/api/v2/customer/119/get-customer-details