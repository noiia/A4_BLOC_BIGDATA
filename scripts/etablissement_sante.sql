INSERT INTO datawarehouse."default".adresse_dim (
    id,
    nom_voie,
    numero_voie,
    complement_adresse,
    commune,
    code_postal,
    type_voie,
    indice_repetition_voie
)
SELECT
    xxhash64(
        to_utf8(concat_ws('|',
            coalesce(a.voie, ''),
            coalesce(a.numero_voie, ''),
            '',
            coalesce(a.commune, ''),
            coalesce(a.code_postal, ''),
            coalesce(a.type_voie, ''),
            coalesce(a.indice_repetition_voie, '')
        ))
    ) AS id,
    a.voie AS nom_voie,
    a.numero_voie,
    '' AS complement_adresse,
    a.commune,
    a.code_postal,
    a.type_voie,
    a.indice_repetition_voie
FROM (
    SELECT DISTINCT
        voie,
        numero_voie,
        commune,
        code_postal,
        type_voie,
        indice_repetition_voie
    FROM datalake."public".etablissement_sante
) a
WHERE NOT EXISTS (
    SELECT 1
    FROM datawarehouse."default".adresse_dim w
    WHERE xxhash64(
        to_utf8(concat_ws('|',
            coalesce(w.nom_voie, ''),
            coalesce(w.numero_voie, ''),
            coalesce(w.complement_adresse, ''),
            coalesce(w.commune, ''),
            coalesce(w.code_postal, ''),
            coalesce(w.type_voie, ''),
            coalesce(w.indice_repetition_voie, '')
        ))
    ) = xxhash64(
        to_utf8(concat_ws('|',
            coalesce(a.voie, ''),
            coalesce(a.numero_voie, ''),
            '',
            coalesce(a.commune, ''),
            coalesce(a.code_postal, ''),
            coalesce(a.type_voie, ''),
            coalesce(a.indice_repetition_voie, '')
        ))
    )
);



INSERT INTO datawarehouse."default".pays_dim (id, nom)
SELECT
    xxhash64(to_utf8(nom_pays)) AS id,
    nom_pays AS nom
FROM (
    SELECT DISTINCT a.pays AS nom_pays
    FROM datalake."public".etablissement_sante a
) src
WHERE NOT EXISTS (
    SELECT 1
    FROM datawarehouse."default".pays_dim p
    WHERE p.nom = src.nom_pays
);




INSERT INTO datawarehouse."default".etablissement_sante (id, raison_sociale_site, id_adresse, id_pays)
SELECT
  a.identifiant_organisation,
  a.raison_sociale_site,
    xxhash64(
        to_utf8(concat_ws('|',
            coalesce(a.voie, ''),
            coalesce(a.numero_voie, ''),
            '',
            coalesce(a.commune, ''),
            coalesce(a.code_postal, ''),
            coalesce(a.type_voie, ''),
            coalesce(a.indice_repetition_voie, '')
        ))
    ) AS id_adresse,
    xxhash64(to_utf8(coalesce(a.pays, ''))) AS id_pays
FROM (
    SELECT DISTINCT
        identifiant_organisation,
        raison_sociale_site,
        voie,
        numero_voie,
        commune,
        code_postal,
        type_voie,
        indice_repetition_voie,
        pays
    FROM datalake."public".etablissement_sante
) a
WHERE NOT EXISTS (
    SELECT 1
    FROM datawarehouse."default".etablissement_sante e
    WHERE e.raison_sociale_site = a.raison_sociale_site
      AND e.id_adresse = xxhash64(
          to_utf8(concat_ws('|',
              coalesce(a.voie, ''),
              coalesce(a.numero_voie, ''),
              '',
              coalesce(a.commune, ''),
              coalesce(a.code_postal, ''),
              coalesce(a.type_voie, ''),
              coalesce(a.indice_repetition_voie, '')
          ))
      )
      AND e.id_pays = xxhash64(to_utf8(coalesce(a.pays, '')))
);

