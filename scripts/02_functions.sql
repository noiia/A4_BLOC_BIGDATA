CREATE OR REPLACE FUNCTION parse_date(d VARCHAR)
RETURNS DATE
RETURN CASE
  WHEN d IS NULL OR trim(d) = ''                  THEN NULL
  WHEN regexp_like(d, '^\d{4}-\d{2}-\d{2}$')      THEN try(CAST(d AS DATE))
  WHEN regexp_like(d, '^\d{4}-\d{2}$')            THEN try(CAST(concat(d,'-01') AS DATE))
  WHEN regexp_like(d, '^\d{4}$')                  THEN try(CAST(concat(d,'-01-01') AS DATE))
  ELSE try(CAST(d AS DATE))
END;

CREATE OR REPLACE FUNCTION clean_str(s VARCHAR)
RETURNS VARCHAR
RETURN
  CASE
    WHEN s IS NULL THEN NULL
    ELSE
      -- enchaînement : trim -> upper -> espaces multiples -> simple espace
      regexp_replace(upper(trim(s)), '\s+', ' ')
  END;

CREATE OR REPLACE FUNCTION gen_adresse_id(
  nom_voie               VARCHAR,
  numero_voie            VARCHAR,
  complement_adresse     VARCHAR,
  commune                VARCHAR,
  code_postal            VARCHAR,
  type_voie              VARCHAR,
  indice_repetition_voie VARCHAR
)
RETURNS BIGINT
RETURN from_big_endian_64(
  xxhash64(
    to_utf8(
      array_join(
        ARRAY[
          coalesce(clean_str(nom_voie),               ''),
          coalesce(clean_str(numero_voie),            ''),
          coalesce(clean_str(complement_adresse),     ''),
          coalesce(clean_str(commune),                ''),
          coalesce(clean_str(code_postal),            ''),
          coalesce(clean_str(type_voie),              ''),
          coalesce(clean_str(indice_repetition_voie), '')
        ],
        '|'
      )
    )
  )
);

CREATE OR REPLACE FUNCTION gen_pays_id(pays VARCHAR)
RETURNS BIGINT
RETURN from_big_endian_64(
  xxhash64(
    to_utf8(coalesce(clean_str(pays), ''))
  )
);

-- dd/mm/yyyy  (ex: 27/09/2017)
CREATE OR REPLACE FUNCTION parse_date_fr(d VARCHAR)
RETURNS DATE
RETURN CASE
  WHEN d IS NULL OR trim(d) = '' THEN NULL
  WHEN regexp_like(d, '^\d{2}/\d{2}/\d{4}$')
    THEN TRY(CAST(date_parse(d, '%d/%m/%Y') AS DATE))   -- <- cast en DATE
  ELSE NULL
END;

-- mm/dd/yyyy  (ex: 10/18/1957, 7/25/2013, 4/6/1980)
CREATE OR REPLACE FUNCTION parse_date_us(d VARCHAR)
RETURNS DATE
RETURN CASE
  WHEN d IS NULL OR trim(d) = '' THEN NULL
  WHEN regexp_like(d, '^\d{1,2}/\d{1,2}/\d{4}$')
    THEN TRY(CAST(date_parse(d, '%m/%d/%Y') AS DATE))   -- <- cast en DATE
  ELSE NULL
END;

CREATE OR REPLACE FUNCTION norm_org_id(s VARCHAR)
RETURNS VARCHAR
RETURN NULLIF(clean_str(s), '');
