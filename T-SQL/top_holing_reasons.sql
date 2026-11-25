SELECT
	h.hub_name,
	ol.hold_reason,
	COUNT(ol.hold_reason) AS reason_count
	FROM dbo.order_logs ol
	LEFT JOIN dbo.agents ag
	ON ol.agent_id = ag.agent_id
	LEFT JOIN dbo.hubs h
	ON ag.hub_id = h.hub_id
	WHERE ol.hold_reason NOT IN('Customer Unreachable','Customer Rescheduled','Address Incomplete')
	GROUP BY ol.hold_reason,h.hub_name
	ORDER BY h.hub_name,reason_count DESC