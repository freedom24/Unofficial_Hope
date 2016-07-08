delimiter $$

CREATE DEFINER=`root`@`localhost` FUNCTION `sf_FactoryUseMaintenance`(fID BIGINT(20)) RETURNS int(11)
BEGIN

--
-- Declare Variables
-- it

  DECLARE maint INTEGER;
  DECLARE maintcalc INTEGER;
  DECLARE maintchar VARCHAR(128);
  DECLARE rate INTEGER;
  DECLARE decayrate INTEGER;
  DECLARE quantity INTEGER;

  DECLARE active INTEGER;
  DECLARE struct_condition INTEGER;
  DECLARE percent FLOAT;
  DECLARE owner BIGINT(20);
  DECLARE bank INTEGER;
  DECLARE cr INTEGER;
  DECLARE ret INTEGER;
  DECLARE maxcondition INTEGER;

--
-- set a proper exit handler in case we have a faulty resource ID
--

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
  BEGIN
    UPDATE factories f SET f.active = 0 WHERE f.ID = fID;
    RETURN 3;
  END;

--
-- Get the owners id in case the maintenance is drained
--
  SELECT s.owner FROM structures s WHERE s.ID =fID INTO owner;
  SELECT b.credits FROM banks b WHERE b.id =(owner+4) INTO bank;



--
-- get the maintenance reserves
--

  SELECT sa.value FROM structure_attributes sa WHERE sa.structure_id =fID AND sa.attribute_id = 382 INTO maintchar;
  SELECT CAST(maintchar AS SIGNED) INTO maint;

--
-- get the maintenance rate
--

  SELECT st.maint_cost_wk FROM structures s INNER JOIN structure_type_data st ON (s.type = st.type) WHERE s.ID =fID  INTO rate;
  SELECT st.decay_rate FROM structures s INNER JOIN structure_type_data st ON (s.type = st.type) WHERE s.ID =fID  INTO decayrate;

  SELECT st.max_condition FROM structures s INNER JOIN structure_type_data st ON (s.type = st.type) WHERE s.ID =fID  INTO maxcondition;

--
-- rate/168 is hourly maintenance - we need to deduct it every half hour as every 30 min is the condition damage intervall
--

  IF(maint >= rate)THEN


      SELECT CAST((maint - (rate/336)) AS SIGNED) INTO maintcalc;
      SELECT CAST((maintcalc ) AS CHAR(128)) INTO maintchar;


      UPDATE structure_attributes sa SET sa.VALUE = maintchar WHERE sa.structure_id = fID AND sa.attribute_id = 382;

--
-- Return 0 for everything ok
--


      return 0;


   END IF;

  IF(maint < rate)THEN
    SELECT ((rate/336)-maint) INTO cr;

    SELECT '0' INTO maintchar;

    UPDATE structure_attributes sa SET sa.VALUE = maintchar WHERE sa.structure_id =fID AND sa.attribute_id = 382;
    UPDATE factories f SET f.active = 0 WHERE f.ID = fID;


  END IF;



  IF(bank >= cr) THEN

    UPDATE banks SET credits = credits-cr WHERE id =(owner+4);

--
-- Return 1 for structure out of maintenance having taken maintenance out of the bank
--

    return 1;

  END IF;


  IF(bank < cr) THEN

    UPDATE banks SET credits = 0 WHERE id =(owner+4);

    SELECT((rate/336) - bank) INTO cr;
--
-- reduce the condition partly due to partly maintenance missing
--

    SELECT (cr/(rate/100)) INTO percent;
    UPDATE structures s SET s.condition_id = (s.condition_id +(decayrate*percent)) WHERE s.ID = fID;

--
-- damage the structures Condition
--

    SELECT s.condition_id FROM structures s WHERE s.ID = fID  INTO struct_condition;

--
-- notify if the structure needs to be condemned thats return code 3
-- please note that condition is actually damage to condition
--

    if(struct_condition >= maxcondition) THEN
      UPDATE structures s SET s.condition_id = maxcondition WHERE s.ID = fID;
      return 3;
    END IF;



    UPDATE factories f SET f.active = 0 WHERE f.ID = fID;
--
-- Return 2 for structure out of maintenance AND Bank account empty - structure damaged
--

    return 2;

  END IF;



--
-- Return 5 for mess up
--

  RETURN 5;

--
-- Exit
--

END$$

