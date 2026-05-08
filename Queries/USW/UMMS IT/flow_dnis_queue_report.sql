DROP PROCEDURE IF EXISTS `rep_94`.`flow_dnis_queue_report`;

CREATE PROCEDURE `rep_94`.`flow_dnis_queue_report`(
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_sort_direction VARCHAR(4),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SET @sql = CONCAT(
        'SELECT
            FROM_UNIXTIME((dqs.utctimestamp / 1000)) AS date_time,
			dqs.utctimestamp AS `utc_timestamp`,
            f.name AS flow,
            dqs.dnis AS dnis,
            q.name AS queue_name,
            dqs.total_interactions AS total_interactions,
            dqs.total_calls AS total_inbound_calls,
            dqs.total_calls_to_im AS total_calls_to_im,
            dqs.calls_ended_on_im AS calls_ended_on_im,
            dqs.calls_abandoned_in_im AS customer_disconnect_on_im,
            dqs.total_calls_to_queue AS total_calls_to_queue,
            dqs.calls_ended_on_queue AS calls_ended_on_queue,
            dqs.calls_ended_by_queue AS queue_hangup,
            dqs.calls_abandoned_in_queue AS total_calls_abandoned_in_queue,
            dqs.calls_to_voicemail AS total_calls_to_voicemail,
            dqs.previewed_calls AS previewed_calls,
            dqs.held_calls AS total_held_calls,
            dqs.handled_calls AS handled_calls,
            dqs.inbound_handled_calls AS inbound_handled_calls,
            dqs.outbound_handled_calls AS outbound_handled_calls,
            dqs.missed_calls AS missed_calls,
            dqs.missed_calls_auto AS missed_calls_auto,
            dqs.missed_calls_manual AS missed_calls_manual,
            dqs.courtesy_callback AS courtesy_callback,
            dqs.manual_calls AS manual_calls,
            dqs.click_2_calls AS click_2_calls,
            dqs.dial_pad_calls AS dial_pad_calls,
            dqs.call_finalized_by_im AS call_finalized_by_im,
            dqs.abandoned_while_on_preview AS abandoned_while_on_preview,
            dqs.calls_in_queue_not_previewed AS calls_in_queue_not_previewed,
            COALESCE(SEC_TO_TIME(ROUND(((dqs.im_duration / 1000) / NULLIF(dqs.total_calls_to_im, 0)), 0)), SEC_TO_TIME(0)) AS average_im_duration,
            COALESCE(SEC_TO_TIME(ROUND(((dqs.talk_duration / 1000) / NULLIF(dqs.handled_calls, 0)), 0)), SEC_TO_TIME(0)) AS average_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND(((dqs.queue_duration_of_abandoned_calls / 1000) / NULLIF(dqs.calls_abandoned_in_queue, 0)), 0)), SEC_TO_TIME(0)) AS average_time_to_abandoned,
            COALESCE(SEC_TO_TIME(ROUND((dqs.voicemail_duration / 1000), 0)), SEC_TO_TIME(0)) AS average_voicemail_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.handled_duration / 1000), 0)), SEC_TO_TIME(0)) AS handled_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.inbound_handled_duration / 1000), 0)), SEC_TO_TIME(0)) AS inbound_handled_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.outbound_handled_duration / 1000), 0)), SEC_TO_TIME(0)) AS outbound_handled_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.handled_calls_queue_duration / 1000), 0)), SEC_TO_TIME(0)) AS handled_call_queue_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.hold_duration / 1000), 0)), SEC_TO_TIME(0)) AS hold_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.im_duration / 1000), 0)), SEC_TO_TIME(0)) AS total_im_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.queue_duration / 1000), 0)), SEC_TO_TIME(0)) AS queue_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.queue_duration_of_abandoned_calls / 1000), 0)), SEC_TO_TIME(0)) AS total_queue_duration_of_abandoned_calls,
            COALESCE(SEC_TO_TIME(ROUND((dqs.talk_duration / 1000), 0)), SEC_TO_TIME(0)) AS total_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.voicemail_duration / 1000), 0)), SEC_TO_TIME(0)) AS total_voicemail_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.wrapup_duration / 1000), 0)), SEC_TO_TIME(0)) AS total_wrapup_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.transfer_duration / 1000), 0)), SEC_TO_TIME(0)) AS transfer_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.im_customer_hangup_duration / 1000), 0)), SEC_TO_TIME(0)) AS im_customer_hangup_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.preview_duration / 1000), 0)), SEC_TO_TIME(0)) AS preview_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.courtesy_call_back_wait_time / 1000), 0)), SEC_TO_TIME(0)) AS courtesy_callback_wait_time,
            COALESCE(SEC_TO_TIME(ROUND((dqs.internal_transfer_talk_time / 1000), 0)), SEC_TO_TIME(0)) AS internal_transfer_talk_duration,
            COALESCE(SEC_TO_TIME(ROUND((dqs.external_transfer_talk_time / 1000), 0)), SEC_TO_TIME(0)) AS external_transfer_talk_duration,
            dqs.answered_after_threshold AS sla_answered_after,
            dqs.answered_before_threshold AS sla_answered_before,
            dqs.abandoned_after_threshold AS sla_abandoned_after,
            dqs.abandoned_before_threshold AS sla_abandoned_before,
            ((dqs.answered_before_threshold / NULLIF(((dqs.answered_after_threshold + dqs.answered_before_threshold) + dqs.abandoned_after_threshold + dqs.abandoned_before_threshold), 0)) * 100) AS sla_service_level_percent,
            ((dqs.answered_before_threshold / NULLIF((dqs.total_calls_to_queue - dqs.calls_abandoned_in_queue), 0)) * 100) AS sla_service_level_wo_abandoned,
            COALESCE(SEC_TO_TIME(ROUND(((dqs.handled_calls_queue_duration / 1000) / NULLIF(dqs.inbound_handled_calls, 0)), 0)), SEC_TO_TIME(0)) AS speed_of_answer,
            dqs.cold_transfer AS transfer_cold,
            dqs.warm_transfer AS transfer_warm,
            dqs.transfer_rejected AS transfer_rejected,
            dqs.transfer_auto_rejected AS transfer_auto_rejected,
            dqs.transfer_manually_rejected AS transfer_manual_rejected,
            (dqs.external_transfer_by_user + dqs.internal_transfer_by_user) AS transfer_total_user_transfers,
            dqs.external_transfer_by_user AS transfers_total_external_transferred_via_agent,
            dqs.external_transfer_by_queue AS transfers_total_external_transferred_via_queue,
            dqs.external_transfer_by_im AS transfers_total_external_transferred_via_im,
            dqs.internal_transfer_by_user AS transfers_internal_transferred_via_agent,
            dqs.internal_transfer_by_queue AS transfers_internal_transferred_via_queue,
            dqs.im_transfer_initiated AS im_transfer_initiated,
            dqs.im_transfer_accepted AS im_transfer_accepted,
            dqs.queue_transfer_initiated AS queue_transfer_initiated,
            dqs.queue_transfer_accepted AS queue_transfer_accepted,
            dqs.agent_transfer_initiated AS agent_transfer_initiated,
            dqs.agent_transfer_accepted AS agent_transfer_accepted,
            dqs.updated_on AS update_time
        FROM
            rep_94.dnis_queue_summary dqs
            LEFT JOIN rep_94.queue q ON dqs.queue_id = q.id
            LEFT JOIN rep_94.flow f ON dqs.flow_id = f.id
        WHERE
            dqs.updated_on BETWEEN ? AND ?
        ORDER BY dqs.updated_on ', p_sort_direction, '
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