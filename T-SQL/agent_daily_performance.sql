WITH agent_performance  AS(
	SELECT 
		ag.agent_id,
		ag.agent_name,
		COUNT(
			CASE
				WHEN ol.status = 'Assigned'
					THEN 1 END) AS Assigned,
		COUNT(
			CASE 
				WHEN ol.status = 'Delivered'
					THEN 1 END) AS Delivered,
		COUNT(
			CASE 
				WHEN ol.status = 'Hold'
					THEN 1 END) AS Hold,
		COUNT(
			CASE
				WHEN ol.status = 'Returned'
					THEN 1 END) AS Returned

	FROM dbo.agents ag
	LEFT JOIN dbo.order_logs ol
	ON ag.agent_id = ol.agent_id
	GROUP BY ag.agent_id,ag.agent_name
)

select * from agent_performance;