INSERT INTO datawarehouse."default".professionel_sante  (id, civilite, categorie_professionnelle, profession, specialite)
SELECT
  dl_pro.identifiant,
  dl_pro.civilite,
  dl_pro.categorie_professionnelle,
  dl_pro.profession,
  dl_spe.specialite
FROM (
    SELECT DISTINCT
        identifiant,
        civilite,
        categorie_professionnelle,
        profession,
        code_specialite
    FROM datalake."public".professionnel_de_sante 
) dl_pro
LEFT JOIN datalake."public".specialites dl_spe
    ON dl_pro.code_specialite = dl_spe.code_specialite
WHERE NOT EXISTS (
    SELECT 1
    FROM datawarehouse."default".professionel_sante dw_pro
    WHERE dw_pro.id = dl_pro.identifiant
);

INSERT INTO datawarehouse."default".professionel_sante  (id, civilite, categorie_professionnelle, profession, specialite)
SELECT
  dl_pro.identifiant,
  dl_pro.civilite,
  dl_pro.categorie_professionnelle,
  dl_pro.profession,
  dl_pro.specialite
FROM (
    SELECT DISTINCT
        identifiant,
        civilite,
        categorie_professionnelle,
        profession,
        specialite
    FROM datalake."public".professionnel_sante_csv 
) dl_pro
WHERE NOT EXISTS (
    SELECT 1
    FROM datawarehouse."default".professionel_sante dw_pro
    WHERE dw_pro.id = dl_pro.identifiant
);


INSERT INTO datawarehouse."default".travaille_a (id, id_etablissement, id_pro_sante, mode_exercice)
SELECT s.id, s.id_etablissement, s.id_pro_sante, s.mode_exercice
FROM (
    SELECT
        xxhash64(to_utf8(concat_ws('|',
            coalesce(identifiant, ''),
            coalesce(identifiant_organisation, ''),
            coalesce(mode_exercice, '')
        ))) AS id,
        identifiant AS id_etablissement,
        identifiant_organisation AS id_pro_sante,
        mode_exercice
    FROM datalake."public".actrivite_professionnel_sante
) s
LEFT JOIN datawarehouse."default".travaille_a t
    ON s.id = t.id
WHERE t.id IS NULL;

