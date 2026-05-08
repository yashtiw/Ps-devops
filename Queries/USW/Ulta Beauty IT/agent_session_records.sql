DROP PROCEDURE IF EXISTS `rep_110`.`agent_session_records`;

CREATE PROCEDURE `rep_110`.`agent_session_records`(
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_sort_direction VARCHAR(4),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    -- Step 1: Increase the max length for GROUP_CONCAT to handle many statuses.
    SET SESSION group_concat_max_len = 1000000;

    -- Step 2: Create a variable to hold the dynamically generated columns.
    SET @dynamic_columns = NULL;

    -- Step 3: Build the dynamic subquery columns for each status.
    SELECT
      GROUP_CONCAT(DISTINCT
        CONCAT(
          'COALESCE((SELECT SEC_TO_TIME(ROUND(SUM(uss2.status_duration) / 1000)) 
            FROM rep_110.user_substatus_summary uss2 
            JOIN rep_110.presence p ON uss2.sub_status_id = p.id 
            WHERE uss2.session_id = uss.session_id 
            AND uss2.utctimestamp = uss.utctimestamp
            AND uss2.user_id = uss.user_id
            AND p.name = ''',
          name,
          '''), SEC_TO_TIME(0)) AS `',
          -- Create a valid column name (lowercase, spaces to underscores)
          REPLACE(LOWER(name), ' ', '_'), 
          '`'
        )
        ORDER BY p.`order`
      ) INTO @dynamic_columns
    FROM
      rep_110.presence p
    WHERE
      p.deleted = 0
      AND p.id != 1; -- Exclude 'Away' status

    -- Step 4: Construct the final query string, including the dynamic columns.
    SET @sql = CONCAT(
        'SELECT
            uss.session_id AS session_id,
            FROM_UNIXTIME((`uss`.`utctimestamp` / 1000)) AS `date_time`,
			uss.utctimestamp AS `utc_timestamp`,
            u.name AS name,
            u.username AS username,
            FROM_UNIXTIME((uss.login_time / 1000)) AS login_time,
            CASE WHEN (uss.logout_time <> 0) THEN FROM_UNIXTIME((uss.logout_time / 1000)) ELSE NULL END AS logout_time,
            COALESCE(SEC_TO_TIME(ROUND((uss.work_duration / 1000), 0)), SEC_TO_TIME(0)) AS work_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.available_duration / 1000), 0)), SEC_TO_TIME(0)) AS available_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.away_duration / 1000), 0)), SEC_TO_TIME(0)) AS away_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.wrapup_duration / 1000), 0)), SEC_TO_TIME(0)) AS wrapup_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.preview_duration / 1000), 0)), SEC_TO_TIME(0)) AS preview_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.active_duration / 1000), 0)), SEC_TO_TIME(0)) AS interaction_active_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.online_duration / 1000), 0)), SEC_TO_TIME(0)) AS online_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.talk_duration / 1000), 0)), SEC_TO_TIME(0)) AS talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.hold_duration / 1000), 0)), SEC_TO_TIME(0)) AS hold_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.handle_duration / 1000), 0)), SEC_TO_TIME(0)) AS handle_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.ring_duration / 1000), 0)), SEC_TO_TIME(0)) AS ring_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.external_transfer_duration / 1000), 0)), SEC_TO_TIME(0)) AS external_transfer_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.internal_transfer_duration / 1000), 0)), SEC_TO_TIME(0)) AS internal_transfer_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.transfer_duration / 1000), 0)), SEC_TO_TIME(0)) AS transfer_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.inbound_handled_duration / 1000), 0)), SEC_TO_TIME(0)) AS inbound_handled_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.outbound_handled_duration / 1000), 0)), SEC_TO_TIME(0)) AS outbound_handled_duration,
            COALESCE(SEC_TO_TIME(ROUND((uss.internal_call_duration / 1000), 0)), SEC_TO_TIME(0)) AS internal_call_duration,
            COALESCE(SEC_TO_TIME(ROUND(( (uss.hold_duration/1000) / NULLIF(uss.held_calls, 0)), 0)), SEC_TO_TIME(0)) AS avg_hold_duration,
            COALESCE(SEC_TO_TIME(ROUND(( (uss.handle_duration/1000) / NULLIF(uss.handled_calls, 0)), 0)), SEC_TO_TIME(0)) AS avg_handle_duration,
            COALESCE(SEC_TO_TIME(ROUND(( (uss.available_duration/1000) / NULLIF((uss.inbound_calls + uss.outbound_calls), 0) ), 0)), SEC_TO_TIME(0)) AS avg_available_duration,
            COALESCE(SEC_TO_TIME(ROUND(( (uss.preview_duration/1000) / NULLIF(uss.inbound_calls, 0)), 0)), SEC_TO_TIME(0)) AS avg_preview_duration,
            COALESCE(SEC_TO_TIME(ROUND(( (uss.talk_duration/1000) / NULLIF(uss.handled_calls, 0)), 0)), SEC_TO_TIME(0)) AS avg_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND(( (uss.wrapup_duration/1000) / NULLIF((uss.inbound_calls + uss.outbound_calls), 0) ), 0)), SEC_TO_TIME(0)) AS avg_wrap_up_duration,
            IFNULL(ROUND(((uss.work_duration / NULLIF(uss.online_duration, 0)) * 100), 2), 0) AS agent_utilization,
            IFNULL(ROUND(((uss.active_duration + uss.wrapup_duration) / NULLIF(uss.available_duration, 0)), 2), 0) AS occupancy_ratio,
            uss.held_calls AS total_held_calls,
            uss.total_calls AS total_interactions,
            uss.inbound_calls AS inbound_calls,
            uss.outbound_calls AS outbound_calls,
            uss.handled_calls AS handled_calls,
            uss.inbound_handled_calls AS inbound_handled_calls,
            uss.internal_transfers AS transfer_internal,
            uss.external_transfers AS transfers_external,
            uss.transfers_made AS transfers_made,
            uss.cold_transfers AS transfers_cold,
            uss.warm_transfers AS transfers_warm,
            uss.conference_participations AS conference_participations,
            uss.disposed_calls AS disposed_calls,
            uss.internal_calls AS internal_calls,
            uss.previewed_calls AS previewed_calls,
            uss.transfer_manual_rejected AS transfer_manual_rejected,
            uss.transfer_auto_rejected AS transfer_auto_rejected,
            uss.missed_call_manual_rejected AS missed_call_manual_rejected,
            uss.missed_call_auto_rejected AS missed_call_auto_rejected,
            uss.missed_calls AS missed_calls,
            uss.outbound_handled_calls AS outbound_handled_calls,
            uss.call_agains AS call_agains,
            uss.agent_transfer_initiated AS agent_transfer_initiated,
            uss.agent_transfer_accepted AS agent_transfer_accepted,
            uss.call_backs AS courtesy_call_back,
            uss.call_backs_handled AS courtesy_call_back_handled,
            ',
            -- Inject the dynamic columns here. Provide a fallback if none are found.
            IFNULL(@dynamic_columns, 'NULL AS no_statuses_found'),
            ',
            COALESCE(SEC_TO_TIME(ROUND((uss.away_duration / 1000), 0)), SEC_TO_TIME(0)) AS away,
            (CASE WHEN uss.updated_on IS NULL THEN uss.created_on ELSE uss.updated_on END ) AS update_time
        FROM
            rep_110.user_session_summary uss
            LEFT JOIN rep_110.user u ON uss.user_id = u.id
        WHERE
           ( uss.updated_on BETWEEN ? AND ?
           OR uss.created_on BETWEEN ? AND ? )
        ORDER BY update_time ', p_sort_direction, '
        LIMIT ? OFFSET ?'
    );

    -- Step 5: Prepare and execute the final query.
    PREPARE stmt FROM @sql;
    SET @start_time = p_start_time;
    SET @end_time = p_end_time;
    SET @limit = p_limit;
    SET @offset = p_offset;
    EXECUTE stmt USING @start_time, @end_time, @start_time, @end_time, @limit, @offset;
    DEALLOCATE PREPARE stmt;
END