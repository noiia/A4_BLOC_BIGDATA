MERGE INTO datawarehouse."default".travaille_a t
USING (
  SELECT DISTINCT
    norm_org_id(identifiant_organisation) AS id_etablissement,
    NULLIF(trim(identifiant), '')         AS id_pro_sante,
    clean_str(mode_exercice)              AS mode_exercice
  FROM datalake.public.actrivite_professionnel_sante
  WHERE identifiant IS NOT NULL AND trim(identifiant) <> ''
) s
ON t.id_etablissement = s.id_etablissement
AND t.id_pro_sante    = s.id_pro_sante
WHEN MATCHED THEN UPDATE SET
  mode_exercice = s.mode_exercice
WHEN NOT MATCHED THEN INSERT (id_etablissement, id_pro_sante, mode_exercice)
VALUES (s.id_etablissement, s.id_pro_sante, s.mode_exercice);
