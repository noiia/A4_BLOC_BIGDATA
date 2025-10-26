MERGE INTO datawarehouse."default".adresse_dim t
USING (
  WITH
  -- on restreint le scan aux lignes 2019 (filtre cheap côté source)
  src_2019 AS (
    SELECT *
    FROM datalake.public.deces
    WHERE date_deces LIKE '2019%'
  ),
  adresses_naissance AS (
    SELECT
      NULLIF(trim(lieu_naissance), '')       AS commune,
      NULLIF(trim(code_lieu_naissance), '')  AS code_postal
    FROM src_2019
    WHERE (lieu_naissance IS NOT NULL AND trim(lieu_naissance) <> '')
       OR (code_lieu_naissance IS NOT NULL AND trim(code_lieu_naissance) <> '')
  ),
  adresses_deces AS (
    SELECT
      CAST(NULL AS VARCHAR)                  AS commune,
      NULLIF(trim(code_lieu_deces), '')      AS code_postal
    FROM src_2019
    WHERE code_lieu_deces IS NOT NULL AND trim(code_lieu_deces) <> ''
  ),
  union_all AS (
    SELECT commune, code_postal FROM adresses_naissance
    UNION ALL
    SELECT commune, code_postal FROM adresses_deces
  ),
  dedup AS (
    SELECT DISTINCT commune, code_postal
    FROM union_all
    WHERE commune IS NOT NULL OR code_postal IS NOT NULL
  )
  SELECT
    gen_adresse_id(
      NULL, NULL, NULL,
      commune,               -- commune (peut être NULL côté décès)
      code_postal,           -- code INSEE/CP selon ce que tu as
      NULL, NULL
    ) AS id,
    commune,
    code_postal,
    NULL AS nom_voie,
    NULL AS numero_voie,
    NULL AS complement_adresse,
    NULL AS type_voie,
    NULL AS indice_repetition_voie
  FROM dedup
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET
  commune                = COALESCE(t.commune, s.commune),
  code_postal            = COALESCE(t.code_postal, s.code_postal),
  nom_voie               = COALESCE(t.nom_voie, s.nom_voie),
  numero_voie            = COALESCE(t.numero_voie, s.numero_voie),
  complement_adresse     = COALESCE(t.complement_adresse, s.complement_adresse),
  type_voie              = COALESCE(t.type_voie, s.type_voie),
  indice_repetition_voie = COALESCE(t.indice_repetition_voie, s.indice_repetition_voie)
WHEN NOT MATCHED THEN INSERT (
  id, commune, code_postal, nom_voie, numero_voie, complement_adresse, type_voie, indice_repetition_voie
) VALUES (
  s.id, s.commune, s.code_postal, s.nom_voie, s.numero_voie, s.complement_adresse, s.type_voie, s.indice_repetition_voie
);






 