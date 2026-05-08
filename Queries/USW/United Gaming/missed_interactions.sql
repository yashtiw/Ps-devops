DROP PROCEDURE IF EXISTS `rep_88`.`missed_interactions`;


CREATE PROCEDURE `rep_88`.`missed_interactions`(
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_sort_direction VARCHAR(4),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SET @sql = CONCAT(
        'SELECT
            u.name AS name,
            u.username AS username,
            FROM_UNIXTIME((mi.flow_start_time / 1000)) AS call_start_time,
            FROM_UNIXTIME((mi.missed_time / 1000)) AS call_missed_time,
			mi.missed_time AS `utc_timestamp`,
            f.name AS im_name,
            q.name AS queue_name,
            mi.remote_party AS remote_party,
            mi.local_party AS dnis,
            mi.conversation_id AS conversation_id,
            mi.skills AS preferred_skill,
            mi.reject_status AS reject_status,
            mi.call_answered_by_other_agent AS call_answered_by_agent,
            mi.updated_on AS update_time
        FROM
            rep_88.missed_interactions mi
            LEFT JOIN rep_88.user u ON mi.user_id = u.id
            LEFT JOIN rep_88.flow f ON mi.flow_id = f.id
            LEFT JOIN rep_88.queue q ON mi.queue_id = q.id
        WHERE
            mi.updated_on BETWEEN ? AND ?
        ORDER BY mi.updated_on ', p_sort_direction, '
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