CREATE OR REPLACE VIEW datawarehouse."default".v_deces_2019_region_geo AS
WITH geo AS (
  -- id_region INSEE  -> lat, lon (centroïdes approx.)
  SELECT * FROM (
    VALUES
      (11, 48.8566,   2.3522),   -- Île-de-France
      (24, 47.8440,   1.9199),   -- Centre-Val de Loire
      (27, 47.2805,   5.0415),   -- Bourgogne-Franche-Comté
      (28, 49.1829,   0.3710),   -- Normandie
      (32, 50.2860,   2.7819),   -- Hauts-de-France
      (44, 48.6921,   6.1844),   -- Grand Est
      (52, 47.4736,  -0.5542),   -- Pays de la Loire
      (53, 48.2000,  -2.9000),   -- Bretagne
      (75, 45.3000,   0.0000),   -- Nouvelle-Aquitaine
      (76, 43.7000,   2.2000),   -- Occitanie
      (84, 45.5000,   4.3000),   -- Auvergne-Rhône-Alpes
      (93, 43.8000,   6.0000),   -- Provence-Alpes-Côte d'Azur
      (94, 42.0396,   9.0129),   -- Corse
      (01, 16.2650, -61.5510),   -- Guadeloupe
      (02, 14.6415, -61.0242),   -- Martinique
      (03,  4.0000, -53.0000),   -- Guyane
      (04, -21.1151, 55.5364),   -- La Réunion
      (06, -12.8275, 45.1662)    -- Mayotte
  ) AS t(id_region, lat, lon)
)
SELECT
  rg.id                  AS id_region,
  rg.nom                 AS region,
  g.lat,
  g.lon,
  COUNT(*)               AS nb_deces
FROM datawarehouse."default".deces d
JOIN datawarehouse."default".adresse_dim a ON a.id = d.id_lieu_deces
JOIN datawarehouse."default".region_dim rg ON rg.id = a.id_region
JOIN geo g ON g.id_region = rg.id
WHERE d.date_mort BETWEEN DATE '2019-01-01' AND DATE '2019-12-31'
GROUP BY rg.id, rg.nom, g.lat, g.lon
ORDER BY nb_deces DESC;
