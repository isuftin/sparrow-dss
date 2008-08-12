ALTER TABLE SPARROW_DSS.MODEL_REACH DROP CONSTRAINT "MODEL_REACH_ENH_REACH_FK"
;

ALTER TABLE SPARROW_DSS.MODEL_REACH DROP CONSTRAINT "MODEL_REACH_SPARROW_MODEL_FK"
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_ATTRIB DROP CONSTRAINT "MODEL_REACH_ATTRIB_MODEL__FK1"
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_GEOM DROP CONSTRAINT "MODEL_REACH_GEOM_FK"
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_TOPO DROP CONSTRAINT "MODEL_REACH_TOPO_FK"
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_UPSTREAM DROP CONSTRAINT "FK_UPSTREAM_REACH_ID"
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_UPSTREAM DROP CONSTRAINT "FK_REACH_ID"
;

ALTER TABLE SPARROW_DSS.REACH_COEF DROP CONSTRAINT "REACH_CEOF_MODEL_REACH_FK"
;

ALTER TABLE SPARROW_DSS.SOURCE DROP CONSTRAINT "SOURCE_SPARROW_MODEL_FK"
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_COEF DROP CONSTRAINT "SOURCE_REACH_COEF_SOURCE_FK"
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_COEF DROP CONSTRAINT "SOURCE_REACH_COEF_FK"
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_PREDICT DROP CONSTRAINT "SOURCE_REACH_PREDICT_SOURCE_FK"
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_PREDICT DROP CONSTRAINT "SOURCE_REACH_PREDICT_FK"
;

ALTER TABLE SPARROW_DSS.SOURCE_VALUE DROP CONSTRAINT "SOURCE_VALUE_MODEL_REACH_FK"
;

ALTER TABLE SPARROW_DSS.SOURCE_VALUE DROP CONSTRAINT "SOURCE_VALUE_SOURCE_FK"
;

ALTER TABLE SPARROW_DSS.TOTAL_PREDICT DROP CONSTRAINT "TOTAL_PREDICT_MODEL_REACH_FK"
;

DROP SEQUENCE SPARROW_DSS.MDRS_DF4A$;

DROP SEQUENCE SPARROW_DSS.MDRS_DF52$;

DROP TABLE SPARROW_DSS.MDRT_DF4A$ CASCADE CONSTRAINTS;

DROP TABLE SPARROW_DSS.MDRT_DF52$ CASCADE CONSTRAINTS;

DROP TABLE SPARROW_DSS.MODEL_REACH CASCADE CONSTRAINTS;

DROP TABLE SPARROW_DSS.MODEL_REACH_ATTRIB CASCADE CONSTRAINTS;

DROP TABLE SPARROW_DSS.MODEL_REACH_GEOM CASCADE CONSTRAINTS;

DROP SEQUENCE SPARROW_DSS.MODEL_REACH_SEQ;

DROP TABLE SPARROW_DSS.MODEL_REACH_TOPO CASCADE CONSTRAINTS;

DROP TABLE SPARROW_DSS.MODEL_REACH_UPSTREAM CASCADE CONSTRAINTS;

DROP TABLE SPARROW_DSS.REACH_COEF CASCADE CONSTRAINTS;

DROP SEQUENCE SPARROW_DSS.REACH_COEF_SEQ;

DROP TABLE SPARROW_DSS.SOURCE CASCADE CONSTRAINTS;

DROP TABLE SPARROW_DSS.SOURCE_REACH_COEF CASCADE CONSTRAINTS;

DROP SEQUENCE SPARROW_DSS.SOURCE_REACH_COEF_SEQ;

DROP TABLE SPARROW_DSS.SOURCE_REACH_PREDICT CASCADE CONSTRAINTS;

DROP SEQUENCE SPARROW_DSS.SOURCE_REACH_PREDICT_SEQ;

DROP SEQUENCE SPARROW_DSS.SOURCE_SEQ;

DROP TABLE SPARROW_DSS.SOURCE_VALUE CASCADE CONSTRAINTS;

DROP SEQUENCE SPARROW_DSS.SOURCE_VALUE_SEQ;

DROP TABLE SPARROW_DSS.SPARROW_MODEL CASCADE CONSTRAINTS;

DROP SEQUENCE SPARROW_DSS.SPARROW_MODEL_SEQ;

DROP TABLE SPARROW_DSS.TOTAL_PREDICT CASCADE CONSTRAINTS;

