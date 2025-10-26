MERGE INTO datawarehouse."default".region_dim t
USING (
  SELECT
    CAST(reg AS INTEGER) AS id,
    nccenr               AS nom  -- libellé long “écriture entière”
  FROM datalake.public.insee_regions_2019
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET nom = s.nom
WHEN NOT MATCHED THEN INSERT (id, nom) VALUES (s.id, s.nom);
