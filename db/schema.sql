\restrict dbmate

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 18.6 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'student'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    activity_id bigint NOT NULL,
    entry_id bigint NOT NULL,
    code_id bigint NOT NULL
);


--
-- Name: activities_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.activities ALTER COLUMN activity_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.activities_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.codes (
    code_id bigint NOT NULL,
    wem_code text NOT NULL,
    wem_description text NOT NULL
);


--
-- Name: codes_code_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.codes ALTER COLUMN code_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.codes_code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entries (
    entry_id bigint NOT NULL,
    user_id bigint NOT NULL,
    entry_text text NOT NULL,
    entry_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: entries_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.entries ALTER COLUMN entry_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.entries_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    role public.user_role DEFAULT 'student'::public.user_role NOT NULL
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: activities activities_entry_id_code_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_entry_id_code_id_key UNIQUE (entry_id, code_id);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (activity_id);


--
-- Name: codes codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes
    ADD CONSTRAINT codes_pkey PRIMARY KEY (code_id);


--
-- Name: codes codes_wem_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes
    ADD CONSTRAINT codes_wem_code_key UNIQUE (wem_code);


--
-- Name: entries entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (entry_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: activities_code_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activities_code_id_idx ON public.activities USING btree (code_id);


--
-- Name: entries_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entries_user_id_idx ON public.entries USING btree (user_id);


--
-- Name: users_email_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_unique_idx ON public.users USING btree (lower(email));


--
-- Name: activities activities_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_code_id_fkey FOREIGN KEY (code_id) REFERENCES public.codes(code_id) ON DELETE RESTRICT;


--
-- Name: activities activities_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.entries(entry_id) ON DELETE CASCADE;


--
-- Name: entries entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict dbmate


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20260917212537'),
    ('20260917213244'),
    ('20260917224537'),
    ('20260917224545'),
    ('20260921134004'),
    ('20260921134005'),
    ('20260921134006'),
    ('20260921175425');
