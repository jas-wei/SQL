-- Create the database and ensure it is the active database before running the rest of the script...
CREATE DATABASE pokemon;

-- When using the transaction, if there are any errors you may need to execute ROLLBACK.

BEGIN TRANSACTION;

DROP TABLE IF EXISTS pokedex;
DROP TABLE IF EXISTS technical_machines;

CREATE TYPE pokemon_type AS ENUM('Normal', 'Fire', 'Fighting', 'Water', 'Flying', 'Grass', 'Poison', 'Electric', 'Ground', 'Psychic', 'Rock', 'Ice', 'Bug', 'Dragon', 'Ghost', 'Dark', 'Steel', 'Fairy');
CREATE TYPE move_category AS ENUM('Physical', 'Status', 'Special');

-- Create the pokedex table.
CREATE TABLE pokedex (
  pokedex_id SERIAL PRIMARY KEY,
  pokedex_number SMALLINT NOT NULL,
  pokemon_name TEXT NOT NULL,
  pokemon_sub_name TEXT,
  primary_type pokemon_type NOT NULL,
  secondary_type pokemon_type,
  hp SMALLINT NOT NULL DEFAULT 0 CHECK(hp>=0),
  attack SMALLINT NOT NULL DEFAULT 0 CHECK(attack>=0),
  defense SMALLINT NOT NULL DEFAULT 0 CHECK(defense>=0),
  special_attack SMALLINT NOT NULL DEFAULT 0 CHECK(special_attack>=0),
  special_defense SMALLINT NOT NULL DEFAULT 0 CHECK(special_defense>=0),
  speed SMALLINT NOT NULL DEFAULT 0 CHECK(speed>=0),
  evolves_from_id INT REFERENCES pokedex(pokedex_id) ON DELETE SET NULL  
);

-- Create the technical_machines table.
CREATE TABLE technical_machines (
    tm_id SERIAL PRIMARY KEY,
    tm_number INT NOT NULL UNIQUE,
    tm_name	TEXT NOT NULL UNIQUE,
    applies_to_type pokemon_type NOT NULL,
    category move_category NOT NULL,
    attack_power INT CHECK(attack_power >= 0),
    accuracy INT CHECK(accuracy >= 0),
    power_points INT CHECK(power_points >= 0)
);

