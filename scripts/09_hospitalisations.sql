MERGE INTO datawarehouse."default".hospitalisations t
USING (
  SELECT
    -- ID déterministe en VARCHAR
    to_hex(xxhash64(to_utf8(array_join(
      ARRAY[
        coalesce(cast(id_patient AS VARCHAR), ''),
        coalesce(norm_org_id(identifiant_organisation), ''),
        coalesce(code_diagnostic, ''),
        coalesce(date_entree, ''),
        coalesce(jour_hospitalisation, '')
      ], '|'
    ))))                                              AS id,

    code_diagnostic,
    parse_date_fr(date_entree)                        AS date_entree,
    date_add('day',
             TRY_CAST(jour_hospitalisation AS INTEGER) - 1,
             parse_date_fr(date_entree))              AS date_sortie,
    TRY_CAST(id_patient AS INTEGER)                   AS id_patient,
    norm_org_id(identifiant_organisation)             AS id_etablissement
  FROM datalake.public.hospitalisation
  WHERE date_entree IS NOT NULL AND trim(date_entree) <> ''
) s
ON t.id = s.id
WHEN MATCHED THEN UPDATE SET
  code_diagnostic  = s.code_diagnostic,
  date_entree      = s.date_entree,
  date_sortie      = s.date_sortie,
  id_patient       = s.id_patient,
  id_etablissement = s.id_etablissement
WHEN NOT MATCHED THEN INSERT (id, code_diagnostic, date_entree, date_sortie, id_patient, id_etablissement)
VALUES (s.id, s.code_diagnostic, s.date_entree, s.date_sortie, s.id_patient, s.id_etablissement);
