CREATE TABLE IF NOT EXISTS insee_commmunes_2019 (
    typecom VARCHAR(4),
    com VARCHAR(5),
    reg VARCHAR(2),
    dep VARCHAR(3),
    arr VARCHAR(4),
    tncc VARCHAR(1),
    ncc VARCHAR(200),
    nccenr VARCHAR(200),
    libelle VARCHAR(200),
    can VARCHAR(5),
    comparent VARCHAR(5)
);

CREATE TABLE IF NOT EXISTS insee_regions_2019 (
    reg VARCHAR(2),
    cheflieu VARCHAR(5),
    tncc VARCHAR(1),
    ncc VARCHAR(200),
    nccenr VARCHAR(200),
    libelle VARCHAR(200)
);