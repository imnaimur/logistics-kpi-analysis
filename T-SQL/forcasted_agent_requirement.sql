WITH current_agents AS (
	SELECT h.hub_name,
	 COUNT(
		CASE WHEN ag.active_status = 'Active' AND ag.salary_type ='Fixed'
			THEN 1 END) AS current_fix_agents,
				 COUNT(
		CASE WHEN ag.active_status = 'Active' AND ag.salary_type ='Variable'
			THEN 1 END) AS current_var_agents
	FROM dbo.hubs h
	left join dbo.agents ag
	on h.hub_id = ag.hub_id
	group by h.hub_name
),
total_orders AS(
SELECT h.hub_name,
sum(vf.expected_orders) as total_orders
from dbo.volume_forecast vf
LEFT JOIN dbo.hubs h
on vf.hub_id = h.hub_id
group by h.hub_name
)
select ca.hub_name,ca.current_var_agents,
	((t.total_orders - ca.current_fix_agents *5*4*40) / (7*4*40)) as required_var_agents
	from current_agents ca
	LEFT JOIN total_orders t
	ON ca.hub_name = t.hub_name
