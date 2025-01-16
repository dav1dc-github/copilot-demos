-- A database table for storing a collection of PokeMan cards
-- This table is used to store the data for the PokeMan cards
-- that are used in the PokeMan game.

CREATE TABLE pokeMan (
  id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  name VARCHAR2(255) NOT NULL,
  type VARCHAR2(255) NOT NULL,
  hp NUMBER NOT NULL,
  attack NUMBER NOT NULL,
  defense NUMBER NOT NULL,
  speed NUMBER NOT NULL,
  special NUMBER NOT NULL,
  image VARCHAR2(255) NOT NULL
);

-- Insert some sample data into the table
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Bulbasaur', 'Grass', 45, 49, 49, 45, 65, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png');
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Ivysaur', 'Grass', 60, 62, 63, 60, 80, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/2.png');
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Venusaur', 'Grass', 80, 82, 83, 80, 100, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png');
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Charmander', 'Fire', 39, 52, 43, 65, 50, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/4.png');
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Charmeleon', 'Fire', 58, 64, 58, 80, 65, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/5.png');
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Charizard', 'Fire', 78, 84, 78, 100, 85, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png');
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Squirtle', 'Water', 44, 48, 65, 43, 50, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/7.png');
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Wartortle', 'Water', 59, 63, 80, 58, 65, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/8.png');
INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image) VALUES
('Blastoise', 'Water', 79, 83, 100, 78, 85, 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png');

-- A stored procedure for inserting records into the PokeMan table
CREATE OR REPLACE PROCEDURE InsertPokeMan (
  pokeManName IN VARCHAR2,
  pokeManType IN VARCHAR2,
  pokeManHP IN NUMBER,
  pokeManAttack IN NUMBER,
  pokeManDefense IN NUMBER,
  pokeManSpeed IN NUMBER,
  pokeManSpecial IN NUMBER,
  pokeManImage IN VARCHAR2
) IS
  name_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(name_exists, -20001);
BEGIN
  -- Check if pokeManName already exists
  IF EXISTS (SELECT 1 FROM pokeMan WHERE name = pokeManName) THEN
    -- Handle the case where the name already exists
    RAISE_APPLICATION_ERROR(-20001, 'PokeManName already exists');
  ELSE
    -- Insert the new record
    INSERT INTO pokeMan (name, type, hp, attack, defense, speed, special, image)
    VALUES (pokeManName, pokeManType, pokeManHP, pokeManAttack, pokeManDefense, pokeManSpeed, pokeManSpecial, pokeManImage);
  END IF;
EXCEPTION
  WHEN name_exists THEN
    -- Handle the error
    ROLLBACK;
    RAISE;
  WHEN OTHERS THEN
    -- Handle other errors
    ROLLBACK;
    RAISE;
END;

