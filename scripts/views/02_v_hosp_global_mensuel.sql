CREATE OR REPLACE VIEW datawarehouse."default".v_hosp_global_mensuel AS
SELECT
  date_trunc('month', date_entree) AS mois,
  COUNT(*) AS nb_hosp
FROM datawarehouse."default".hospitalisations
GROUP BY 1
ORDER BY 1;
