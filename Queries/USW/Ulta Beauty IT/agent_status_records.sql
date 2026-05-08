DROP PROCEDURE IF EXISTS `rep_110`.`agent_status_records`;

CREATE PROCEDURE `rep_110`.`agent_status_records`(
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_sort_direction VARCHAR(4),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SET @sql = CONCAT(
        'SELECT
            usr.session_id AS session_id,
            u.name AS name,
            u.username AS username,
            FROM_UNIXTIME((usr.timestamp / 1000)) AS time_stamp,
			usr.timestamp AS `utc_timestamp`,
            usr.status AS status,
            p.name AS sub_status,
            COALESCE(SEC_TO_TIME(ROUND((usr.status_duration / 1000), 0)), SEC_TO_TIME(0)) AS status_duration,
            usr.updated_on AS update_time
        FROM
            rep_110.user_status_record usr
            LEFT JOIN rep_110.user u ON usr.user_id = u.id
            LEFT JOIN rep_110.presence p ON usr.sub_status_id = p.id
        WHERE
            usr.updated_on BETWEEN ? AND ?
        ORDER BY usr.updated_on ', p_sort_direction, '
        LIMIT ? OFFSET ?'
    );

    PREPARE stmt FROM @sql;
    SET @start_time = p_start_time;
    SET @end_time = p_end_time;
    SET @limit = p_limit;
    SET @offset = p_offset;
    EXECUTE stmt USING @start_time, @end_time, @limit, @offset;
    DEALLOCATE PREPARE stmt;
END 