-- Insert some of the pokemon.
INSERT INTO pokedex (pokedex_number,pokemon_name,pokemon_sub_name,primary_type,secondary_type,hp,attack,defense,special_attack,special_defense,speed,evolves_from_id) VALUES
	 (1,'Bulbasaur',NULL,'Grass'::public.pokemon_type,'Poison'::public.pokemon_type,45,49,49,65,65,45,NULL),
	 (2,'Ivysaur',NULL,'Grass'::public.pokemon_type,'Poison'::public.pokemon_type,60,62,63,80,80,60,NULL),
	 (3,'Venusaur',NULL,'Grass'::public.pokemon_type,'Poison'::public.pokemon_type,80,82,83,100,100,80,NULL),
	 (3,'Venusaur','Mega Venusaur','Grass'::public.pokemon_type,'Poison'::public.pokemon_type,80,100,123,122,120,80,NULL),
	 (4,'Charmander',NULL,'Fire'::public.pokemon_type,NULL,39,52,43,60,50,65,NULL),
	 (5,'Charmeleon',NULL,'Fire'::public.pokemon_type,NULL,58,64,58,80,65,80,NULL),
	 (6,'Charizard',NULL,'Fire'::public.pokemon_type,'Flying'::public.pokemon_type,78,84,78,109,85,100,NULL),
	 (6,'Charizard','Mega Charizard X','Fire'::public.pokemon_type,'Dragon'::public.pokemon_type,78,130,111,130,85,100,NULL),
	 (6,'Charizard','Mega Charizard Y','Fire'::public.pokemon_type,'Flying'::public.pokemon_type,78,104,78,159,115,100,NULL),
	 (7,'Squirtle',NULL,'Water'::public.pokemon_type,NULL,44,48,65,50,64,43,NULL),
	 (8,'Wartortle',NULL,'Water'::public.pokemon_type,NULL,59,63,80,65,80,58,NULL),
	 (9,'Blastoise',NULL,'Water'::public.pokemon_type,NULL,79,83,100,85,105,78,NULL),
	 (9,'Blastoise','Mega Blastoise','Water'::public.pokemon_type,NULL,79,103,120,135,115,78,NULL),
	 (10,'Caterpie',NULL,'Bug'::public.pokemon_type,NULL,45,30,35,20,20,45,NULL),
	 (11,'Metapod',NULL,'Bug'::public.pokemon_type,NULL,50,20,55,25,25,30,NULL),
	 (12,'Butterfree',NULL,'Bug'::public.pokemon_type,'Flying'::public.pokemon_type,60,45,50,90,80,70,NULL),
	 (13,'Weedle',NULL,'Bug'::public.pokemon_type,'Poison'::public.pokemon_type,40,35,30,20,20,50,NULL),
	 (14,'Kakuna',NULL,'Bug'::public.pokemon_type,'Poison'::public.pokemon_type,45,25,50,25,25,35,NULL),
	 (15,'Beedrill',NULL,'Bug'::public.pokemon_type,'Poison'::public.pokemon_type,65,90,40,45,80,75,NULL),
	 (15,'Beedrill','Mega Beedrill','Bug'::public.pokemon_type,'Poison'::public.pokemon_type,65,150,40,15,80,145,NULL),
	 (16,'Pidgey',NULL,'Normal'::public.pokemon_type,'Flying'::public.pokemon_type,40,45,40,35,35,56,NULL),
	 (17,'Pidgeotto',NULL,'Normal'::public.pokemon_type,'Flying'::public.pokemon_type,63,60,55,50,50,71,NULL),
	 (18,'Pidgeot',NULL,'Normal'::public.pokemon_type,'Flying'::public.pokemon_type,83,80,75,70,70,101,NULL),
	 (18,'Pidgeot','Mega Pidgeot','Normal'::public.pokemon_type,'Flying'::public.pokemon_type,83,80,80,135,80,121,NULL),
	 (19,'Rattata',NULL,'Normal'::public.pokemon_type,NULL,30,56,35,25,35,72,NULL),
	 (19,'Rattata','Alolan Rattata','Dark'::public.pokemon_type,'Normal'::public.pokemon_type,30,56,35,25,35,72,NULL),
	 (20,'Raticate',NULL,'Normal'::public.pokemon_type,NULL,55,81,60,50,70,97,NULL),
	 (20,'Raticate','Alolan Raticate','Dark'::public.pokemon_type,'Normal'::public.pokemon_type,75,71,70,40,80,77,NULL),
	 (21,'Spearow',NULL,'Normal'::public.pokemon_type,'Flying'::public.pokemon_type,40,60,30,31,31,70,NULL),
	 (22,'Fearow',NULL,'Normal'::public.pokemon_type,'Flying'::public.pokemon_type,65,90,65,61,61,100,NULL),
	 (23,'Ekans',NULL,'Poison'::public.pokemon_type,NULL,35,60,44,40,54,55,NULL),
	 (24,'Arbok',NULL,'Poison'::public.pokemon_type,NULL,60,95,69,65,79,80,NULL),
	 (25,'Pikachu',NULL,'Electric'::public.pokemon_type,NULL,35,55,40,50,50,90,NULL),
	 (25,'Pikachu','Partner Pikachu','Electric'::public.pokemon_type,NULL,45,80,50,75,60,120,NULL),
	 (26,'Raichu',NULL,'Electric'::public.pokemon_type,NULL,60,90,55,90,80,110,NULL),
	 (26,'Raichu','Alolan Raichu','Electric'::public.pokemon_type,'Psychic'::public.pokemon_type,60,85,50,95,85,110,NULL),
	 (27,'Sandshrew',NULL,'Ground'::public.pokemon_type,NULL,50,75,85,20,30,40,NULL),
	 (27,'Sandshrew','Alolan Sandshrew','Ice'::public.pokemon_type,'Steel'::public.pokemon_type,50,75,90,10,35,40,NULL),
	 (28,'Sandslash',NULL,'Ground'::public.pokemon_type,NULL,75,100,110,45,55,65,NULL),
	 (28,'Sandslash','Alolan Sandslash','Ice'::public.pokemon_type,'Steel'::public.pokemon_type,75,100,120,25,65,65,NULL),
	 (29,'Nidoran (female)',NULL,'Poison'::public.pokemon_type,NULL,55,47,52,40,40,41,NULL),
	 (30,'Nidorina',NULL,'Poison'::public.pokemon_type,NULL,70,62,67,55,55,56,NULL),
	 (31,'Nidoqueen',NULL,'Poison'::public.pokemon_type,'Ground'::public.pokemon_type,90,92,87,75,85,76,NULL),
	 (32,'Nidoran (male)',NULL,'Poison'::public.pokemon_type,NULL,46,57,40,40,40,50,NULL),
	 (33,'Nidorino',NULL,'Poison'::public.pokemon_type,NULL,61,72,57,55,55,65,NULL),
	 (34,'Nidoking',NULL,'Poison'::public.pokemon_type,'Ground'::public.pokemon_type,81,102,77,85,75,85,NULL),
	 (35,'Clefairy',NULL,'Fairy'::public.pokemon_type,NULL,70,45,48,60,65,35,NULL),
	 (36,'Clefable',NULL,'Fairy'::public.pokemon_type,NULL,95,70,73,95,90,60,NULL),
	 (37,'Vulpix',NULL,'Fire'::public.pokemon_type,NULL,38,41,40,50,65,65,NULL),
	 (37,'Vulpix','Alolan Vulpix','Ice'::public.pokemon_type,NULL,38,41,40,50,65,65,NULL),
	 (38,'Ninetales',NULL,'Fire'::public.pokemon_type,NULL,73,76,75,81,100,100,NULL),
	 (38,'Ninetales','Alolan Ninetales','Ice'::public.pokemon_type,'Fairy'::public.pokemon_type,73,67,75,81,100,109,NULL),
	 (39,'Jigglypuff',NULL,'Normal'::public.pokemon_type,'Fairy'::public.pokemon_type,115,45,20,45,25,20,NULL),
	 (40,'Wigglytuff',NULL,'Normal'::public.pokemon_type,'Fairy'::public.pokemon_type,140,70,45,85,50,45,NULL),
	 (41,'Zubat',NULL,'Poison'::public.pokemon_type,'Flying'::public.pokemon_type,40,45,35,30,40,55,NULL),
	 (42,'Golbat',NULL,'Poison'::public.pokemon_type,'Flying'::public.pokemon_type,75,80,70,65,75,90,NULL),
	 (43,'Oddish',NULL,'Grass'::public.pokemon_type,'Poison'::public.pokemon_type,45,50,55,75,65,30,NULL),
	 (44,'Gloom',NULL,'Grass'::public.pokemon_type,'Poison'::public.pokemon_type,60,65,70,85,75,40,NULL),
	 (45,'Vileplume',NULL,'Grass'::public.pokemon_type,'Poison'::public.pokemon_type,75,80,85,110,90,50,NULL),
	 (46,'Paras',NULL,'Bug'::public.pokemon_type,'Grass'::public.pokemon_type,35,70,55,45,55,25,NULL),
	 (47,'Parasect',NULL,'Bug'::public.pokemon_type,'Grass'::public.pokemon_type,60,95,80,60,80,30,NULL),
	 (48,'Venonat',NULL,'Bug'::public.pokemon_type,'Poison'::public.pokemon_type,60,55,50,40,55,45,NULL),
	 (49,'Venomoth',NULL,'Bug'::public.pokemon_type,'Poison'::public.pokemon_type,70,65,60,90,75,90,NULL),
	 (50,'Diglett',NULL,'Ground'::public.pokemon_type,NULL,10,55,25,35,45,95,NULL),
	 (50,'Diglett','Alolan Diglett','Ground'::public.pokemon_type,'Steel'::public.pokemon_type,10,55,30,35,45,90,NULL),
	 (51,'Dugtrio',NULL,'Ground'::public.pokemon_type,NULL,35,100,50,50,70,120,NULL),
	 (51,'Dugtrio','Alolan Dugtrio','Ground'::public.pokemon_type,'Steel'::public.pokemon_type,35,100,60,50,70,110,NULL),
	 (133,'Eevee',NULL,'Normal'::public.pokemon_type,NULL,55,55,50,45,65,55,NULL),
	 (133,'Eevee','Partner Eevee','Normal'::public.pokemon_type,NULL,65,75,70,65,85,75,NULL),
	 (134,'Vaporeon',NULL,'Water'::public.pokemon_type,NULL,130,65,60,110,95,65,NULL),
	 (135,'Jolteon',NULL,'Electric'::public.pokemon_type,NULL,65,65,60,110,95,130,NULL),
	 (136,'Flareon',NULL,'Fire'::public.pokemon_type,NULL,65,130,60,95,110,65,NULL);



COMMIT;