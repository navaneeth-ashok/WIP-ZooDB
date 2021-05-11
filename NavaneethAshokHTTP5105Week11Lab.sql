-- 1 - Create a procedure that accepts four input parameters: two strings, a date, and a number. Have your procedure perform a select statement that selects values from your input parameters in the following format:
DELIMITER $$
CREATE PROCEDURE SESAME(
	param_date DATE,
	param_string1 VARCHAR(255),
	param_string2 VARCHAR(255),
	param_number INT
)
BEGIN 
	SELECT CONCAT(param_date, "'s episode of Sesame Street has been brought to you by the 
letters ", UPPER(SUBSTR(param_string1, 1,1)), " and ", UPPER(SUBSTR(param_string2, 1,1)), " , and the number ", param_number) AS "STRING";
END;
$$
DELIMITER ;
DROP PROCEDURE SESAME
CALL SESAME(NOW(), "Batman", "Superman", 3)

-- 2 - Create a procedure that, when called, will insert values into three of your database's tables: two tables with a many-to-many relationship, and the bridging table that manages that relationship. See the example I used of books & authors on how to do this while maintaining data integrity
-- I'm creating this procedure to run on my athelete, result, events table created for a previous lab.
-- To ensure data integrity I'm checking whether the athelete or the competition is already present in the the tables,
-- if present, i'm taking the primary key to create the result table without creating a duplicate of the entry.
-- if not present, I'm using the incremented primary key to create the table

DROP PROCEDURE IF EXISTS addNewResult;
DELIMITER $$

CREATE PROCEDURE addNewResult(
  param_ath_fname    VARCHAR(50),
  param_ath_lname  VARCHAR(50),
  param_competition   VARCHAR(50),
  param_comp_time TIME,
  param_medal VARCHAR(20)
)
BEGIN
-- DECLARE local variables
  DECLARE var_ath_id   INT;
  DECLARE var_event_id INT;
  DECLARE var_res_id INT;
  DECLARE var_exist_ath_id INT;
  DECLARE var_exist_cmpt_id INT;
 
-- Finding next primary key for the 3 tables

SELECT MAX(id) + 1 INTO var_ath_id 
  FROM ATHLETES;
SELECT MAX(id) + 1 INTO var_event_id
  FROM EVENTS;
 SELECT MAX(id) + 1 INTO var_res_id
  FROM RESULTS;
	-- Checking whether the athlete already exist, if not add, else skip
	SELECT id from ATHLETES where param_ath_fname = fname AND param_ath_lname = lname INTO var_exist_ath_id;
    IF var_exist_ath_id is NULL
    	THEN
    	INSERT INTO ATHLETES VALUES(var_ath_id, param_ath_fname, param_ath_lname);
    ELSE
    	-- if the athelete exists make sure the ahtlete id for building the result table is proper
    	SET var_ath_id = var_exist_ath_id;
    END IF;
    -- Checking whether the competition already exists, if not add, else skip
   	SELECT id FROM EVENTS where competition = param_competition AND event_time = param_comp_time INTO var_exist_cmpt_id;
	IF var_exist_cmpt_id is NULL
		THEN
		INSERT INTO EVENTS VALUES(var_event_id, param_competition, param_comp_time);
	ELSE
		-- if the event exists make sure the event id for building the result table is proper
		SET var_event_id = var_exist_cmpt_id;
	END IF;
    -- Inserting to the results db
	INSERT INTO RESULTS VALUES(var_res_id, var_event_id, var_ath_id, param_medal);
END
$$
DELIMITER ;

SELECT * FROM ATHLETES a2
SELECT * FROM EVENTS e 
SELECT * FROM RESULTS r 
SELECT * FROM finalDetailedResult fdr

CALL addNewResult(
  'Dorothy', 
  'Dietrich',
  'Relay Race',
  '11:00:00',
  'Gold');

-- 4 - Create a procedure that, when called, will set a session variable to the current time. Additionally, write a SELECT statement using that session variable that will subtract the session variable from the current time.

DELIMITER $$
CREATE PROCEDURE timeCounter ()
BEGIN
  SET @timenow = TIME(NOW());
END $$
DELIMITER ;

CALL timeCounter();
SELECT @timenow;
SELECT SEC_TO_TIME(TIME(NOW()) - @timenow) ;