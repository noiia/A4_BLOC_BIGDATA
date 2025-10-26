MERGE INTO datawarehouse."default".patient t
USING (
  SELECT
    CAST(id_patient AS INTEGER)                             AS id,
    CASE
      WHEN lower(trim(sexe)) = 'female' THEN 'F'
      WHEN lower(trim(sexe)) = 'male'   THEN 'M'
      ELSE NULLIF(trim(sexe), '')
    END                                                     AS sexe,
    parse_date_us(date)                                     AS date_naissance
  FROM datalake.public.patient
  WHERE id_patient IS NOT NULL
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET
  sexe = s.sexe,
  date_naissance = s.date_naissance
WHEN NOT MATCHED THEN INSERT (id, sexe, date_naissance)
VALUES (s.id, s.sexe, s.date_naissance);
