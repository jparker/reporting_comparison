--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

--
-- Name: delete_from_report(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_from_report() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ DECLARE date TIMESTAMP WITHOUT TIME ZONE; BEGIN date = date_trunc('week', OLD.timestamp); UPDATE trigger_reports SET net = net-OLD.net, gross = gross-OLD.gross, commission = commission-OLD.commission WHERE type = 'WeeklyTriggerReport' AND period = date; RETURN NULL; END; $$;


--
-- Name: insert_into_report(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION insert_into_report() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ DECLARE date TIMESTAMP WITHOUT TIME ZONE; BEGIN date = date_trunc('week', NEW.timestamp); LOOP UPDATE trigger_reports SET net = net+NEW.net, gross = gross+NEW.gross, commission = commission+NEW.commission WHERE type = 'WeeklyTriggerReport' AND period = date; EXIT WHEN found; INSERT INTO trigger_reports (type, period, net, gross, commission) VALUES('WeeklyTriggerReport', date, NEW.net, NEW.gross, NEW.commission); EXIT; END LOOP; RETURN NULL; END; $$;


--
-- Name: update_in_report(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_in_report() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ DECLARE old_date TIMESTAMP WITHOUT TIME ZONE; new_date TIMESTAMP WITHOUT TIME ZONE; BEGIN old_date = date_trunc('week', OLD.timestamp); new_date = date_trunc('week', NEW.timestamp); LOOP IF (old_date != new_date) THEN UPDATE trigger_reports SET net = net-OLD.net, gross = gross-OLD.gross, commission = commission-OLD.commission WHERE type = 'WeeklyTriggerReport' AND period = old_date; UPDATE trigger_reports SET net = net+NEW.net, gross = gross+NEW.gross, commission = commission+NEW.commission WHERE type = 'WeeklyTriggerReport' AND period = new_date; ELSE UPDATE trigger_reports SET net = net-OLD.net+NEW.net, gross = gross-OLD.gross+NEW.gross, commission = commission-OLD.commission+NEW.commission WHERE type = 'WeeklyTriggerReport' AND period = new_date; END IF; EXIT WHEN found; INSERT INTO trigger_reports (type, period, net, gross, commission) VALUES('WeeklyTriggerReport', new_date, NEW.net, NEW.gross, NEW.commission); EXIT; END LOOP; RETURN NULL; END; $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: callback_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE callback_reports (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    period timestamp without time zone NOT NULL,
    gross numeric(12,2) DEFAULT 0 NOT NULL,
    net numeric(12,2) DEFAULT 0 NOT NULL,
    commission numeric(12,2) DEFAULT 0 NOT NULL
);


--
-- Name: callback_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE callback_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: callback_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE callback_reports_id_seq OWNED BY callback_reports.id;


--
-- Name: callbacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE callbacks (
    id integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    net numeric(10,2) DEFAULT 0 NOT NULL,
    gross numeric(10,2) DEFAULT 0 NOT NULL,
    commission numeric(10,2) DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: callbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE callbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: callbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE callbacks_id_seq OWNED BY callbacks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: trigger_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trigger_reports (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    period timestamp without time zone NOT NULL,
    gross numeric(12,2) DEFAULT 0 NOT NULL,
    net numeric(12,2) DEFAULT 0 NOT NULL,
    commission numeric(12,2) DEFAULT 0 NOT NULL
);


--
-- Name: trigger_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trigger_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trigger_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trigger_reports_id_seq OWNED BY trigger_reports.id;


--
-- Name: triggers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE triggers (
    id integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    net numeric(10,2) DEFAULT 0 NOT NULL,
    gross numeric(10,2) DEFAULT 0 NOT NULL,
    commission numeric(10,2) DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: triggers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE triggers_id_seq OWNED BY triggers.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE callback_reports ALTER COLUMN id SET DEFAULT nextval('callback_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE callbacks ALTER COLUMN id SET DEFAULT nextval('callbacks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE trigger_reports ALTER COLUMN id SET DEFAULT nextval('trigger_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE triggers ALTER COLUMN id SET DEFAULT nextval('triggers_id_seq'::regclass);


--
-- Name: callback_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY callback_reports
    ADD CONSTRAINT callback_reports_pkey PRIMARY KEY (id);


--
-- Name: callbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY callbacks
    ADD CONSTRAINT callbacks_pkey PRIMARY KEY (id);


--
-- Name: trigger_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trigger_reports
    ADD CONSTRAINT trigger_reports_pkey PRIMARY KEY (id);


--
-- Name: triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY triggers
    ADD CONSTRAINT triggers_pkey PRIMARY KEY (id);


--
-- Name: index_callback_reports_on_type_and_period; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_callback_reports_on_type_and_period ON callback_reports USING btree (type, period);


--
-- Name: index_callbacks_on_timestamp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_callbacks_on_timestamp ON callbacks USING btree ("timestamp");


--
-- Name: index_trigger_reports_on_type_and_period; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_trigger_reports_on_type_and_period ON trigger_reports USING btree (type, period);


--
-- Name: index_triggers_on_timestamp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_triggers_on_timestamp ON triggers USING btree ("timestamp");


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: delete_from_report; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_from_report AFTER DELETE ON triggers FOR EACH ROW EXECUTE PROCEDURE delete_from_report();


--
-- Name: insert_into_report; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_into_report AFTER INSERT ON triggers FOR EACH ROW EXECUTE PROCEDURE insert_into_report();


--
-- Name: update_in_report; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_in_report AFTER UPDATE ON triggers FOR EACH ROW EXECUTE PROCEDURE update_in_report();


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20110702000900');

INSERT INTO schema_migrations (version) VALUES ('20110704064441');

INSERT INTO schema_migrations (version) VALUES ('20110704064446');

INSERT INTO schema_migrations (version) VALUES ('20110701231239');

INSERT INTO schema_migrations (version) VALUES ('20110704064457');