DROP SEQUENCE SPARROW_DSS.TOTAL_PREDICT_SEQ;

CREATE OR REPLACE function get_median_point(
	geom SDO_GEOMETRY
) RETURN SDO_GEOMETRY
IS

	num_points NUMBER;
	p1 SDO_GEOMETRY;
	p2 SDO_GEOMETRY;
	i1 INTEGER;

BEGIN
	num_points := get_num_points(geom);
	IF num_points < 2 THEN
		RETURN get_point(geom);
	ELSE

		IF MOD(num_points,2) = 0 THEN
			--even number of pts

			SELECT cast((num_points/2) as INTEGER) INTO i1 FROM dual;

			p1 := get_point(geom, i1);
			p2 := get_point(geom, i1 + 1);

			--AVG POINTS and return new point
			RETURN
				MDSYS.SDO_GEOMETRY(
					2001,
					geom.SDO_SRID,
					SDO_POINT_TYPE(
						(p1.sdo_point.x + p2.sdo_point.x) / 2,
						(p1.sdo_point.y + p2.sdo_point.y) / 2,
						NULL
					),NULL,NULL);

		ELSE
			--odd number of pts
			SELECT cast((num_points/2) as INTEGER) INTO i1 FROM dual;
			RETURN get_point(geom, i1 + 1);

		END IF;

	END IF;
END;

/

CREATE OR REPLACE function get_num_points(
	geom SDO_GEOMETRY
) RETURN NUMBER
IS
	d NUMBER;
BEGIN

	d := SUBSTR(geom.SDO_GTYPE, 1, 1);
	IF d > 0 THEN
		RETURN geom.SDO_ORDINATES.COUNT()/d;
	ELSE
		RETURN 0;
	END IF;

END;

/

CREATE OR REPLACE function get_point(
	geom SDO_GEOMETRY, point_number NUMBER DEFAULT 1
) RETURN SDO_GEOMETRY
IS
	g MDSYS.SDO_GEOMETRY;
	d NUMBER;
	p NUMBER;
	px NUMBER;
	py NUMBER;

BEGIN

	d := SUBSTR(geom.SDO_GTYPE, 1, 1);

	IF point_number < 1
	OR point_number > geom.SDO_ORDINATES.COUNT()/d THEN
		RETURN NULL;
	END IF;

	p := (point_number-1)*d+1;

	px := geom.SDO_ORDINATES(p);
	py := geom.SDO_ORDINATES(p+1);

	RETURN
		MDSYS.SDO_GEOMETRY(
			2001,
			geom.SDO_SRID,
			SDO_POINT_TYPE(px,py,NULL),
			NULL,NULL);
END;

/

CREATE TABLE SPARROW_DSS.MDRT_DF4A$
(
NODE_ID NUMBER,
NODE_LEVEL NUMBER,
INFO BLOB
)
;

CREATE TABLE SPARROW_DSS.MDRT_DF52$
(
NODE_ID NUMBER,
NODE_LEVEL NUMBER,
INFO BLOB
)
;

CREATE TABLE SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID NUMBER(9, 0) NOT NULL,
IDENTIFIER NUMBER(9, 0) NOT NULL,
FULL_IDENTIFIER VARCHAR2(40) NOT NULL,
SPARROW_MODEL_ID NUMBER(9, 0) NOT NULL,
ENH_REACH_ID NUMBER(9, 0),
HYDSEQ NUMBER(9, 0) NOT NULL,
IFTRAN NUMBER(1, 0) NOT NULL,
FNODE NUMBER(9, 0),
TNODE NUMBER(9, 0),
FRAC NUMBER(10, 9),
REACH_SIZE NUMBER(1, 0) DEFAULT 5 NOT NULL
)
;

CREATE TABLE SPARROW_DSS.MODEL_REACH_ATTRIB
(
MODEL_REACH_ID NUMBER(9, 0) NOT NULL,
REACH_NAME VARCHAR2(60),
OPEN_WATER_NAME VARCHAR2(60),
MEANQ NUMBER(10, 4),
MEANV NUMBER(4, 2),
CATCH_AREA NUMBER(9, 3),
CUM_CATCH_AREA NUMBER(10, 3),
REACH_LENGTH NUMBER(7, 0),
HUC2 VARCHAR2(2),
HUC4 VARCHAR2(4),
HUC6 VARCHAR2(6),
HUC8 VARCHAR2(8),
HEAD_REACH NUMBER(1, 0),
SHORE_REACH NUMBER(1, 0),
TERM_TRANS NUMBER(1, 0),
TERM_ESTUARY NUMBER(1, 0),
TERM_NONCONNECT NUMBER(1, 0)
)
;

