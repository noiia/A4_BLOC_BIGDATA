CREATE OR REPLACE VIEW datawarehouse."default".v_consultation_hospitalisation AS
SELECT
  c.id            AS id_consultation,
  h.id            AS id_hospitalisation,
  c.id_patient,
  h.id_etablissement,
  c.ts_debut,
  c.ts_fin,
  h.date_entree,
  h.date_sortie
FROM datawarehouse."default".consultation    c
JOIN datawarehouse."default".hospitalisations h
  ON h.id_patient = c.id_patient
 -- chevauchement (sur les dates)
WHERE
  c.ts_debut <= CAST(date_add('day', 1, h.date_sortie) AS TIMESTAMP) -- <= fin de journée de sortie
  AND
  c.ts_fin   >= CAST(h.date_entree AS TIMESTAMP);                    -- >= début de journée d'entrée
