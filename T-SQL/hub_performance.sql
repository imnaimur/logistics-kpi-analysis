WITH hub_performance AS(
SELECT 
	h.hub_id,
	h.hub_name,
	COUNT(
		CASE
			WHEN ol.status = 'Delivered'
				THEN 1 END) AS delivered,
	COUNT(DISTINCT ag.agent_id) as total_agents,
	COUNT(DISTINCT 
	TRY_CONVERT(date,ol.event_time)) as total_days
FROM dbo.hubs h
LEFT JOIN dbo.agents ag
ON h.hub_id = ag.hub_id
LEFT JOIN dbo.order_logs ol
ON ag.agent_id = ol.agent_id
GROUP BY h.hub_id,h.hub_name
)
SELECT hub_id,hub_id,
	CAST(
	((delivered*1.0)/NULLIF (total_agents,0))/NULLIF (total_days,0)
		AS DECIMAL(10,2)
	) AS deliver_per_agent_per_day
FROM hub_performance