CREATE TABLE SPARROW_DSS.MODEL_REACH_GEOM
(
MODEL_REACH_ID NUMBER(9, 0) NOT NULL,
REACH_GEOM MDSYS.SDO_GEOMETRY NOT NULL,
CATCH_GEOM MDSYS.SDO_GEOMETRY NOT NULL,
WATERSHED_GEOM MDSYS.SDO_GEOMETRY
)
;

CREATE TABLE SPARROW_DSS.MODEL_REACH_TOPO
(
MODEL_REACH_ID NUMBER(9, 0) NOT NULL,
FNODE NUMBER(9, 0),
TNODE NUMBER(9, 0),
IFTRAN NUMBER(1, 0) NOT NULL
)
;

CREATE TABLE SPARROW_DSS.MODEL_REACH_UPSTREAM
(
MODEL_REACH_ID NUMBER,
UPSTREAM_REACH_ID NUMBER
)
;

CREATE TABLE SPARROW_DSS.REACH_COEF
(
REACH_COEF_ID NUMBER(9, 0) NOT NULL,
ITERATION NUMBER(4, 0) NOT NULL,
INC_DELIVERY FLOAT(126) NOT NULL,
TOTAL_DELIVERY FLOAT(126) NOT NULL,
BOOT_ERROR FLOAT(126) DEFAULT 0 NOT NULL,
MODEL_REACH_ID NUMBER(9, 0) NOT NULL
)
;

CREATE TABLE SPARROW_DSS.SOURCE
(
SOURCE_ID NUMBER(9, 0) NOT NULL,
NAME VARCHAR2(60 CHAR) NOT NULL,
DESCRIPTION CLOB,
SORT_ORDER NUMBER(3, 0) DEFAULT 1 NOT NULL,
SPARROW_MODEL_ID NUMBER(9, 0) NOT NULL,
IDENTIFIER NUMBER(3, 0) NOT NULL,
DISPLAY_NAME VARCHAR2(20 CHAR),
CONSTITUENT VARCHAR2(30 CHAR) NOT NULL,
UNITS VARCHAR2(30 CHAR) NOT NULL,
PRECISION NUMBER(2, 0) NOT NULL,
IS_POINT_SOURCE VARCHAR2(1 CHAR) NOT NULL
)
;

CREATE TABLE SPARROW_DSS.SOURCE_REACH_COEF
(
SOURCE_REACH_COEF_ID NUMBER(9, 0) NOT NULL,
ITERATION NUMBER(4, 0) NOT NULL,
VALUE FLOAT(126) NOT NULL,
SOURCE_ID NUMBER(9, 0) NOT NULL,
MODEL_REACH_ID NUMBER(9, 0) NOT NULL
)
;

CREATE TABLE SPARROW_DSS.SOURCE_REACH_PREDICT
(
SOURCE_REACH_PREDICT_ID NUMBER(9, 0) NOT NULL,
ITERATION NUMBER(4, 0) NOT NULL,
INCREMENTAL FLOAT(126) NOT NULL,
CUMULATIVE FLOAT(126) NOT NULL,
SOURCE_ID NUMBER(9, 0) NOT NULL,
MODEL_REACH_ID NUMBER(9, 0) NOT NULL
)
;

CREATE TABLE SPARROW_DSS.SOURCE_VALUE
(
SOURCE_VALUE_ID NUMBER(9, 0) NOT NULL,
VALUE FLOAT(126) NOT NULL,
SOURCE_ID NUMBER(9, 0) NOT NULL,
MODEL_REACH_ID NUMBER(9, 0) NOT NULL
)
;

CREATE TABLE SPARROW_DSS.SPARROW_MODEL
(
SPARROW_MODEL_ID NUMBER(9, 0) NOT NULL,
IS_APPROVED CHAR(1) DEFAULT 'F' NOT NULL,
IS_PUBLIC CHAR(1) DEFAULT 'F' NOT NULL,
IS_ARCHIVED CHAR(1) DEFAULT 'F' NOT NULL,
NAME VARCHAR2(40) NOT NULL,
DESCRIPTION CLOB,
DATE_ADDED DATE DEFAULT SYSDATE NOT NULL,
CONTACT_ID NUMBER(9, 0) NOT NULL,
ENH_NETWORK_ID NUMBER(9, 0) NOT NULL,
URL VARCHAR2(400),
BOUND_NORTH NUMBER(9, 6),
BOUND_EAST NUMBER(9, 6),
BOUND_SOUTH NUMBER(9, 6),
BOUND_WEST NUMBER(9, 6)
)
;

