MERGE INTO datawarehouse."default".pays_dim t
USING (
  SELECT DISTINCT
    clean_str(pays)      AS nom,
    gen_pays_id(pays)    AS id
  FROM datalake.public.etablissement_sante
  WHERE pays IS NOT NULL AND trim(pays) <> ''
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET nom = s.nom
WHEN NOT MATCHED THEN INSERT (id, nom) VALUES (s.id, s.nom);





MERGE INTO datawarehouse."default".adresse_dim t
USING (
  WITH raw AS (
    SELECT
      commune,
      code_postal,
      voie             AS nom_voie,
      numero_voie,
      type_voie,
      indice_repetition_voie
    FROM datalake.public.etablissement_sante
  ),
  -- 1) normalise comme le fait gen_adresse_id (trim/upper/espaces)
  norm AS (
    SELECT
      clean_str(commune)                AS commune,
      clean_str(code_postal)            AS code_postal,
      clean_str(nom_voie)               AS nom_voie,
      clean_str(numero_voie)            AS numero_voie,
      clean_str(type_voie)              AS type_voie,
      clean_str(indice_repetition_voie) AS indice_repetition_voie
    FROM raw
  ),
  -- 2) remplace les vides par NULL, et ne garde que (commune OR code_postal)
  filt AS (
    SELECT
      NULLIF(commune, '')                AS commune,
      NULLIF(code_postal, '')            AS code_postal,
      NULLIF(nom_voie, '')               AS nom_voie,
      NULLIF(numero_voie, '')            AS numero_voie,
      NULLIF(type_voie, '')              AS type_voie,
      NULLIF(indice_repetition_voie, '') AS indice_repetition_voie
    FROM norm
    WHERE commune IS NOT NULL OR code_postal IS NOT NULL
  ),
  -- 3) calcule l'id et regroupe par id pour garantir l'unicité
  keyed AS (
    SELECT
      gen_adresse_id(nom_voie, numero_voie, NULL, commune, code_postal, type_voie, indice_repetition_voie) AS id,
      commune, code_postal, nom_voie, numero_voie, type_voie, indice_repetition_voie
    FROM filt
  ),
  one_row_per_id AS (
    SELECT
      id,
      arbitrary(commune)                AS commune,
      arbitrary(code_postal)            AS code_postal,
      arbitrary(nom_voie)               AS nom_voie,
      arbitrary(numero_voie)            AS numero_voie,
      arbitrary(type_voie)              AS type_voie,
      arbitrary(indice_repetition_voie) AS indice_repetition_voie
    FROM keyed
    GROUP BY id
  )
  SELECT
    id,
    nom_voie,
    numero_voie,
    NULL AS complement_adresse,
    commune,
    code_postal,
    type_voie,
    indice_repetition_voie
  FROM one_row_per_id
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
  id, nom_voie, numero_voie, complement_adresse, commune, code_postal, type_voie, indice_repetition_voie
) VALUES (
  s.id, s.nom_voie, s.numero_voie, s.complement_adresse, s.commune, s.code_postal, s.type_voie, s.indice_repetition_voie
);




MERGE INTO datawarehouse."default".etablissement_sante t
USING (
  SELECT
    norm_org_id(identifiant_organisation) AS id,         -- 👈 clé = identifiant_organisation
    clean_str(raison_sociale_site)        AS raison_sociale_site,
    gen_adresse_id(                       -- FK adresse, inchangé
      NULLIF(trim(voie), ''),             -- nom_voie
      NULLIF(trim(numero_voie), ''),      -- numero_voie
      NULL,                               -- complement_adresse (absent)
      NULLIF(trim(commune), ''),          -- commune
      NULLIF(trim(code_postal), ''),      -- code_postal
      NULLIF(trim(type_voie), ''),        -- type_voie
      NULLIF(trim(indice_repetition_voie), '')
    ) AS id_adresse,
    gen_pays_id(pays)                     AS id_pays,
    finess_etablissement_juridique		  as finess
  FROM datalake.public.etablissement_sante
  WHERE identifiant_organisation IS NOT NULL AND trim(identifiant_organisation) <> ''
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET
  raison_sociale_site = s.raison_sociale_site,
  id_adresse          = s.id_adresse,
  id_pays             = s.id_pays,
  finess			  = s.finess
WHEN NOT MATCHED THEN INSERT (id, raison_sociale_site, id_adresse, id_pays, finess)
VALUES (s.id, s.raison_sociale_site, s.id_adresse, s.id_pays, s.finess)
