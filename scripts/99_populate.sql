-- Populate adresse_dim with id_region from insee_commmunes_2019
MERGE INTO datawarehouse."default".adresse_dim a
USING (
  SELECT
    TRIM(com) AS com,
    TRY_CAST(NULLIF(TRIM(reg), '') AS INTEGER) AS id_region
  FROM datalake.public.insee_commmunes_2019
  WHERE com IS NOT NULL AND TRIM(com) <> ''
    AND reg IS NOT NULL AND TRIM(reg) <> ''
) r
ON  a.id_region IS NULL
AND a.code_postal IS NOT NULL AND TRIM(a.code_postal) <> ''
AND a.code_postal = r.com
WHEN MATCHED THEN UPDATE SET
  id_region = r.id_region;