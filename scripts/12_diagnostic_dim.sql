MERGE INTO datawarehouse."default".diagnostic_dim t
USING (
  SELECT DISTINCT
    clean_str(code_diag) AS code,
    NULLIF(trim(diagnostic), '') AS libelle
  FROM datalake.public.diagnostic
  WHERE code_diag IS NOT NULL AND trim(code_diag) <> ''
) s
ON t.code = s.code
WHEN MATCHED THEN UPDATE SET libelle = COALESCE(s.libelle, t.libelle)
WHEN NOT MATCHED THEN INSERT (code, libelle) VALUES (s.code, s.libelle);