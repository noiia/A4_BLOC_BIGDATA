MERGE INTO datawarehouse."default".consultation t
USING (
  SELECT
    CAST(num_consultation AS BIGINT)          AS id,
    CAST(id_patient AS INTEGER)               AS id_patient,
    NULLIF(trim(id_prof_sante), '')           AS id_prof_sante,
    NULLIF(trim(code_diag), '')               AS code_diagnostic,

    -- concat 'YYYY-MM-DD HH:MM:SS' puis cast → TIMESTAMP
    CAST(format('%s %s', CAST("date" AS VARCHAR), CAST(heure_debut AS VARCHAR)) AS TIMESTAMP) AS ts_debut,
    CAST(format('%s %s', CAST("date" AS VARCHAR), CAST(heure_fin   AS VARCHAR)) AS TIMESTAMP) AS ts_fin

  FROM datalake.public.consultation
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET
  id_patient      = s.id_patient,
  id_prof_sante   = s.id_prof_sante,
  code_diagnostic = s.code_diagnostic,
  ts_debut        = s.ts_debut,
  ts_fin          = s.ts_fin
WHEN NOT MATCHED THEN INSERT (id, id_patient, id_prof_sante, code_diagnostic, ts_debut, ts_fin)
VALUES (s.id, s.id_patient, s.id_prof_sante, s.code_diagnostic, s.ts_debut, s.ts_fin);
