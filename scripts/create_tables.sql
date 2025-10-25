drop table datawarehouse."default".adresse_dim ;

drop table datawarehouse."default".date_dim ; 

drop table datawarehouse."default".deces;

drop table datawarehouse."default".etablissement_sante  ;

drop table datawarehouse."default".patient ; 

drop table datawarehouse."default".pays_dim ; 

drop table datawarehouse."default".professionel_sante  ;

drop table datawarehouse."default".region_dim   ;

drop table datawarehouse."default".satisfaction;   

drop table datawarehouse."default".travaille_a ;  

drop table datawarehouse."default".note_a  ;
-- ================================
-- SCHEMA DATAWAREHOUSE - TRINO
-- ================================

CREATE TABLE IF NOT EXISTS datawarehouse."default".date_dim (
  	id        varbinary,
  	annee     integer,
    mois      integer,
 	jour      integer,
  	heures    integer,
  	minutes   integer
)
WITH (
  format = 'PARQUET',
  partitioning = ARRAY['annee', 'mois']
);

CREATE TABLE IF NOT EXISTS datawarehouse."default".adresse_dim (
  id                      varbinary,
  nom_voie                varchar,
  numero_voie             varchar,
  complement_adresse      varchar,
  commune                 varchar,
  code_postal             varchar,
  type_voie               varchar,
  indice_repetition_voie  varchar
)
WITH (
  format = 'PARQUET'
);

CREATE TABLE IF NOT EXISTS datawarehouse."default".pays_dim (
  id   varbinary,
  nom  varchar
)
WITH (format = 'PARQUET');

CREATE TABLE IF NOT EXISTS datawarehouse."default".region_dim (
  id   varbinary,
  nom  varchar
)
WITH (format = 'PARQUET');

CREATE TABLE IF NOT EXISTS datawarehouse."default".deces (
  id                  varchar,
  sexe                varchar,
  id_lieu_naissance   varbinary,
  id_lieu_deces       varbinary,
  id_date_naissance   varbinary,
  id_date_mort        varbinary
)
WITH (
  format = 'PARQUET',
  partitioning = ARRAY['id_lieu_deces']
);

CREATE TABLE IF NOT EXISTS datawarehouse."default".professionel_sante (
  id                           varchar,
  civilite                     varchar,
  categorie_professionnelle    varchar,
  profession                   varchar,
  specialite                   varchar
) WITH (
  format = 'PARQUET',
  partitioning = ARRAY['categorie_professionnelle']
);


CREATE TABLE IF NOT EXISTS datawarehouse."default".patient (
  id                  varchar,
  sexe                varchar,
  id_date_naissance   varbinary
)
WITH (
  format = 'PARQUET',
  partitioning = ARRAY['id_date_naissance']
);

CREATE TABLE IF NOT EXISTS datawarehouse."default".hospitalisations (
  id                  varchar,
  code_diagnostic     varchar,
  id_date_entree      varbinary,
  id_date_sortie      varbinary,
  id_patient          varbinary,
  id_etablissement    varbinary
)
WITH (format = 'PARQUET');

CREATE TABLE IF NOT EXISTS datawarehouse."default".satisfaction (
  id                  varchar,
  score_global        integer,
  id_etablissement    varbinary
)
WITH (format = 'PARQUET');

CREATE TABLE IF NOT EXISTS datawarehouse."default".note_a (
  id_region           varbinary,
  id_satisfaction     varbinary
)
WITH (
  format = 'PARQUET',
  partitioning = ARRAY['id_region']
);

CREATE TABLE IF NOT EXISTS datawarehouse."default".etablissement_sante (
  id                  varchar,
  raison_sociale_site varchar,
  id_adresse          varbinary,
  id_pays             varbinary
)
WITH (
  format = 'PARQUET',
  partitioning = ARRAY['id_pays']
);

CREATE TABLE IF NOT EXISTS datawarehouse."default".travaille_a (
  id_etablissement    varbinary,
  id_pro_sante        varbinary,
  mode_exercice       varchar
)
WITH (
  format = 'PARQUET',
  partitioning = ARRAY['id_etablissement']
); 

SHOW TABLES FROM datawarehouse."default";