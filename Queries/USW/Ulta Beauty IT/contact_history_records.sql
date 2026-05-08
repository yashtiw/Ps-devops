DROP PROCEDURE IF EXISTS `rep_110`.`contact_history_records`;


CREATE PROCEDURE `rep_110`.`contact_history_records`(
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_sort_direction VARCHAR(4),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SET @sql = CONCAT(
        'SELECT
            chr.conversation_id AS conversation_id,
            FROM_UNIXTIME((chr.flow_start_time / 1000)) AS flow_start_time,
			chr.flow_start_time AS `utc_timestamp`,
            f.name AS im_name,
            FROM_UNIXTIME((chr.flow_end_time / 1000)) AS flow_end_time,
            (SELECT q.name FROM rep_110.queue q WHERE q.id = chr.entry_queue_id) AS entry_queue_name,
            (SELECT q.name FROM rep_110.queue q WHERE q.id = chr.exit_queue_id) AS exit_queue_name,
            chr.skills AS preferred_skill,
            u.username AS username,
            u.name AS name,
            chr.remote_party AS remote_party,
            chr.local_party AS local_party,
            COALESCE(SEC_TO_TIME(ROUND((chr.connection_duration / 1000), 0)), SEC_TO_TIME(0)) AS connection_duration,
            COALESCE(SEC_TO_TIME(ROUND((chr.im_duration / 1000), 0)), SEC_TO_TIME(0)) AS im_time,
            COALESCE(SEC_TO_TIME(ROUND((chr.queue_duration / 1000), 0)), SEC_TO_TIME(0)) AS queue_duration,
            COALESCE(SEC_TO_TIME(ROUND((chr.voicemail_duration / 1000), 0)), SEC_TO_TIME(0)) AS voicemail_time,
            COALESCE(SEC_TO_TIME(ROUND((chr.ring_duration / 1000), 0)), SEC_TO_TIME(0)) AS ring_duration,
            COALESCE(SEC_TO_TIME(ROUND((chr.preview_duration / 1000), 0)), SEC_TO_TIME(0)) AS preview_duration,
            COALESCE(SEC_TO_TIME(ROUND((chr.handle_duration / 1000), 0)), SEC_TO_TIME(0)) AS handle_duration,
            COALESCE(SEC_TO_TIME(ROUND((chr.talk_duration / 1000), 0)), SEC_TO_TIME(0)) AS talk_time,
            COALESCE(SEC_TO_TIME(ROUND((chr.hold_duration / 1000), 0)), SEC_TO_TIME(0)) AS hold_time,
            COALESCE(SEC_TO_TIME(ROUND((chr.wrapup_duration / 1000), 0)), SEC_TO_TIME(0)) AS wrapup_time,
            COALESCE(SEC_TO_TIME(ROUND((chr.transfer_duration / 1000), 0)), SEC_TO_TIME(0)) AS transfer_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((chr.internal_transfer_duration / 1000), 0)), SEC_TO_TIME(0)) AS internal_transfer_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((chr.external_transfer_duration / 1000), 0)), SEC_TO_TIME(0)) AS external_transfer_talk_duration,
            chr.transfer_mode AS transfer_mode,
            chr.transfer_type AS transfer_type,
            chr.transfer_status AS transfer_status,
            (CASE
                WHEN (chr.transfer_party_type = ''Queue'') THEN (
                    SELECT q.name FROM rep_110.queue q WHERE q.queue_flow_id = chr.transfer_party
                )
                WHEN (chr.transfer_party_type = ''Agent'') THEN CONVERT((
                    SELECT u.name FROM rep_110.user u WHERE u.id = chr.transfer_party
                ) USING utf8mb4)
                ELSE CONVERT(chr.transfer_party USING utf8mb4)
            END) AS transfer_party,
            chr.disposition AS disposition,
            chr.courtesy_call_back_status AS courtesy_call_back_status,
            COALESCE(SEC_TO_TIME(ROUND((chr.courtesy_call_back_wait_time / 1000), 0)), SEC_TO_TIME(0)) AS courtesy_call_back_wait_time,
            chr.flow_type AS flow_type,
            chr.notes AS notes,
            chr.call_recording_files AS media_files,
            chr.disposition_service AS disposition_service,
            chr.local_hangup AS local_hangup,
            chr.preferred_call_back_number AS preferred_call_back_number,
            chr.abandoned_im AS abandoned_on_im,
            COALESCE(SEC_TO_TIME(ROUND((chr.conference_duration / 1000), 0)), SEC_TO_TIME(0)) AS conference_duration,
            chr.abandoned_queue AS abandoned_on_queue,
            chr.queue_entry_position AS queue_entry_position,
            chr.updated_on AS update_time
        FROM
            rep_110.contact_history_record chr
            LEFT JOIN rep_110.flow f ON chr.flow_id = f.id
            LEFT JOIN rep_110.user u ON chr.user_id = u.id
        WHERE
            chr.updated_on BETWEEN ? AND ?
        ORDER BY chr.updated_on ', p_sort_direction, '
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