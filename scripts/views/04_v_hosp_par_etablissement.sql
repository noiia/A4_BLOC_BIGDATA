CREATE OR REPLACE VIEW datawarehouse."default".v_hosp_par_etablissement AS
SELECT
  date_trunc('month', h.date_entree) AS mois,
  COALESCE(e.raison_sociale_site, h.id_etablissement) AS etablissement,
  COUNT(*) AS nb_hosp
FROM datawarehouse."default".hospitalisations h
LEFT JOIN datawarehouse."default".etablissement_sante e
  ON e.id = h.id_etablissement
GROUP BY 1,2
ORDER BY 1,3 DESC;
