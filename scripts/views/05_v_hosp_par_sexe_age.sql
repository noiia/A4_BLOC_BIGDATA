CREATE OR REPLACE VIEW datawarehouse."default".v_hosp_par_sexe_age AS
WITH ages AS (
  SELECT
    h.*,
    p.sexe,
    date_diff('year', p.date_naissance, h.date_entree) AS age
  FROM datawarehouse."default".hospitalisations h
  LEFT JOIN datawarehouse."default".patient p
    ON p.id = h.id_patient
)
SELECT
  date_trunc('month', date_entree) AS mois,
  COALESCE(sexe, 'NA') AS sexe,
  CASE
    WHEN age < 18  THEN '0-17'
    WHEN age < 30  THEN '18-29'
    WHEN age < 45  THEN '30-44'
    WHEN age < 60  THEN '45-59'
    WHEN age < 75  THEN '60-74'
    WHEN age < 90  THEN '75-89'
    WHEN age IS NULL THEN 'NA'
    ELSE '90+'
  END AS tranche_age,
  COUNT(*) AS nb_hosp
FROM ages
GROUP BY 1,2,3
ORDER BY 1,2,3;
