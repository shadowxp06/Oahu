-- Table: public."DatabaseInfo"

-- DROP TABLE public."DatabaseInfo";

CREATE TABLE public."DatabaseInfo"
(
    dbversion integer NOT NULL,
    uiversion double precision NOT NULL,
    apiversion double precision NOT NULL
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."DatabaseInfo"
    OWNER to postgres;
	