MERGE INTO datawarehouse."default".professionel_sante t
USING (
  WITH a AS (
    SELECT
      NULLIF(trim(identifiant), '')             AS id,
      clean_str(civilite)                       AS civilite,
      clean_str(categorie_professionnelle)      AS categorie_professionnelle,
      clean_str(profession)                     AS profession,
      clean_str(code_specialite)                AS specialite
    FROM datalake.public.professionnel_de_sante
    WHERE identifiant IS NOT NULL AND trim(identifiant) <> ''
  ),
  b AS (
    SELECT
      NULLIF(trim(identifiant), '')             AS id,
      clean_str(civilite)                       AS civilite,
      clean_str(categorie_professionnelle)      AS categorie_professionnelle,
      clean_str(profession)                     AS profession,
      clean_str(specialite)                     AS specialite
    FROM datalake.public.professionnel_sante_csv
    WHERE identifiant IS NOT NULL AND trim(identifiant) <> ''
  ),
  unioned AS (
    SELECT * FROM a
    UNION ALL
    SELECT * FROM b
  ),
  prefer AS (
    -- si doublons sur le même id, on prend une ligne arbitraire (les champs sont identiques/compatibles)
    SELECT id,
           arbitrary(civilite)                  AS civilite,
           arbitrary(categorie_professionnelle) AS categorie_professionnelle,
           arbitrary(profession)                AS profession,
           arbitrary(specialite)                AS specialite
    FROM unioned
    GROUP BY id
  )
  SELECT * FROM prefer
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET
  civilite = s.civilite,
  categorie_professionnelle = s.categorie_professionnelle,
  profession = s.profession,
  specialite = s.specialite
WHEN NOT MATCHED THEN INSERT (id, civilite, categorie_professionnelle, profession, specialite)
VALUES (s.id, s.civilite, s.categorie_professionnelle, s.profession, s.specialite);