CREATE TABLE SPARROW_DSS.TOTAL_PREDICT
(
TOTAL_PREDICT_ID NUMBER(9, 0) NOT NULL,
ITERATION NUMBER(4, 0) NOT NULL,
NO_DECAY_TOTAL FLOAT(126) NOT NULL,
TOTAL FLOAT(126) NOT NULL,
SPARROW_MODEL_ID NUMBER(9, 0) NOT NULL,
MODEL_REACH_ID NUMBER(9, 0) NOT NULL
)
;

ALTER TABLE SPARROW_DSS.MODEL_REACH
ADD CONSTRAINT MODEL_REACH_PK PRIMARY KEY
(
MODEL_REACH_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH
ADD CONSTRAINT MODEL_REACH_UK_IDENTIFIER UNIQUE
(
SPARROW_MODEL_ID,
IDENTIFIER
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_ATTRIB
ADD CONSTRAINT MODEL_REACH_ATTRIB_PK PRIMARY KEY
(
MODEL_REACH_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_GEOM
ADD CONSTRAINT MODEL_REACH_GEOM_PK PRIMARY KEY
(
MODEL_REACH_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_TOPO
ADD CONSTRAINT MODEL_REACH_TOPO_PK PRIMARY KEY
(
MODEL_REACH_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.REACH_COEF
ADD CONSTRAINT REACH_COEF_FACT_PK PRIMARY KEY
(
REACH_COEF_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.REACH_COEF
ADD CONSTRAINT REACH_COEF_UK_VALUE UNIQUE
(
MODEL_REACH_ID,
ITERATION
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE
ADD CONSTRAINT SOURCE_PK PRIMARY KEY
(
SOURCE_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE
ADD CONSTRAINT SOURCE_UK_SOURCE_NAME UNIQUE
(
SPARROW_MODEL_ID,
NAME
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE
ADD CONSTRAINT SOURCE_UK_IDENTIFIER UNIQUE
(
SOURCE_ID,
IDENTIFIER
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_COEF
ADD CONSTRAINT SOURCE_REACH_COEF_PK PRIMARY KEY
(
SOURCE_REACH_COEF_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_COEF
ADD CONSTRAINT SOURCE_REACH_COEF_UK_VALUE UNIQUE
(
MODEL_REACH_ID,
SOURCE_ID,
ITERATION
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_PREDICT
ADD CONSTRAINT SOURCE_REACH_PREDICT_PK PRIMARY KEY
(
SOURCE_REACH_PREDICT_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_PREDICT
ADD CONSTRAINT SOURCE_REACH_PREDICT_UK_VALUE UNIQUE
(
MODEL_REACH_ID,
SOURCE_ID,
ITERATION
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_VALUE
ADD CONSTRAINT SOURCE_VALUE_PK PRIMARY KEY
(
SOURCE_VALUE_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_VALUE
ADD CONSTRAINT SOURCE_VALUE_UK_VALUE UNIQUE
(
MODEL_REACH_ID,
SOURCE_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_PK PRIMARY KEY
(
SPARROW_MODEL_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_UK_NAME UNIQUE
(
ENH_NETWORK_ID,
IS_APPROVED,
IS_PUBLIC,
IS_ARCHIVED,
NAME
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.TOTAL_PREDICT
ADD CONSTRAINT TOTAL_PREDICT_PK PRIMARY KEY
(
TOTAL_PREDICT_ID
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.TOTAL_PREDICT
ADD CONSTRAINT TOTAL_PREDICT_UK_VALUE UNIQUE
(
SPARROW_MODEL_ID,
ITERATION
)
 ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH
ADD CONSTRAINT MODEL_REACH_ENH_REACH_FK FOREIGN KEY
(
ENH_REACH_ID
)
REFERENCES STREAM_NETWORK.ENH_REACH
(
ENH_REACH_ID
) ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH
ADD CONSTRAINT MODEL_REACH_SPARROW_MODEL_FK FOREIGN KEY
(
SPARROW_MODEL_ID
)
REFERENCES SPARROW_DSS.SPARROW_MODEL
(
SPARROW_MODEL_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_ATTRIB
ADD CONSTRAINT MODEL_REACH_ATTRIB_MODEL__FK1 FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
) ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_GEOM
ADD CONSTRAINT MODEL_REACH_GEOM_FK FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_TOPO
ADD CONSTRAINT MODEL_REACH_TOPO_FK FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_UPSTREAM
ADD CONSTRAINT FK_UPSTREAM_REACH_ID FOREIGN KEY
(
UPSTREAM_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH_UPSTREAM
ADD CONSTRAINT FK_REACH_ID FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.REACH_COEF
ADD CONSTRAINT REACH_CEOF_MODEL_REACH_FK FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE
ADD CONSTRAINT SOURCE_SPARROW_MODEL_FK FOREIGN KEY
(
SPARROW_MODEL_ID
)
REFERENCES SPARROW_DSS.SPARROW_MODEL
(
SPARROW_MODEL_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_COEF
ADD CONSTRAINT SOURCE_REACH_COEF_SOURCE_FK FOREIGN KEY
(
SOURCE_ID
)
REFERENCES SPARROW_DSS.SOURCE
(
SOURCE_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_COEF
ADD CONSTRAINT SOURCE_REACH_COEF_FK FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_PREDICT
ADD CONSTRAINT SOURCE_REACH_PREDICT_SOURCE_FK FOREIGN KEY
(
SOURCE_ID
)
REFERENCES SPARROW_DSS.SOURCE
(
SOURCE_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_REACH_PREDICT
ADD CONSTRAINT SOURCE_REACH_PREDICT_FK FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_VALUE
ADD CONSTRAINT SOURCE_VALUE_MODEL_REACH_FK FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE_VALUE
ADD CONSTRAINT SOURCE_VALUE_SOURCE_FK FOREIGN KEY
(
SOURCE_ID
)
REFERENCES SPARROW_DSS.SOURCE
(
SOURCE_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.TOTAL_PREDICT
ADD CONSTRAINT TOTAL_PREDICT_MODEL_REACH_FK FOREIGN KEY
(
MODEL_REACH_ID
)
REFERENCES SPARROW_DSS.MODEL_REACH
(
MODEL_REACH_ID
)
ON DELETE CASCADE ENABLE
;

ALTER TABLE SPARROW_DSS.MODEL_REACH
ADD CONSTRAINT MODEL_REACH_RSIZE_CHK CHECK
(REACH_SIZE BETWEEN 1 AND 5)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SOURCE
ADD CONSTRAINT SOURCE_CHK_IS_POINT_SOURCE CHECK
(IS_POINT_SOURCE IN ('T','F'))
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_CHK_IS_ARC CHECK
(IS_ARCHIVED IN ('T', 'F'))
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_BD_WEST CHECK
(BOUND_WEST >= -180 AND BOUND_WEST < 180)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_BD_NORTH CHECK
(BOUND_NORTH < 90 AND BOUND_NORTH > -90)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_BD_EAST CHECK
(BOUND_EAST <= 180 AND BOUND_EAST > -180)
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_CHK_IS_PUBLIC CHECK
(IS_PUBLIC IN ('T', 'F'))
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_CHK_IS_APP CHECK
(IS_APPROVED IN ('T','F'))
 ENABLE
;

ALTER TABLE SPARROW_DSS.SPARROW_MODEL
ADD CONSTRAINT SPARROW_MODEL_BD_SOUTH CHECK
(BOUND_SOUTH < 90 AND BOUND_SOUTH > -90)
 ENABLE
;

CREATE OR REPLACE VIEW SPARROW_DSS.MODEL_ATTRIB_VW AS (
/*
Selects attribs from MODEL_REACH and MODEL_REACH_ATTRIB
for model reaches that have a corresponding row in the MODEL_REACH_ATTRIB table.
*/
SELECT
    model.SPARROW_MODEL_ID SPARROW_MODEL_ID,
    model.MODEL_REACH_ID MODEL_REACH_ID,
    model.IDENTIFIER IDENTIFIER,
    model.FULL_IDENTIFIER FULL_IDENTIFIER,
    model.HYDSEQ HYDSEQ,
    model.FNODE FNODE,
    model.TNODE TNODE,
    model.FRAC FRAC,
    attrib.REACH_NAME REACH_NAME,
    attrib.OPEN_WATER_NAME OPEN_WATER_NAME,
    attrib.MEANQ MEANQ,
    attrib.MEANV MEANV,
    attrib.CATCH_AREA CATCH_AREA,
    attrib.CUM_CATCH_AREA CUM_CATCH_AREA,
    attrib.REACH_LENGTH REACH_LENGTH,
    attrib.HUC2 HUC2,
    attrib.HUC4 HUC4,
    attrib.HUC6 HUC6,
    attrib.HUC8 HUC8,
    attrib.HEAD_REACH HEAD_REACH,
    attrib.SHORE_REACH SHORE_REACH,
    attrib.TERM_TRANS TERM_TRANS,
    attrib.TERM_ESTUARY TERM_ESTUARY,
    attrib.TERM_NONCONNECT TERM_NONCONNECT
FROM
    MODEL_REACH model INNER JOIN MODEL_REACH_ATTRIB attrib ON (model.MODEL_REACH_ID = attrib.MODEL_REACH_ID)
)
UNION ALL
(
/*
Selects attribs from MODEL_REACH and ENH_ATTRIB_VW
for model reaches that do not have a corresponding row in the MODEL_REACH_ATTRIB table,
but do have a corresponding row in the ENH_ATTRIB_VW view.
*/
SELECT
    model.SPARROW_MODEL_ID SPARROW_MODEL_ID,
    model.MODEL_REACH_ID MODEL_REACH_ID,
    model.IDENTIFIER IDENTIFIER,
    model.FULL_IDENTIFIER FULL_IDENTIFIER,
    model.HYDSEQ HYDSEQ,
    model.FNODE FNODE,
    model.TNODE TNODE,
    model.FRAC FRAC,
    attrib.REACH_NAME REACH_NAME,
    attrib.OPEN_WATER_NAME OPEN_WATER_NAME,
    attrib.MEANQ MEANQ,
    attrib.MEANV MEANV,
    attrib.CATCH_AREA CATCH_AREA,
    attrib.CUM_CATCH_AREA CUM_CATCH_AREA,
    attrib.REACH_LENGTH REACH_LENGTH,
    attrib.HUC2 HUC2,
    attrib.HUC4 HUC4,
    attrib.HUC6 HUC6,
    attrib.HUC8 HUC8,
    attrib.HEAD_REACH HEAD_REACH,
    attrib.SHORE_REACH SHORE_REACH,
    attrib.TERM_TRANS TERM_TRANS,
    attrib.TERM_ESTUARY TERM_ESTUARY,
    attrib.TERM_NONCONNECT TERM_NONCONNECT
FROM
    MODEL_REACH model INNER JOIN STREAM_NETWORK.ENH_ATTRIB_VW attrib ON (model.ENH_REACH_ID = attrib.ENH_REACH_ID)
WHERE
    NOT EXISTS (SELECT MODEL_REACH_ID FROM MODEL_REACH_ATTRIB modattrib WHERE modattrib.MODEL_REACH_ID = model.MODEL_REACH_ID)
)
UNION ALL
(
/*
Selects attribs from MODEL_REACH only, setting values normally found in the
XXX_ATTRIB tables to null.
Applies to cases where a model reach has no corresponding row in
ENH_ATTRIB_VW (i.e., reach is added at the model level)  and does not have a
row in MODEL_REACH_ATTRIB.
This is a degenerate case:   The attribs are not provided in the
STREAM_NETWORK schema or at the model level and are basically missing.
*/
SELECT
    model.SPARROW_MODEL_ID SPARROW_MODEL_ID,
    model.MODEL_REACH_ID MODEL_REACH_ID,
    model.IDENTIFIER IDENTIFIER,
    model.FULL_IDENTIFIER FULL_IDENTIFIER,
    model.HYDSEQ HYDSEQ,
    model.FNODE FNODE,
    model.TNODE TNODE,
    model.FRAC FRAC,
    null REACH_NAME,
    null OPEN_WATER_NAME,
    null MEANQ,
    null MEANV,
    null CATCH_AREA,
    null CUM_CATCH_AREA,
    null REACH_LENGTH,
    null HUC2,
    null HUC4,
    null HUC6,
    null HUC8,
    null HEAD_REACH,
    null SHORE_REACH,
    null TERM_TRANS,
    null TERM_ESTUARY,
    null TERM_NONCONNECT
FROM
    MODEL_REACH model
WHERE
    NOT EXISTS (SELECT ENH_REACH_ID FROM STREAM_NETWORK.ENH_ATTRIB_VW enhvw WHERE enhvw.ENH_REACH_ID = model.ENH_REACH_ID) AND
    NOT EXISTS (SELECT MODEL_REACH_ID FROM MODEL_REACH_ATTRIB modattrib WHERE modattrib.MODEL_REACH_ID = model.MODEL_REACH_ID)
);

CREATE OR REPLACE VIEW SPARROW_DSS.MODEL_GEOM_VW AS SELECT
/*
Note:  In this View, reaches which contain no geometry and are not related to a nominal reach are not returned.
The first query returns reaches which have no geometry at the model level (no entry in MODEL_REACH_GEOM),
but do inherit geometry from the enhanced level (entry in STREAM_NETWORK.ENH_GEOM_VW).  It is possible, however, that the
geometry in ENH_GEOM_VW or MODEL_REACH_GEOM may be null.
*/
model.SPARROW_MODEL_ID as SPARROW_MODEL_ID,
model.MODEL_REACH_ID as MODEL_REACH_ID,
model.IDENTIFIER as IDENTIFIER,
enh.REACH_GEOM as REACH_GEOM,
enh.CATCH_GEOM as CATCH_GEOM,
enh.WATERSHED_GEOM as WATERSHED_GEOM,
model.REACH_SIZE as REACH_SIZE
FROM
MODEL_REACH model INNER JOIN STREAM_NETWORK.ENH_GEOM_VW enh ON (model.ENH_REACH_ID = enh.ENH_REACH_ID)
WHERE
model.MODEL_REACH_ID NOT IN (SELECT MODEL_REACH_ID FROM MODEL_REACH_GEOM)
UNION ALL
SELECT
/*
The second query returns reaches which have geometry at the model level (an entry in MODEL_REACH_GEOM)
*/
model.SPARROW_MODEL_ID as SPARROW_MODEL_ID,
model.MODEL_REACH_ID as MODEL_REACH_ID,
model.IDENTIFIER as IDENTIFIER,
geo.REACH_GEOM as REACH_GEOM,
geo.CATCH_GEOM as CATCH_GEOM,
geo.WATERSHED_GEOM as WATERSHED_GEOM,
model.REACH_SIZE as REACH_SIZE
FROM
MODEL_REACH model INNER JOIN MODEL_REACH_GEOM geo ON (model.MODEL_REACH_ID = geo.MODEL_REACH_ID);

CREATE OR REPLACE VIEW SPARROW_DSS.MODEL_UPSTREAM_VW AS SELECT downstream.SPARROW_MODEL_ID SPARROW_MODEL_ID, downstream.identifier DOWNSTREAM_ID, upstream.identifier UPSTREAM_ID
FROM
  (MODEL_REACH downstream INNER JOIN MODEL_REACH_UPSTREAM relation ON downstream.MODEL_REACH_ID = relation.MODEL_REACH_ID)
  INNER JOIN MODEL_REACH upstream ON upstream.MODEL_REACH_ID = relation.UPSTREAM_REACH_ID;


/* 
	ERROR ORA-02327: cannot create index on expression with datatype ADT
	The generation of the script is incorrect. These must be spatial indexes.

CREATE INDEX SPARROW_DSS.MODEL_REACH_CATCH_GEOM_I ON SPARROW_DSS.MODEL_REACH_GEOM (CATCH_GEOM ASC);

CREATE INDEX SPARROW_DSS.MODEL_REACH_REACH_GEOM_I ON SPARROW_DSS.MODEL_REACH_GEOM (REACH_GEOM ASC);

*/
CREATE INDEX SPARROW_DSS.MODEL_REACH_HYDSEQ_I ON SPARROW_DSS.MODEL_REACH (HYDSEQ ASC);

CREATE INDEX SPARROW_DSS.MODEL_REACH_FNODE_I ON SPARROW_DSS.MODEL_REACH (FNODE ASC);

CREATE INDEX SPARROW_DSS.MODEL_REACH_ENH_REACH_FK_I ON SPARROW_DSS.MODEL_REACH (ENH_REACH_ID ASC);

CREATE INDEX SPARROW_DSS.MODEL_REACH_TNODE_I ON SPARROW_DSS.MODEL_REACH (TNODE ASC);

CREATE INDEX SPARROW_DSS.MODEL_REACH_RSIZE_I ON SPARROW_DSS.MODEL_REACH (REACH_SIZE ASC);

CREATE INDEX SPARROW_DSS.MODEL_REACH_ATTRIB_RNAME_I ON SPARROW_DSS.MODEL_REACH_ATTRIB (REACH_NAME ASC);

CREATE INDEX SPARROW_DSS.MODEL_REACH_ATTRIB_OW_NAME_I ON SPARROW_DSS.MODEL_REACH_ATTRIB (OPEN_WATER_NAME ASC);


CREATE INDEX SPARROW_DSS.MODEL_REACH_UPSTREAM_REACH_ID ON SPARROW_DSS.MODEL_REACH_UPSTREAM (MODEL_REACH_ID ASC);

CREATE INDEX SPARROW_DSS.REACH_COEF_IT_I ON SPARROW_DSS.REACH_COEF (ITERATION ASC);

CREATE INDEX SPARROW_DSS.SOURCE_REACH_IT_I ON SPARROW_DSS.SOURCE_REACH_COEF (ITERATION ASC);

CREATE INDEX SPARROW_DSS.SOURCE_REACH_PREDICT_IT_I ON SPARROW_DSS.SOURCE_REACH_PREDICT (ITERATION ASC);

CREATE SEQUENCE SPARROW_DSS.MDRS_DF4A$ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 100 ORDER ;

CREATE SEQUENCE SPARROW_DSS.MDRS_DF52$ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 100 ORDER ;

CREATE SEQUENCE SPARROW_DSS.MODEL_REACH_SEQ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 20 ORDER ;

CREATE SEQUENCE SPARROW_DSS.REACH_COEF_SEQ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 20 ORDER ;

CREATE SEQUENCE SPARROW_DSS.SOURCE_REACH_COEF_SEQ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 20 ORDER ;

CREATE SEQUENCE SPARROW_DSS.SOURCE_REACH_PREDICT_SEQ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 20 ORDER ;

CREATE SEQUENCE SPARROW_DSS.SOURCE_SEQ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 20 ORDER ;

CREATE SEQUENCE SPARROW_DSS.SOURCE_VALUE_SEQ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 20 ORDER ;

CREATE SEQUENCE SPARROW_DSS.SPARROW_MODEL_SEQ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 20 ORDER ;

CREATE SEQUENCE SPARROW_DSS.TOTAL_PREDICT_SEQ INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 1 CACHE 20 ORDER ;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH.REACH_SIZE IS 'An arbitrary indicator of at what scale a reach should be shown on a map:  5:  National, 4: Regional, 3: State, 2 Multi-County, 1: County.'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_ATTRIB.REACH_NAME IS 'The primary name for the reach'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_ATTRIB.OPEN_WATER_NAME IS 'The primary name for any associated open water, such as a lake or pond.'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_ATTRIB.MEANQ IS 'Mean Flow in Cubic Feet / Second'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_ATTRIB.MEANV IS 'Velocity corresponding to mean streamflow for reach, in feet per second'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_ATTRIB.CATCH_AREA IS 'Incremental drainage area for a given reach, in square kilometers'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_ATTRIB.CUM_CATCH_AREA IS 'Cumulative drainage area for a given reach, in square kilometers'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_ATTRIB.REACH_LENGTH IS 'Reach length in meters'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_TOPO.FNODE IS 'Can be null if no from node'
;

COMMENT ON COLUMN SPARROW_DSS.MODEL_REACH_TOPO.TNODE IS 'Can be null if no downstream node'
;

COMMENT ON COLUMN SPARROW_DSS.REACH_COEF.BOOT_ERROR IS 'Would 1 be a more reasonable value for this? '
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.SOURCE_ID IS 'Uniquely id''s a source globally - this is the UUID db key.'
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.NAME IS 'The full name of the source. '
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.DESCRIPTION IS 'A detailed description of the source.'
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.SORT_ORDER IS 'Sequential numbers used to sort the sources (low to high) when the sources are displayed to the user. Can just be a copy of the SOURCE_ID values if the sort order does not need to be changed.'
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.IDENTIFIER IS 'Normally a sequentially numbered ID for the source, starting at 1. Used to refer to a source within a model.'
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.DISPLAY_NAME IS 'A shortened name for the source that is easier to display in space limited areas '
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.CONSTITUENT IS 'The name of the thing the source values are measuring. '
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.UNITS IS 'The units in which the constituent is measured in '
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.PRECISION IS 'The number of decimal places used in reports of the source value. Full precision is used for calculations. '
;

COMMENT ON COLUMN SPARROW_DSS.SOURCE.IS_POINT_SOURCE IS 'A yes or no flag (values are Y or N) to indicate if this is a point source. This flag may be used to inhibit reports of yield calculations based on point sources. '
;

