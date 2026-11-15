WITH agent_returns AS (
    SELECT
        ag.agent_id,
        ag.agent_name,
        h.hub_name,
        ag.joining_date,
        DATE '2026-10-26' - ag.joining_date AS tenure,
        COUNT(*) FILTER (
            WHERE ol.status = 'Assigned'
        ) AS attempts,
        COUNT(*) FILTER (
            WHERE ol.status = 'Returned'
        ) AS returned
    FROM agents ag
    INNER JOIN order_logs ol
        ON ag.agent_id = ol.agent_id
    INNER JOIN hubs h
        ON ag.hub_id = h.hub_id
    GROUP BY
        ag.agent_id,
        ag.agent_name,
        h.hub_name,
        ag.joining_date
)

SELECT
    agent_id,
    agent_name,
    hub_name,
    joining_date,
    tenure,
    attempts,
    returned,
    ROUND(returned * 100.0 / attempts, 1) AS return_ratio_pct
FROM agent_returns
WHERE tenure > 30
  AND returned * 100.0 / attempts > 15
ORDER BY return_ratio_pct;