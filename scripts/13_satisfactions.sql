CREATE OR REPLACE function generate_int_id(field1 double, field2 varchar)
RETURNS BIGINT
return from_big_endian_64(
		  xxhash64(
		    to_utf8(
		      array_join(
		        ARRAY[
          		  coalesce(cast(field1 as varchar) , ''),
                  coalesce(field2, '')
          		  ],
          		  '|'
          		  )
      		  )
  		  )
	  )
	  
CREATE OR REPLACE FUNCTION gen_region_id(region VARCHAR)
	RETURNS BIGINT
	RETURN from_big_endian_64(
  	  xxhash64(
    	to_utf8(coalesce(clean_str(region), ''))
  	  )
	)
	

INSERT INTO datawarehouse."default".satisfaction (id, score_global, id_etablissement)
SELECT 
    generate_int_id(score_all_rea_ajust, finess) AS id,
    CAST(score_all_rea_ajust AS integer) AS score_global,
    finess  AS id_etablissement
FROM datalake.public."resultats-esatis48h-mco-open-data-2020";

INSERT INTO datawarehouse."default".satisfaction (id, score_global, id_etablissement)
SELECT 
    generate_int_id(score_all_ajust, finess) AS id,
    CAST(score_all_ajust AS integer) AS score_global,
    finess AS id_etablissement
FROM datalake.public."resultats-esatisca-mco-open-data-2020";

INSERT INTO datawarehouse."default".satisfaction (id, score_global, id_etablissement)
WITH computed AS (
    SELECT
        CAST(
            (
                TRY_CAST(ete_ortho_ratio_oe AS double) +
                TRY_CAST(iso_ortho_ratio_oe AS double)
            ) / 2
            AS integer
        ) AS score_global,
        finess
    FROM datalake.public."resultats-iqss-open-data-2020"
)
SELECT
    generate_int_id(score_global, finess) AS id,
    score_global,
    finess AS id_etablissement
FROM computed

ALTER TABLE datawarehouse."default".region_dim
ALTER COLUMN id SET DATA TYPE BIGINT;

ALTER TABLE datawarehouse."default".note_a
ALTER COLUMN id_region SET DATA TYPE BIGINT;

ALTER TABLE datawarehouse."default".note_a
ALTER COLUMN id_satisfaction SET DATA TYPE BIGINT

MERGE INTO datawarehouse."default".region_dim t
USING (
  SELECT DISTINCT
    clean_str(region)      AS nom,
    gen_region_id(region)    AS id
  FROM datalake.public."resultats-esatis48h-mco-open-data-2020"
  WHERE region IS NOT NULL AND trim(region) <> ''
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET nom = s.nom
WHEN NOT MATCHED THEN INSERT (id, nom) VALUES (s.id, s.nom);

MERGE INTO datawarehouse."default".region_dim t
USING (
  SELECT DISTINCT
    clean_str(region)      AS nom,
    gen_region_id(region)    AS id
  FROM datalake.public."resultats-esatisca-mco-open-data-2020"
  WHERE region IS NOT NULL AND trim(region) <> ''
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET nom = s.nom
WHEN NOT MATCHED THEN INSERT (id, nom) VALUES (s.id, s.nom);

MERGE INTO datawarehouse."default".region_dim t
USING (
  SELECT DISTINCT
    clean_str(region)      AS nom,
    gen_region_id(region)    AS id
  FROM datalake.public."resultats-iqss-open-data-2020"
  WHERE region IS NOT NULL AND trim(region) <> ''
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET nom = s.nom
WHEN NOT MATCHED THEN INSERT (id, nom) VALUES (s.id, s.nom);

INSERT INTO datawarehouse."default".note_a (id_region, id_satisfaction)
SELECT
    gen_region_id(region) AS id_region,
    generate_int_id(score_all_rea_ajust, finess) AS id_satisfaction
FROM datalake.public."resultats-esatis48h-mco-open-data-2020";

INSERT INTO datawarehouse."default".note_a (id_region, id_satisfaction)
SELECT
    gen_region_id(region) AS id_region,
    generate_int_id(score_all_ajust, finess) AS id_satisfaction
FROM datalake.public."resultats-esatisca-mco-open-data-2020"

INSERT INTO datawarehouse."default".note_a (id_region, id_satisfaction)
WITH computed AS (
    SELECT
        CAST(
            (
                TRY_CAST(ete_ortho_ratio_oe AS double) +
                TRY_CAST(iso_ortho_ratio_oe AS double)
            ) / 2
            AS integer
        ) AS score_global,
        finess,
        region
    FROM datalake.public."resultats-iqss-open-data-2020"
)
SELECT
    gen_region_id(region) AS id_region,
    generate_int_id(score_global, finess) AS id_satisfaction
FROM computed