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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE callback_reports ALTER COLUMN id SET DEFAULT nextval('callback_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE callbacks ALTER COLUMN id SET DEFAULT nextval('callbacks_id_seq'::regclass);


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
-- Name: index_callback_reports_on_type_and_period; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_callback_reports_on_type_and_period ON callback_reports USING btree (type, period);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20110701231239');

INSERT INTO schema_migrations (version) VALUES ('20110702000900');