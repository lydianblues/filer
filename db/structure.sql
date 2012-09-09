--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: clusterings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clusterings (
    id integer NOT NULL,
    cluster_id integer,
    filespace_id integer
);


--
-- Name: clusterings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clusterings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clusterings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clusterings_id_seq OWNED BY clusterings.id;


--
-- Name: clusters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clusters (
    id integer NOT NULL,
    name character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clusters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clusters_id_seq OWNED BY clusters.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    content character varying(255),
    name character varying(255),
    size integer,
    url character varying(255),
    checksum character varying(255),
    path character varying(255),
    content_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: filespaces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filespaces (
    id integer NOT NULL,
    name character varying(255),
    version integer DEFAULT 1,
    uuid character varying(255),
    latest boolean,
    root_folder_id integer,
    current_folder_id integer,
    incoming_folder_id integer,
    trash_folder_id integer,
    archived_folder_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: filespaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE filespaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filespaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE filespaces_id_seq OWNED BY filespaces.id;


--
-- Name: folders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE folders (
    id integer NOT NULL,
    name character varying(255),
    filespace_id integer,
    parent_id integer,
    leaf boolean DEFAULT true,
    ntype character varying(255) DEFAULT 'regular'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: folders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE folders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: folders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE folders_id_seq OWNED BY folders.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    document_id integer,
    folder_id integer
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clusterings ALTER COLUMN id SET DEFAULT nextval('clusterings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clusters ALTER COLUMN id SET DEFAULT nextval('clusters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY filespaces ALTER COLUMN id SET DEFAULT nextval('filespaces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY folders ALTER COLUMN id SET DEFAULT nextval('folders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: clusterings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clusterings
    ADD CONSTRAINT clusterings_pkey PRIMARY KEY (id);


--
-- Name: clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clusters
    ADD CONSTRAINT clusters_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: filespaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filespaces
    ADD CONSTRAINT filespaces_pkey PRIMARY KEY (id);


--
-- Name: folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120719185107');

INSERT INTO schema_migrations (version) VALUES ('20120719192554');

INSERT INTO schema_migrations (version) VALUES ('20120719192620');

INSERT INTO schema_migrations (version) VALUES ('20120722173734');

INSERT INTO schema_migrations (version) VALUES ('20120803183656');

INSERT INTO schema_migrations (version) VALUES ('20120908020857');