-- Booking system: database structure (8 tables, enums, indexes, foreign keys) without demo data.
-- Generated with pg_dump from src/database/migrations on 2026-10-18; the migrations stay the source of truth.
-- sequelize_meta rows are included so a later "sequelize-cli db:migrate" only runs NEW migrations.
-- Import into an EMPTY database: psql -h 127.0.0.1 -U booking_user -d booking_db -v ON_ERROR_STOP=1 -f schema.sql
--
-- PostgreSQL database dump
--


-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: enum_booking_status_logs_from_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_booking_status_logs_from_status AS ENUM (
    'PENDING',
    'CONFIRMED',
    'COMPLETED',
    'CANCELLED'
);


--
-- Name: enum_booking_status_logs_to_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_booking_status_logs_to_status AS ENUM (
    'PENDING',
    'CONFIRMED',
    'COMPLETED',
    'CANCELLED'
);


--
-- Name: enum_bookings_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_bookings_status AS ENUM (
    'PENDING',
    'CONFIRMED',
    'COMPLETED',
    'CANCELLED'
);


--
-- Name: enum_payments_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_payments_method AS ENUM (
    'CASH',
    'TRANSFER',
    'EWALLET'
);


--
-- Name: enum_payments_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_payments_status AS ENUM (
    'UNPAID',
    'PAID',
    'REFUNDED'
);


--
-- Name: enum_schedules_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_schedules_status AS ENUM (
    'AVAILABLE',
    'FULL',
    'CLOSED'
);


--
-- Name: enum_services_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_services_status AS ENUM (
    'ACTIVE',
    'INACTIVE'
);


--
-- Name: enum_users_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_users_role AS ENUM (
    'ADMIN',
    'USER'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: booking_status_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_status_logs (
    id integer NOT NULL,
    booking_id uuid NOT NULL,
    from_status public.enum_booking_status_logs_from_status,
    to_status public.enum_booking_status_logs_to_status NOT NULL,
    changed_by uuid,
    note character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: booking_status_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_status_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_status_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_status_logs_id_seq OWNED BY public.booking_status_logs.id;


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id uuid NOT NULL,
    booking_code character varying(30) NOT NULL,
    user_id uuid NOT NULL,
    service_id integer NOT NULL,
    schedule_id integer NOT NULL,
    total_price numeric(12,2) NOT NULL,
    status public.enum_bookings_status DEFAULT 'PENDING'::public.enum_bookings_status NOT NULL,
    notes character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(120) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid NOT NULL,
    booking_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL,
    method public.enum_payments_method,
    status public.enum_payments_status DEFAULT 'UNPAID'::public.enum_payments_status NOT NULL,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(64) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules (
    id integer NOT NULL,
    service_id integer NOT NULL,
    date date NOT NULL,
    start_time character varying(5) NOT NULL,
    end_time character varying(5) NOT NULL,
    capacity integer DEFAULT 1 NOT NULL,
    booked_count integer DEFAULT 0 NOT NULL,
    status public.enum_schedules_status DEFAULT 'AVAILABLE'::public.enum_schedules_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schedules_id_seq OWNED BY public.schedules.id;


--
-- Name: sequelize_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sequelize_meta (
    name character varying(255) NOT NULL
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id integer NOT NULL,
    category_id integer NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    price numeric(12,2) NOT NULL,
    duration_minutes integer NOT NULL,
    status public.enum_services_status DEFAULT 'ACTIVE'::public.enum_services_status NOT NULL,
    image_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    phone character varying(20),
    password_hash text NOT NULL,
    role public.enum_users_role DEFAULT 'USER'::public.enum_users_role NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: booking_status_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_status_logs ALTER COLUMN id SET DEFAULT nextval('public.booking_status_logs_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedules_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: booking_status_logs booking_status_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_status_logs
    ADD CONSTRAINT booking_status_logs_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_booking_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_booking_code_key UNIQUE (booking_code);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- Name: payments payments_booking_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_key UNIQUE (booking_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: sequelize_meta sequelize_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequelize_meta
    ADD CONSTRAINT sequelize_meta_pkey PRIMARY KEY (name);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: booking_status_logs_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX booking_status_logs_booking_id ON public.booking_status_logs USING btree (booking_id);


--
-- Name: bookings_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookings_created_at ON public.bookings USING btree (created_at);


--
-- Name: bookings_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookings_schedule_id ON public.bookings USING btree (schedule_id);


--
-- Name: bookings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookings_status ON public.bookings USING btree (status);


--
-- Name: bookings_user_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookings_user_id_status ON public.bookings USING btree (user_id, status);


--
-- Name: payments_status_paid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_status_paid_at ON public.payments USING btree (status, paid_at);


--
-- Name: refresh_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX refresh_tokens_user_id ON public.refresh_tokens USING btree (user_id);


--
-- Name: schedules_date_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedules_date_status ON public.schedules USING btree (date, status);


--
-- Name: schedules_service_id_date_start_time; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX schedules_service_id_date_start_time ON public.schedules USING btree (service_id, date, start_time);


--
-- Name: services_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX services_category_id ON public.services USING btree (category_id);


--
-- Name: services_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX services_status ON public.services USING btree (status);


--
-- Name: users_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_role ON public.users USING btree (role);


--
-- Name: booking_status_logs booking_status_logs_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_status_logs
    ADD CONSTRAINT booking_status_logs_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: booking_status_logs booking_status_logs_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_status_logs
    ADD CONSTRAINT booking_status_logs_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: bookings bookings_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: bookings bookings_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: schedules schedules_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: services services_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--



--
-- PostgreSQL database dump
--


-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: sequelize_meta; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sequelize_meta (name) VALUES ('20261011000001-create-users.js');
INSERT INTO public.sequelize_meta (name) VALUES ('20261011000002-create-refresh-tokens.js');
INSERT INTO public.sequelize_meta (name) VALUES ('20261011000003-create-categories.js');
INSERT INTO public.sequelize_meta (name) VALUES ('20261011000004-create-services.js');
INSERT INTO public.sequelize_meta (name) VALUES ('20261011000005-create-schedules.js');
INSERT INTO public.sequelize_meta (name) VALUES ('20261011000006-create-bookings.js');
INSERT INTO public.sequelize_meta (name) VALUES ('20261011000007-create-payments.js');
INSERT INTO public.sequelize_meta (name) VALUES ('20261011000008-create-booking-status-logs.js');


--
-- PostgreSQL database dump complete
--


