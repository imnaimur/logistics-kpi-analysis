WITH w1_performance AS(
	SELECT
		h.hub_name,
		COUNT(ol.attempt_no) as w1_attempt,
		COUNT(
			CASE
				WHEN ol.status='Delivered'
				THEN 1 END) AS w1_delivered
		FROM dbo.hubs h
		LEFT JOIN dbo.agents ag
		ON h.hub_id = ag.hub_id
		LEFT JOIN dbo.order_logs ol
		ON ag.agent_id = ol.agent_id
		WHERE TRY_CONVERT(date,ol.event_time) 
			BETWEEN TRY_CONVERT(DATE,'2026-10-17') AND TRY_CONVERT(DATE,'2026-10-19')
		group by h.hub_name
),
w2_performace AS(
	SELECT 
		h.hub_name,
		COUNT(ol.attempt_no) as w2_attempt,
		COUNT(
			CASE
				WHEN ol.status ='Delivered'
				THEN 1 END) AS w2_delivered
		FROM dbo.hubs h
		LEFT JOIN dbo.agents ag
		ON h.hub_id = ag.hub_id
		LEFT JOIN dbo.order_logs ol
		ON ag.agent_id = ol.agent_id
		WHERE TRY_CONVERT(DATE,ol.event_time) 
		BETWEEN TRY_CONVERT(DATE,'2026-10-20') AND TRY_CONVERT(DATE,'2026-10-26')
		GROUP BY h.hub_name
),
utilization AS(
	SELECT w1.hub_name,
	w1.w1_attempt,
	CAST(
	(
	((w1.w1_delivered*1.0)/ NULLIF (w1.w1_attempt,0))*100
	) AS DECIMAL(10,2)) AS w1_utilization,
	w2.w2_attempt,
	CAST(
	(
	((w2.w2_delivered*1.0)/ NULLIF(w2.w2_attempt,0))*100
	) AS DECIMAL(10,2)) AS w2_utilization
	FROM w1_performance w1
	LEFT JOIN w2_performace w2
	ON w1.hub_name = w2.hub_name
)
select * from utilization