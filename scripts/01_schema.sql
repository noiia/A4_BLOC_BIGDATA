-- ================================
-- SCHEMA DATAWAREHOUSE - TRINO + ICEBERG (v2)
-- ================================

-- (Sécurité) Supprimer l'ancienne dimension si elle existe encore
DROP TABLE IF EXISTS datawarehouse."default".date_dim;

-- ---------- Dimensions (faible volume : pas de partitioning) ----------

CREATE TABLE IF NOT EXISTS datawarehouse."default".adresse_dim (
  id                      BIGINT,
  nom_voie                VARCHAR,
  numero_voie             VARCHAR,
  complement_adresse      VARCHAR,
  commune                 VARCHAR,
  code_postal             VARCHAR,
  type_voie               VARCHAR,
  indice_repetition_voie  VARCHAR,
  id_region               INTEGER
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
  );

CREATE TABLE IF NOT EXISTS datawarehouse."default".pays_dim (
  id   BIGINT,
  nom  VARCHAR
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );

CREATE TABLE IF NOT EXISTS datawarehouse."default".region_dim (
  id   INTEGER,
  nom  VARCHAR
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );

CREATE TABLE IF NOT EXISTS datawarehouse."default".professionel_sante (
  id                         VARCHAR,
  civilite                   VARCHAR,
  categorie_professionnelle  VARCHAR,
  profession                 VARCHAR,
  specialite                 VARCHAR
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );

CREATE TABLE IF NOT EXISTS datawarehouse."default".etablissement_sante (
  id                  VARCHAR,
  raison_sociale_site VARCHAR,
  id_adresse          BIGINT,
  id_pays             BIGINT,
  finess              INTEGER
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );
-- ---------- Faits / liens (DATES NATIVES + partitioning utile) ----------

-- Fait décès : dates natives, pruning mensuel, équilibrage par lieu
CREATE TABLE IF NOT EXISTS datawarehouse."default".deces (
  id                 INTEGER,
  sexe               VARCHAR,
  id_lieu_naissance  BIGINT,
  id_lieu_deces      BIGINT,
  date_naissance     DATE,
  date_mort          DATE
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );

-- Patient : date de naissance native
CREATE TABLE IF NOT EXISTS datawarehouse."default".patient (
  id               INTEGER,
  sexe             VARCHAR,
  date_naissance   DATE
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );

-- Hospitalisations : dates natives, pruning sur date_entree, équilibrage par établissement
CREATE TABLE IF NOT EXISTS datawarehouse."default".hospitalisations (
  id                VARCHAR,
  code_diagnostic   VARCHAR,
  date_entree       DATE,
  date_sortie       DATE,
  id_patient        INTEGER,
  id_etablissement  VARCHAR
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );

-- Consultations
CREATE TABLE IF NOT EXISTS datawarehouse."default".consultation (
  id                BIGINT,          -- num_consultation
  id_patient        INTEGER,
  id_prof_sante     VARCHAR,
  code_diagnostic   VARCHAR,
  ts_debut          TIMESTAMP,
  ts_fin            TIMESTAMP
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );

CREATE TABLE IF NOT EXISTS datawarehouse."default".diagnostic_dim (
  code    VARCHAR,   -- ex. 'S02800'
  libelle VARCHAR    -- ex. 'Traumatisme...'
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['code'],
    bucket_count = 8
    );

-- Satisfaction / Note_a : faible volume
CREATE TABLE IF NOT EXISTS datawarehouse."default".satisfaction (
  id               BIGINT,
  score_global     INTEGER,
  id_etablissement VARCHAR
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id'],
    bucket_count = 8
    );

CREATE TABLE IF NOT EXISTS datawarehouse."default".note_a (
  id_region        INTEGER,
  id_satisfaction  INTEGER
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id_region'],
    bucket_count = 8
    );

-- Relation de travail (faible volume)
CREATE TABLE IF NOT EXISTS datawarehouse."default".travaille_a (
  id_etablissement  VARCHAR,
  id_pro_sante      VARCHAR,
  mode_exercice     VARCHAR
)
WITH (
    format_version = 2,
    bucketed_by = ARRAY['id_etablissement'],
    bucket_count = 8
    );