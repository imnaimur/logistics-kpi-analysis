WITH w1_order AS(
	SELECT 
		h.hub_name,
		COUNT(
			CASE
				WHEN o.final_status = 'Delivered'
				THEN 1 END) AS total_delivered
			FROM dbo.orders o
			LEFT JOIN dbo.hubs h
			ON o.hub_id = h.hub_id
			WHERE TRY_CONVERT(DATE,created_at) BETWEEN TRY_CONVERT(DATE,'2026-10-13') AND TRY_CONVERT(DATE,'2026-10-19')
			GROUP BY h.hub_name
),
w1_agent AS (
	SELECT h.hub_name,
	COUNT(
	DISTINCT
		CASE 
			WHEN ag.salary_type = 'Fixed'
			THEN ag.agent_id END) AS fag,	-- fixed agents
		
	COUNT(
	DISTINCT
		CASE 
			WHEN ag.salary_type = 'Variable'
			THEN  ag.agent_id END) AS vag,	-- variable agents
	COUNT(
		CASE 
			WHEN ag.salary_type = 'Variable'
			THEN  1 END) AS vag_order,	
	COUNT(
		DISTINCT
		CASE 
			WHEN ag.salary_type = 'Fixed'
			THEN TRY_CONVERT(DATE,o.created_at) END) AS fag_days,
	COUNT(
		DISTINCT
		CASE 
			WHEN ag.salary_type = 'Variable'
			THEN TRY_CONVERT(DATE,o.created_at) END) AS vag_days
	FROM dbo.orders o
	LEFT JOIN dbo.hubs h
	ON o.hub_id = h.hub_id
	LEFT JOIN dbo.agents ag
	ON h.hub_id = ag.hub_id
	WHERE TRY_CONVERT(DATE,created_at) BETWEEN TRY_CONVERT(DATE,'2026-10-13') AND TRY_CONVERT(DATE,'2026-10-19')
	GROUP BY h.hub_name
),
w1_cost AS (
SELECT hub_name,
	((fag*650*fag_days) + (vag*vag_days*300 + vag_order*14)) AS total_cost
	FROM w1_agent
),
w2_order AS(
	SELECT 
		h.hub_name,
		COUNT(
			CASE
				WHEN o.final_status = 'Delivered'
				THEN 1 END) AS total_delivered
			FROM dbo.orders o
			LEFT JOIN dbo.hubs h
			ON o.hub_id = h.hub_id
			WHERE TRY_CONVERT(DATE,created_at) BETWEEN TRY_CONVERT(DATE,'2026-10-20') AND TRY_CONVERT(DATE,'2026-10-26')
			GROUP BY h.hub_name
),
w2_agent AS (
	SELECT h.hub_name,
	COUNT(
	DISTINCT
		CASE 
			WHEN ag.salary_type = 'Fixed' AND ag.active_status = 'Active'
			THEN ag.agent_id END) AS fag,	-- fixed agents
		
	COUNT(
	DISTINCT
		CASE 
			WHEN ag.salary_type = 'Variable' AND ag.active_status = 'Active'
			THEN  ag.agent_id END) AS vag,	-- variable agents
	COUNT(
		CASE 
			WHEN ag.salary_type = 'Variable' AND ag.active_status = 'Active'
			THEN  1 END) AS vag_order,	
	COUNT(
		DISTINCT
		CASE 
			WHEN ag.salary_type = 'Fixed' AND ag.active_status = 'Active'
			THEN TRY_CONVERT(DATE,o.created_at) END) AS fag_days,
	COUNT(
		DISTINCT
		CASE 
			WHEN ag.salary_type = 'Variable' AND ag.active_status = 'Active'
			THEN TRY_CONVERT(DATE,o.created_at) END) AS vag_days
	FROM dbo.orders o
	LEFT JOIN dbo.hubs h
	ON o.hub_id = h.hub_id
	LEFT JOIN dbo.agents ag
	ON h.hub_id = ag.hub_id
	WHERE TRY_CONVERT(DATE,created_at) BETWEEN TRY_CONVERT(DATE,'2026-10-20') AND TRY_CONVERT(DATE,'2026-10-26')
	GROUP BY h.hub_name
),
w2_cost AS (
SELECT hub_name,
	((fag*650*fag_days) + (vag*vag_days*300 + vag_order*14)) AS total_cost
	FROM w2_agent
)

select w1c.hub_name,
		CAST(((w1c.total_cost*1.0)/w1o.total_delivered) AS DECIMAL(10,2)) AS w1_per_order_cost,
		CAST(((w2c.total_cost*1.0)/w2o.total_delivered) AS DECIMAL(10,2)) AS w2_per_order_cost
 from w1_cost w1c
 LEFT JOIN w1_order w1o
 ON w1c.hub_name = w1o.hub_name
 LEFT JOIN w2_cost w2c
 ON w1o.hub_name = w2C.hub_name
 LEFT JOIN w2_order w2o
 ON w2c.hub_name = w2o.hub_name