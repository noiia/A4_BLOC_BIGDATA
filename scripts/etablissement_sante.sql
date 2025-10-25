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
            coalesce('', ''),
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
FROM datalake."public".etablissement_sante a
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
    xxhash64(to_utf8(concat_ws('|', coalesce(a.pays, '')))) AS id,
    a.pays AS nom
FROM datalake."public".etablissement_sante a
WHERE NOT EXISTS (
    SELECT 1
    FROM datawarehouse."default".pays_dim p
    WHERE p.nom = a.pays
);