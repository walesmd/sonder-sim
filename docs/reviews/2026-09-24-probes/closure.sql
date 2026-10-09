WITH RECURSIVE anc(id) AS (
  SELECT :war
  UNION
  SELECT c.cause_id FROM causes c JOIN anc ON c.event_id = anc.id
)
SELECT a.location, a.kind, count(*) FROM anc JOIN annals a ON a.id = anc.id GROUP BY a.location, a.kind ORDER BY a.location, a.kind;
