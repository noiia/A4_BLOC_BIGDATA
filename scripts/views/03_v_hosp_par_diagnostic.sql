CREATE OR REPLACE VIEW datawarehouse."default".v_hosp_par_diagnostic AS
SELECT
  date_trunc('month', h.date_entree) AS mois,
  h.code_diagnostic,
  COALESCE(d.libelle, '(sans libellé)') AS diagnostic,
  COUNT(*) AS nb_hosp
FROM datawarehouse."default".hospitalisations h
LEFT JOIN datawarehouse."default".diagnostic_dim d
  ON d.code = clean_str(h.code_diagnostic)
GROUP BY 1,2,3
ORDER BY 1,4 DESC;
