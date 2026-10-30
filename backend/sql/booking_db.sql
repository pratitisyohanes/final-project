-- Booking system: full database (structure + demo data) for the presentation.
-- Generated with pg_dump after migrate + seed on 2026-10-18; demo schedules cover 2026-10-11 to 2026-11-01.
-- Demo accounts: admin@booking.com / Admin12345, budi@example.com and siti@example.com / User12345.
-- Import into an EMPTY database: psql -h 127.0.0.1 -U booking_user -d booking_db -v ON_ERROR_STOP=1 -f booking_db.sql
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
-- Data for Name: booking_status_logs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (1, '5d0d5c7d-635f-4c35-a191-7a5194fffef9', NULL, 'PENDING', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 'Booking created', '2026-10-18 01:41:34.914+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (2, '5d0d5c7d-635f-4c35-a191-7a5194fffef9', 'PENDING', 'CONFIRMED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:34.914+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (3, '5d0d5c7d-635f-4c35-a191-7a5194fffef9', 'CONFIRMED', 'COMPLETED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:34.915+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (4, '703cf4e0-c677-4b7a-b8ed-707c9758f587', NULL, 'PENDING', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 'Booking created', '2026-10-18 01:41:34.949+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (5, '703cf4e0-c677-4b7a-b8ed-707c9758f587', 'PENDING', 'CONFIRMED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:34.949+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (6, '703cf4e0-c677-4b7a-b8ed-707c9758f587', 'CONFIRMED', 'COMPLETED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:34.949+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (8, '6a7885b2-bb39-46bf-a5ac-b177e4a8028d', 'PENDING', 'CONFIRMED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:34.972+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (7, '6a7885b2-bb39-46bf-a5ac-b177e4a8028d', NULL, 'PENDING', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 'Booking created', '2026-10-18 01:41:34.972+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (9, '6a7885b2-bb39-46bf-a5ac-b177e4a8028d', 'CONFIRMED', 'COMPLETED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:34.972+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (10, 'bf9505a6-8af8-444e-b858-5b26eb3ec8ac', 'PENDING', 'CONFIRMED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:35.019+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (11, 'bf9505a6-8af8-444e-b858-5b26eb3ec8ac', 'CONFIRMED', 'COMPLETED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:35.019+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (12, 'bf9505a6-8af8-444e-b858-5b26eb3ec8ac', NULL, 'PENDING', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 'Booking created', '2026-10-18 01:41:35.019+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (13, '0c3b55ae-51eb-44c2-80ad-ddfdcff98e80', NULL, 'PENDING', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 'Booking created', '2026-10-18 01:41:35.049+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (14, '0c3b55ae-51eb-44c2-80ad-ddfdcff98e80', 'PENDING', 'CANCELLED', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 'Cancelled by customer', '2026-10-18 01:41:35.049+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (15, '2c898efa-d085-474c-9178-f846d54acd6d', NULL, 'PENDING', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 'Booking created', '2026-10-18 01:41:35.057+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (16, '2c898efa-d085-474c-9178-f846d54acd6d', 'PENDING', 'CONFIRMED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:35.057+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (17, '2c898efa-d085-474c-9178-f846d54acd6d', 'CONFIRMED', 'COMPLETED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:35.057+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (18, 'b4b61a05-8238-465a-b7e3-af8d05eaf247', NULL, 'PENDING', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 'Booking created', '2026-10-18 01:41:35.068+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (19, 'b4b61a05-8238-465a-b7e3-af8d05eaf247', 'PENDING', 'CONFIRMED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:35.068+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (20, 'b4b61a05-8238-465a-b7e3-af8d05eaf247', 'CONFIRMED', 'COMPLETED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:35.068+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (21, 'dd49ba8c-8ecc-45e3-a728-f49ce1133f14', NULL, 'PENDING', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 'Booking created', '2026-10-18 01:41:35.086+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (22, 'dd49ba8c-8ecc-45e3-a728-f49ce1133f14', 'PENDING', 'CONFIRMED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:35.086+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (23, 'dd012927-16d6-490a-a9bc-928200f35ed6', NULL, 'PENDING', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 'Booking created', '2026-10-18 01:41:35.097+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (24, '336301bc-c00e-401f-a848-331e70728ecb', NULL, 'PENDING', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 'Booking created', '2026-10-18 01:41:35.105+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (25, '6d177b9a-3547-4e85-bb22-b88654971557', NULL, 'PENDING', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 'Booking created', '2026-10-18 01:41:35.115+07');
INSERT INTO public.booking_status_logs (id, booking_id, from_status, to_status, changed_by, note, created_at) VALUES (26, '6d177b9a-3547-4e85-bb22-b88654971557', 'PENDING', 'CONFIRMED', '676e3705-4e5b-4a84-a2b2-959f93790941', NULL, '2026-10-18 01:41:35.115+07');


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('5d0d5c7d-635f-4c35-a191-7a5194fffef9', 'BK-SEED-0001', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 1, 10, 75000.00, 'COMPLETED', NULL, '2026-10-11 10:00:00+07', '2026-10-18 01:41:34.904+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('703cf4e0-c677-4b7a-b8ed-707c9758f587', 'BK-SEED-0002', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 3, 272, 180000.00, 'COMPLETED', NULL, '2026-10-11 12:00:00+07', '2026-10-18 01:41:34.944+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('6a7885b2-bb39-46bf-a5ac-b177e4a8028d', 'BK-SEED-0003', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 4, 394, 150000.00, 'COMPLETED', NULL, '2026-10-12 12:00:00+07', '2026-10-18 01:41:34.968+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('bf9505a6-8af8-444e-b858-5b26eb3ec8ac', 'BK-SEED-0004', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 1, 26, 75000.00, 'COMPLETED', NULL, '2026-10-13 10:00:00+07', '2026-10-18 01:41:35.013+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('0c3b55ae-51eb-44c2-80ad-ddfdcff98e80', 'BK-SEED-0005', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 5, 583, 120000.00, 'CANCELLED', NULL, '2026-10-14 09:00:00+07', '2026-10-18 01:41:35.042+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('2c898efa-d085-474c-9178-f846d54acd6d', 'BK-SEED-0006', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 1, 42, 75000.00, 'COMPLETED', NULL, '2026-10-15 10:00:00+07', '2026-10-18 01:41:35.055+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('b4b61a05-8238-465a-b7e3-af8d05eaf247', 'BK-SEED-0007', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 3, 296, 180000.00, 'COMPLETED', NULL, '2026-10-16 10:30:00+07', '2026-10-18 01:41:35.066+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('dd49ba8c-8ecc-45e3-a728-f49ce1133f14', 'BK-SEED-0008', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 4, 441, 150000.00, 'CONFIRMED', NULL, '2026-10-18 11:00:00+07', '2026-10-18 01:41:35.08+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('dd012927-16d6-490a-a9bc-928200f35ed6', 'BK-SEED-0009', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 1, 74, 75000.00, 'PENDING', NULL, '2026-10-19 10:00:00+07', '2026-10-18 01:41:35.094+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('336301bc-c00e-401f-a848-331e70728ecb', 'BK-SEED-0010', 'cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 6, 891, 50000.00, 'PENDING', NULL, '2026-10-20 11:00:00+07', '2026-10-18 01:41:35.103+07');
INSERT INTO public.bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, notes, created_at, updated_at) VALUES ('6d177b9a-3547-4e85-bb22-b88654971557', 'BK-SEED-0011', '11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 2, 221, 250000.00, 'CONFIRMED', NULL, '2026-10-21 09:00:00+07', '2026-10-18 01:41:35.112+07');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (1, 'Hair Care', 'hair-care', '2026-10-18 01:41:34.709+07', '2026-10-18 01:41:34.709+07');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (2, 'Spa & Massage', 'spa-and-massage', '2026-10-18 01:41:34.709+07', '2026-10-18 01:41:34.709+07');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (3, 'Nail Care', 'nail-care', '2026-10-18 01:41:34.709+07', '2026-10-18 01:41:34.709+07');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (4, 'Consultation', 'consultation', '2026-10-18 01:41:34.709+07', '2026-10-18 01:41:34.709+07');


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('9a922d66-ef47-4f67-803c-65a88e875fbc', '5d0d5c7d-635f-4c35-a191-7a5194fffef9', 75000.00, 'TRANSFER', 'PAID', '2026-10-12 10:00:00+07', '2026-10-18 01:41:34.914+07', '2026-10-18 01:41:34.914+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('60e06479-37ab-47a5-81b9-bb5cf5bc34c9', '703cf4e0-c677-4b7a-b8ed-707c9758f587', 180000.00, 'TRANSFER', 'PAID', '2026-10-12 12:00:00+07', '2026-10-18 01:41:34.949+07', '2026-10-18 01:41:34.949+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('5d9c7a25-3807-4efc-a2aa-75f49c6c56ef', '6a7885b2-bb39-46bf-a5ac-b177e4a8028d', 150000.00, 'TRANSFER', 'PAID', '2026-10-13 12:00:00+07', '2026-10-18 01:41:34.971+07', '2026-10-18 01:41:34.971+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('4a81899c-4cbe-4ef2-bdc4-8ff0f6dba98b', 'bf9505a6-8af8-444e-b858-5b26eb3ec8ac', 75000.00, 'TRANSFER', 'PAID', '2026-10-14 10:00:00+07', '2026-10-18 01:41:35.019+07', '2026-10-18 01:41:35.019+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('f9c29264-d8f2-43f8-bacb-ce422d6c0880', '0c3b55ae-51eb-44c2-80ad-ddfdcff98e80', 120000.00, NULL, 'UNPAID', NULL, '2026-10-18 01:41:35.049+07', '2026-10-18 01:41:35.049+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('fa6c435e-dc7e-4c5b-a375-e755bcd1a1b3', '2c898efa-d085-474c-9178-f846d54acd6d', 75000.00, 'TRANSFER', 'PAID', '2026-10-16 10:00:00+07', '2026-10-18 01:41:35.057+07', '2026-10-18 01:41:35.057+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('d063486f-35cf-4e65-ad85-8b2364138415', 'b4b61a05-8238-465a-b7e3-af8d05eaf247', 180000.00, 'TRANSFER', 'PAID', '2026-10-17 10:30:00+07', '2026-10-18 01:41:35.068+07', '2026-10-18 01:41:35.068+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('249f11a3-b383-4495-b43c-25164147ebd0', 'dd49ba8c-8ecc-45e3-a728-f49ce1133f14', 150000.00, 'TRANSFER', 'PAID', '2026-10-18 01:41:35.08+07', '2026-10-18 01:41:35.085+07', '2026-10-18 01:41:35.085+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('94b2b66a-1117-4903-ab59-4432b71a28ac', 'dd012927-16d6-490a-a9bc-928200f35ed6', 75000.00, NULL, 'UNPAID', NULL, '2026-10-18 01:41:35.097+07', '2026-10-18 01:41:35.097+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('9d43fca8-cc82-4cca-9393-e359987a7e03', '336301bc-c00e-401f-a848-331e70728ecb', 50000.00, NULL, 'UNPAID', NULL, '2026-10-18 01:41:35.105+07', '2026-10-18 01:41:35.105+07');
INSERT INTO public.payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at) VALUES ('6ff02c3c-d4bc-4e68-a7ca-1e4679ac7310', '6d177b9a-3547-4e85-bb22-b88654971557', 250000.00, 'TRANSFER', 'PAID', '2026-10-18 01:41:35.111+07', '2026-10-18 01:41:35.115+07', '2026-10-18 01:41:35.115+07');


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1, 1, '2026-10-11', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (2, 1, '2026-10-11', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (3, 1, '2026-10-11', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (4, 1, '2026-10-11', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (5, 1, '2026-10-11', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (6, 1, '2026-10-11', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (7, 1, '2026-10-11', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (8, 1, '2026-10-11', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (9, 1, '2026-10-12', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (11, 1, '2026-10-12', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (12, 1, '2026-10-12', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (13, 1, '2026-10-12', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (14, 1, '2026-10-12', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (15, 1, '2026-10-12', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (16, 1, '2026-10-12', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (17, 1, '2026-10-13', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (18, 1, '2026-10-13', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (19, 1, '2026-10-13', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (20, 1, '2026-10-13', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (21, 1, '2026-10-13', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (22, 1, '2026-10-13', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (23, 1, '2026-10-13', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (24, 1, '2026-10-13', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (25, 1, '2026-10-14', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (27, 1, '2026-10-14', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (28, 1, '2026-10-14', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (29, 1, '2026-10-14', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (30, 1, '2026-10-14', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (31, 1, '2026-10-14', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (32, 1, '2026-10-14', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (33, 1, '2026-10-15', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (34, 1, '2026-10-15', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (35, 1, '2026-10-15', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (36, 1, '2026-10-15', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (37, 1, '2026-10-15', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (38, 1, '2026-10-15', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (39, 1, '2026-10-15', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (40, 1, '2026-10-15', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (41, 1, '2026-10-16', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (43, 1, '2026-10-16', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (44, 1, '2026-10-16', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (45, 1, '2026-10-16', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (46, 1, '2026-10-16', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (47, 1, '2026-10-16', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (48, 1, '2026-10-16', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (49, 1, '2026-10-17', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (50, 1, '2026-10-17', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (51, 1, '2026-10-17', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (52, 1, '2026-10-17', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (53, 1, '2026-10-17', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (54, 1, '2026-10-17', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (55, 1, '2026-10-17', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (56, 1, '2026-10-17', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (57, 1, '2026-10-18', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (58, 1, '2026-10-18', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (59, 1, '2026-10-18', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (60, 1, '2026-10-18', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (61, 1, '2026-10-18', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (62, 1, '2026-10-18', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (63, 1, '2026-10-18', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (64, 1, '2026-10-18', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (65, 1, '2026-10-19', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (66, 1, '2026-10-19', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (67, 1, '2026-10-19', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (68, 1, '2026-10-19', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (69, 1, '2026-10-19', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (70, 1, '2026-10-19', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (71, 1, '2026-10-19', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (72, 1, '2026-10-19', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (73, 1, '2026-10-20', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (75, 1, '2026-10-20', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (76, 1, '2026-10-20', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (77, 1, '2026-10-20', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (78, 1, '2026-10-20', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (79, 1, '2026-10-20', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (80, 1, '2026-10-20', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (81, 1, '2026-10-21', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (82, 1, '2026-10-21', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (83, 1, '2026-10-21', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (84, 1, '2026-10-21', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (85, 1, '2026-10-21', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (86, 1, '2026-10-21', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (87, 1, '2026-10-21', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (88, 1, '2026-10-21', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (89, 1, '2026-10-22', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (90, 1, '2026-10-22', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (91, 1, '2026-10-22', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (92, 1, '2026-10-22', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (93, 1, '2026-10-22', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (94, 1, '2026-10-22', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (95, 1, '2026-10-22', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (96, 1, '2026-10-22', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (97, 1, '2026-10-23', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (26, 1, '2026-10-14', '10:00', '11:00', 2, 1, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:35.035+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (42, 1, '2026-10-16', '10:00', '11:00', 2, 1, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:35.063+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (74, 1, '2026-10-20', '10:00', '11:00', 2, 1, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:35.1+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (98, 1, '2026-10-23', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (99, 1, '2026-10-23', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (100, 1, '2026-10-23', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (101, 1, '2026-10-23', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (102, 1, '2026-10-23', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (103, 1, '2026-10-23', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (104, 1, '2026-10-23', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (105, 1, '2026-10-24', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (106, 1, '2026-10-24', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (107, 1, '2026-10-24', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (108, 1, '2026-10-24', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (109, 1, '2026-10-24', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (110, 1, '2026-10-24', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (111, 1, '2026-10-24', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (112, 1, '2026-10-24', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (113, 1, '2026-10-25', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (114, 1, '2026-10-25', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (115, 1, '2026-10-25', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (116, 1, '2026-10-25', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (117, 1, '2026-10-25', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (118, 1, '2026-10-25', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (119, 1, '2026-10-25', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (120, 1, '2026-10-25', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (121, 1, '2026-10-26', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (122, 1, '2026-10-26', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (123, 1, '2026-10-26', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (124, 1, '2026-10-26', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (125, 1, '2026-10-26', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (126, 1, '2026-10-26', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (127, 1, '2026-10-26', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (128, 1, '2026-10-26', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (129, 1, '2026-10-27', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (130, 1, '2026-10-27', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (131, 1, '2026-10-27', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (132, 1, '2026-10-27', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (133, 1, '2026-10-27', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (134, 1, '2026-10-27', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (135, 1, '2026-10-27', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (136, 1, '2026-10-27', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (137, 1, '2026-10-28', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (138, 1, '2026-10-28', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (139, 1, '2026-10-28', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (140, 1, '2026-10-28', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (141, 1, '2026-10-28', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (142, 1, '2026-10-28', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (143, 1, '2026-10-28', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (144, 1, '2026-10-28', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (145, 1, '2026-10-29', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (146, 1, '2026-10-29', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (147, 1, '2026-10-29', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (148, 1, '2026-10-29', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (149, 1, '2026-10-29', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (150, 1, '2026-10-29', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (151, 1, '2026-10-29', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (152, 1, '2026-10-29', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (153, 1, '2026-10-30', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (154, 1, '2026-10-30', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (155, 1, '2026-10-30', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (156, 1, '2026-10-30', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (157, 1, '2026-10-30', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (158, 1, '2026-10-30', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (159, 1, '2026-10-30', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (160, 1, '2026-10-30', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (161, 1, '2026-10-31', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (162, 1, '2026-10-31', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (163, 1, '2026-10-31', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (164, 1, '2026-10-31', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (165, 1, '2026-10-31', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (166, 1, '2026-10-31', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (167, 1, '2026-10-31', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (168, 1, '2026-10-31', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (169, 1, '2026-11-01', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (170, 1, '2026-11-01', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (171, 1, '2026-11-01', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (172, 1, '2026-11-01', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (173, 1, '2026-11-01', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (174, 1, '2026-11-01', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (175, 1, '2026-11-01', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (176, 1, '2026-11-01', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.733+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (177, 2, '2026-10-11', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (178, 2, '2026-10-11', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (179, 2, '2026-10-11', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (180, 2, '2026-10-11', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (181, 2, '2026-10-12', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (182, 2, '2026-10-12', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (183, 2, '2026-10-12', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (184, 2, '2026-10-12', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (185, 2, '2026-10-13', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (186, 2, '2026-10-13', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (187, 2, '2026-10-13', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (188, 2, '2026-10-13', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (189, 2, '2026-10-14', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (190, 2, '2026-10-14', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (191, 2, '2026-10-14', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (192, 2, '2026-10-14', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (193, 2, '2026-10-15', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (194, 2, '2026-10-15', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (195, 2, '2026-10-15', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (196, 2, '2026-10-15', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (197, 2, '2026-10-16', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (198, 2, '2026-10-16', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (199, 2, '2026-10-16', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (200, 2, '2026-10-16', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (201, 2, '2026-10-17', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (202, 2, '2026-10-17', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (203, 2, '2026-10-17', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (204, 2, '2026-10-17', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (205, 2, '2026-10-18', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (206, 2, '2026-10-18', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (207, 2, '2026-10-18', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (208, 2, '2026-10-18', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (209, 2, '2026-10-19', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (210, 2, '2026-10-19', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (211, 2, '2026-10-19', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (212, 2, '2026-10-19', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (213, 2, '2026-10-20', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (214, 2, '2026-10-20', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (215, 2, '2026-10-20', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (216, 2, '2026-10-20', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (217, 2, '2026-10-21', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (218, 2, '2026-10-21', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (219, 2, '2026-10-21', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (220, 2, '2026-10-21', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (222, 2, '2026-10-22', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (223, 2, '2026-10-22', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (224, 2, '2026-10-22', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (225, 2, '2026-10-23', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (226, 2, '2026-10-23', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (227, 2, '2026-10-23', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (228, 2, '2026-10-23', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (229, 2, '2026-10-24', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (230, 2, '2026-10-24', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (231, 2, '2026-10-24', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (232, 2, '2026-10-24', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (233, 2, '2026-10-25', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (234, 2, '2026-10-25', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (235, 2, '2026-10-25', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (236, 2, '2026-10-25', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (237, 2, '2026-10-26', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (238, 2, '2026-10-26', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (239, 2, '2026-10-26', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (240, 2, '2026-10-26', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (241, 2, '2026-10-27', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (242, 2, '2026-10-27', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (243, 2, '2026-10-27', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (244, 2, '2026-10-27', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (245, 2, '2026-10-28', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (246, 2, '2026-10-28', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (247, 2, '2026-10-28', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (248, 2, '2026-10-28', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (249, 2, '2026-10-29', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (250, 2, '2026-10-29', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (251, 2, '2026-10-29', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (252, 2, '2026-10-29', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (253, 2, '2026-10-30', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (254, 2, '2026-10-30', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (255, 2, '2026-10-30', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (256, 2, '2026-10-30', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (257, 2, '2026-10-31', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (258, 2, '2026-10-31', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (259, 2, '2026-10-31', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (260, 2, '2026-10-31', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (261, 2, '2026-11-01', '09:00', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (262, 2, '2026-11-01', '11:00', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (263, 2, '2026-11-01', '13:00', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (264, 2, '2026-11-01', '15:00', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:34.772+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (265, 3, '2026-10-11', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (266, 3, '2026-10-11', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (267, 3, '2026-10-11', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (268, 3, '2026-10-11', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (269, 3, '2026-10-11', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (270, 3, '2026-10-12', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (271, 3, '2026-10-12', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (273, 3, '2026-10-12', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (274, 3, '2026-10-12', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (275, 3, '2026-10-13', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (276, 3, '2026-10-13', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (277, 3, '2026-10-13', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (278, 3, '2026-10-13', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (279, 3, '2026-10-13', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (280, 3, '2026-10-14', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (281, 3, '2026-10-14', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (282, 3, '2026-10-14', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (283, 3, '2026-10-14', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (284, 3, '2026-10-14', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (285, 3, '2026-10-15', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (286, 3, '2026-10-15', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (287, 3, '2026-10-15', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (288, 3, '2026-10-15', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (289, 3, '2026-10-15', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (290, 3, '2026-10-16', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (291, 3, '2026-10-16', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (221, 2, '2026-10-22', '09:00', '11:00', 1, 1, 'FULL', '2026-10-18 01:41:34.772+07', '2026-10-18 01:41:35.118+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (292, 3, '2026-10-16', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (293, 3, '2026-10-16', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (294, 3, '2026-10-16', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (295, 3, '2026-10-17', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (297, 3, '2026-10-17', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (298, 3, '2026-10-17', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (299, 3, '2026-10-17', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (300, 3, '2026-10-18', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (301, 3, '2026-10-18', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (302, 3, '2026-10-18', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (303, 3, '2026-10-18', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (304, 3, '2026-10-18', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (305, 3, '2026-10-19', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (306, 3, '2026-10-19', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (307, 3, '2026-10-19', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (308, 3, '2026-10-19', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (309, 3, '2026-10-19', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (310, 3, '2026-10-20', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (311, 3, '2026-10-20', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (312, 3, '2026-10-20', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (313, 3, '2026-10-20', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (314, 3, '2026-10-20', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (315, 3, '2026-10-21', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (316, 3, '2026-10-21', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (317, 3, '2026-10-21', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (318, 3, '2026-10-21', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (319, 3, '2026-10-21', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (320, 3, '2026-10-22', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (321, 3, '2026-10-22', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (322, 3, '2026-10-22', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (323, 3, '2026-10-22', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (324, 3, '2026-10-22', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (325, 3, '2026-10-23', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (326, 3, '2026-10-23', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (327, 3, '2026-10-23', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (328, 3, '2026-10-23', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (329, 3, '2026-10-23', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (330, 3, '2026-10-24', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (331, 3, '2026-10-24', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (332, 3, '2026-10-24', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (333, 3, '2026-10-24', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (334, 3, '2026-10-24', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (335, 3, '2026-10-25', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (336, 3, '2026-10-25', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (337, 3, '2026-10-25', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (338, 3, '2026-10-25', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (339, 3, '2026-10-25', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (340, 3, '2026-10-26', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (341, 3, '2026-10-26', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (342, 3, '2026-10-26', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (343, 3, '2026-10-26', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (344, 3, '2026-10-26', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (345, 3, '2026-10-27', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (346, 3, '2026-10-27', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (347, 3, '2026-10-27', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (348, 3, '2026-10-27', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (349, 3, '2026-10-27', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (350, 3, '2026-10-28', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (351, 3, '2026-10-28', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (352, 3, '2026-10-28', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (353, 3, '2026-10-28', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (354, 3, '2026-10-28', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (355, 3, '2026-10-29', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (356, 3, '2026-10-29', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (357, 3, '2026-10-29', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (358, 3, '2026-10-29', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (359, 3, '2026-10-29', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (360, 3, '2026-10-30', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (361, 3, '2026-10-30', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (362, 3, '2026-10-30', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (363, 3, '2026-10-30', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (364, 3, '2026-10-30', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (365, 3, '2026-10-31', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (366, 3, '2026-10-31', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (367, 3, '2026-10-31', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (368, 3, '2026-10-31', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (369, 3, '2026-10-31', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (370, 3, '2026-11-01', '09:00', '10:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (371, 3, '2026-11-01', '10:30', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (372, 3, '2026-11-01', '12:00', '13:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (373, 3, '2026-11-01', '13:30', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (374, 3, '2026-11-01', '15:00', '16:30', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.786+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (375, 4, '2026-10-11', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (376, 4, '2026-10-11', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (377, 4, '2026-10-11', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (378, 4, '2026-10-11', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (379, 4, '2026-10-11', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (380, 4, '2026-10-11', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (381, 4, '2026-10-11', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (382, 4, '2026-10-11', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (383, 4, '2026-10-12', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (384, 4, '2026-10-12', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (385, 4, '2026-10-12', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (386, 4, '2026-10-12', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (387, 4, '2026-10-12', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (388, 4, '2026-10-12', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (389, 4, '2026-10-12', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (390, 4, '2026-10-12', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (391, 4, '2026-10-13', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (392, 4, '2026-10-13', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (393, 4, '2026-10-13', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (395, 4, '2026-10-13', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (396, 4, '2026-10-13', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (397, 4, '2026-10-13', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (398, 4, '2026-10-13', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (399, 4, '2026-10-14', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (400, 4, '2026-10-14', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (401, 4, '2026-10-14', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (402, 4, '2026-10-14', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (403, 4, '2026-10-14', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (404, 4, '2026-10-14', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (405, 4, '2026-10-14', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (406, 4, '2026-10-14', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (407, 4, '2026-10-15', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (408, 4, '2026-10-15', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (409, 4, '2026-10-15', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (410, 4, '2026-10-15', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (411, 4, '2026-10-15', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (412, 4, '2026-10-15', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (413, 4, '2026-10-15', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (414, 4, '2026-10-15', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (415, 4, '2026-10-16', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (416, 4, '2026-10-16', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (417, 4, '2026-10-16', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (418, 4, '2026-10-16', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (419, 4, '2026-10-16', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (420, 4, '2026-10-16', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (421, 4, '2026-10-16', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (422, 4, '2026-10-16', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (423, 4, '2026-10-17', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (424, 4, '2026-10-17', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (425, 4, '2026-10-17', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (426, 4, '2026-10-17', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (427, 4, '2026-10-17', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (428, 4, '2026-10-17', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (429, 4, '2026-10-17', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (430, 4, '2026-10-17', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (431, 4, '2026-10-18', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (432, 4, '2026-10-18', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (433, 4, '2026-10-18', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (434, 4, '2026-10-18', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (435, 4, '2026-10-18', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (436, 4, '2026-10-18', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (437, 4, '2026-10-18', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (438, 4, '2026-10-18', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (439, 4, '2026-10-19', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (440, 4, '2026-10-19', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (442, 4, '2026-10-19', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (443, 4, '2026-10-19', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (444, 4, '2026-10-19', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (445, 4, '2026-10-19', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (446, 4, '2026-10-19', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (447, 4, '2026-10-20', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (448, 4, '2026-10-20', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (449, 4, '2026-10-20', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (450, 4, '2026-10-20', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (451, 4, '2026-10-20', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (452, 4, '2026-10-20', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (453, 4, '2026-10-20', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (454, 4, '2026-10-20', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (455, 4, '2026-10-21', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (456, 4, '2026-10-21', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (457, 4, '2026-10-21', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (458, 4, '2026-10-21', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (459, 4, '2026-10-21', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (460, 4, '2026-10-21', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (461, 4, '2026-10-21', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (462, 4, '2026-10-21', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (463, 4, '2026-10-22', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (464, 4, '2026-10-22', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (465, 4, '2026-10-22', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (466, 4, '2026-10-22', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (467, 4, '2026-10-22', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (468, 4, '2026-10-22', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (469, 4, '2026-10-22', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (470, 4, '2026-10-22', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (471, 4, '2026-10-23', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (472, 4, '2026-10-23', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (473, 4, '2026-10-23', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (474, 4, '2026-10-23', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (475, 4, '2026-10-23', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (476, 4, '2026-10-23', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (477, 4, '2026-10-23', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (478, 4, '2026-10-23', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (479, 4, '2026-10-24', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (480, 4, '2026-10-24', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (481, 4, '2026-10-24', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (482, 4, '2026-10-24', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (483, 4, '2026-10-24', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (484, 4, '2026-10-24', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (485, 4, '2026-10-24', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (441, 4, '2026-10-19', '11:00', '12:00', 2, 1, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:35.09+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (486, 4, '2026-10-24', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (487, 4, '2026-10-25', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (488, 4, '2026-10-25', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (489, 4, '2026-10-25', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (490, 4, '2026-10-25', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (491, 4, '2026-10-25', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (492, 4, '2026-10-25', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (493, 4, '2026-10-25', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (494, 4, '2026-10-25', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (495, 4, '2026-10-26', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (496, 4, '2026-10-26', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (497, 4, '2026-10-26', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (498, 4, '2026-10-26', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (499, 4, '2026-10-26', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (500, 4, '2026-10-26', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (501, 4, '2026-10-26', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (502, 4, '2026-10-26', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (503, 4, '2026-10-27', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (504, 4, '2026-10-27', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (505, 4, '2026-10-27', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (506, 4, '2026-10-27', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (507, 4, '2026-10-27', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (508, 4, '2026-10-27', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (509, 4, '2026-10-27', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (510, 4, '2026-10-27', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (511, 4, '2026-10-28', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (512, 4, '2026-10-28', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (513, 4, '2026-10-28', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (514, 4, '2026-10-28', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (515, 4, '2026-10-28', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (516, 4, '2026-10-28', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (517, 4, '2026-10-28', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (518, 4, '2026-10-28', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (519, 4, '2026-10-29', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (520, 4, '2026-10-29', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (521, 4, '2026-10-29', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (522, 4, '2026-10-29', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (523, 4, '2026-10-29', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (524, 4, '2026-10-29', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (525, 4, '2026-10-29', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (526, 4, '2026-10-29', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (527, 4, '2026-10-30', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (528, 4, '2026-10-30', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (529, 4, '2026-10-30', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (530, 4, '2026-10-30', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (531, 4, '2026-10-30', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (532, 4, '2026-10-30', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (533, 4, '2026-10-30', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (534, 4, '2026-10-30', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (535, 4, '2026-10-31', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (536, 4, '2026-10-31', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (537, 4, '2026-10-31', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (538, 4, '2026-10-31', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (539, 4, '2026-10-31', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (540, 4, '2026-10-31', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (541, 4, '2026-10-31', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (542, 4, '2026-10-31', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (543, 4, '2026-11-01', '09:00', '10:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (544, 4, '2026-11-01', '10:00', '11:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (545, 4, '2026-11-01', '11:00', '12:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (546, 4, '2026-11-01', '12:00', '13:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (547, 4, '2026-11-01', '13:00', '14:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (548, 4, '2026-11-01', '14:00', '15:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (549, 4, '2026-11-01', '15:00', '16:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (550, 4, '2026-11-01', '16:00', '17:00', 2, 0, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.807+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (551, 5, '2026-10-11', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (552, 5, '2026-10-11', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (553, 5, '2026-10-11', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (554, 5, '2026-10-11', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (555, 5, '2026-10-11', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (556, 5, '2026-10-11', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (557, 5, '2026-10-11', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (558, 5, '2026-10-11', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (559, 5, '2026-10-12', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (560, 5, '2026-10-12', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (561, 5, '2026-10-12', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (562, 5, '2026-10-12', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (563, 5, '2026-10-12', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (564, 5, '2026-10-12', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (565, 5, '2026-10-12', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (566, 5, '2026-10-12', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (567, 5, '2026-10-13', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (568, 5, '2026-10-13', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (569, 5, '2026-10-13', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (570, 5, '2026-10-13', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (571, 5, '2026-10-13', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (572, 5, '2026-10-13', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (573, 5, '2026-10-13', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (574, 5, '2026-10-13', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (575, 5, '2026-10-14', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (576, 5, '2026-10-14', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (577, 5, '2026-10-14', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (578, 5, '2026-10-14', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (579, 5, '2026-10-14', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (580, 5, '2026-10-14', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (581, 5, '2026-10-14', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (582, 5, '2026-10-14', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (583, 5, '2026-10-15', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (584, 5, '2026-10-15', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (585, 5, '2026-10-15', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (586, 5, '2026-10-15', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (587, 5, '2026-10-15', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (588, 5, '2026-10-15', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (589, 5, '2026-10-15', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (590, 5, '2026-10-15', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (591, 5, '2026-10-16', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (592, 5, '2026-10-16', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (593, 5, '2026-10-16', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (594, 5, '2026-10-16', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (595, 5, '2026-10-16', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (596, 5, '2026-10-16', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (597, 5, '2026-10-16', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (598, 5, '2026-10-16', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (599, 5, '2026-10-17', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (600, 5, '2026-10-17', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (601, 5, '2026-10-17', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (602, 5, '2026-10-17', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (603, 5, '2026-10-17', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (604, 5, '2026-10-17', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (605, 5, '2026-10-17', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (606, 5, '2026-10-17', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (607, 5, '2026-10-18', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (608, 5, '2026-10-18', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (609, 5, '2026-10-18', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (610, 5, '2026-10-18', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (611, 5, '2026-10-18', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (612, 5, '2026-10-18', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (613, 5, '2026-10-18', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (614, 5, '2026-10-18', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (615, 5, '2026-10-19', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (616, 5, '2026-10-19', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (617, 5, '2026-10-19', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (618, 5, '2026-10-19', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (619, 5, '2026-10-19', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (620, 5, '2026-10-19', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (621, 5, '2026-10-19', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (622, 5, '2026-10-19', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (623, 5, '2026-10-20', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (624, 5, '2026-10-20', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (625, 5, '2026-10-20', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (626, 5, '2026-10-20', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (627, 5, '2026-10-20', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (628, 5, '2026-10-20', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (629, 5, '2026-10-20', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (630, 5, '2026-10-20', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (631, 5, '2026-10-21', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (632, 5, '2026-10-21', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (633, 5, '2026-10-21', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (634, 5, '2026-10-21', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (635, 5, '2026-10-21', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (636, 5, '2026-10-21', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (637, 5, '2026-10-21', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (638, 5, '2026-10-21', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (639, 5, '2026-10-22', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (640, 5, '2026-10-22', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (641, 5, '2026-10-22', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (642, 5, '2026-10-22', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (643, 5, '2026-10-22', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (644, 5, '2026-10-22', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (645, 5, '2026-10-22', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (646, 5, '2026-10-22', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (647, 5, '2026-10-23', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (648, 5, '2026-10-23', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (649, 5, '2026-10-23', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (650, 5, '2026-10-23', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (651, 5, '2026-10-23', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (652, 5, '2026-10-23', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (653, 5, '2026-10-23', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (654, 5, '2026-10-23', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (655, 5, '2026-10-24', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (656, 5, '2026-10-24', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (657, 5, '2026-10-24', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (658, 5, '2026-10-24', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (659, 5, '2026-10-24', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (660, 5, '2026-10-24', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (661, 5, '2026-10-24', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (662, 5, '2026-10-24', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (663, 5, '2026-10-25', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (664, 5, '2026-10-25', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (665, 5, '2026-10-25', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (666, 5, '2026-10-25', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (667, 5, '2026-10-25', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (668, 5, '2026-10-25', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (669, 5, '2026-10-25', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (670, 5, '2026-10-25', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (671, 5, '2026-10-26', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (672, 5, '2026-10-26', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (673, 5, '2026-10-26', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (674, 5, '2026-10-26', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (675, 5, '2026-10-26', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (676, 5, '2026-10-26', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (677, 5, '2026-10-26', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (678, 5, '2026-10-26', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (679, 5, '2026-10-27', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (680, 5, '2026-10-27', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (681, 5, '2026-10-27', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (682, 5, '2026-10-27', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (683, 5, '2026-10-27', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (684, 5, '2026-10-27', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (685, 5, '2026-10-27', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (686, 5, '2026-10-27', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (687, 5, '2026-10-28', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (688, 5, '2026-10-28', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (689, 5, '2026-10-28', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (690, 5, '2026-10-28', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (691, 5, '2026-10-28', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (692, 5, '2026-10-28', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (693, 5, '2026-10-28', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (694, 5, '2026-10-28', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (695, 5, '2026-10-29', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (696, 5, '2026-10-29', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (697, 5, '2026-10-29', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (698, 5, '2026-10-29', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (699, 5, '2026-10-29', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (700, 5, '2026-10-29', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (701, 5, '2026-10-29', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (702, 5, '2026-10-29', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (703, 5, '2026-10-30', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (704, 5, '2026-10-30', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (705, 5, '2026-10-30', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (706, 5, '2026-10-30', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (707, 5, '2026-10-30', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (708, 5, '2026-10-30', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (709, 5, '2026-10-30', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (710, 5, '2026-10-30', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (711, 5, '2026-10-31', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (712, 5, '2026-10-31', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (713, 5, '2026-10-31', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (714, 5, '2026-10-31', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (715, 5, '2026-10-31', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (716, 5, '2026-10-31', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (717, 5, '2026-10-31', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (718, 5, '2026-10-31', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (719, 5, '2026-11-01', '09:00', '10:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (720, 5, '2026-11-01', '10:00', '11:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (721, 5, '2026-11-01', '11:00', '12:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (722, 5, '2026-11-01', '12:00', '13:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (723, 5, '2026-11-01', '13:00', '14:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (724, 5, '2026-11-01', '14:00', '15:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (725, 5, '2026-11-01', '15:00', '16:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (726, 5, '2026-11-01', '16:00', '17:00', 3, 0, 'AVAILABLE', '2026-10-18 01:41:34.833+07', '2026-10-18 01:41:34.833+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (727, 6, '2026-10-11', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (728, 6, '2026-10-11', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (729, 6, '2026-10-11', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (730, 6, '2026-10-11', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (731, 6, '2026-10-11', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (732, 6, '2026-10-11', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (733, 6, '2026-10-11', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (734, 6, '2026-10-11', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (735, 6, '2026-10-11', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (736, 6, '2026-10-11', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (737, 6, '2026-10-11', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (738, 6, '2026-10-11', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (739, 6, '2026-10-11', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (740, 6, '2026-10-11', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (741, 6, '2026-10-11', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (742, 6, '2026-10-11', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (743, 6, '2026-10-12', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (744, 6, '2026-10-12', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (745, 6, '2026-10-12', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (746, 6, '2026-10-12', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (747, 6, '2026-10-12', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (748, 6, '2026-10-12', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (749, 6, '2026-10-12', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (750, 6, '2026-10-12', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (751, 6, '2026-10-12', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (752, 6, '2026-10-12', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (753, 6, '2026-10-12', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (754, 6, '2026-10-12', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (755, 6, '2026-10-12', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (756, 6, '2026-10-12', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (757, 6, '2026-10-12', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (758, 6, '2026-10-12', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (759, 6, '2026-10-13', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (760, 6, '2026-10-13', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (761, 6, '2026-10-13', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (762, 6, '2026-10-13', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (763, 6, '2026-10-13', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (764, 6, '2026-10-13', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (765, 6, '2026-10-13', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (766, 6, '2026-10-13', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (767, 6, '2026-10-13', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (768, 6, '2026-10-13', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (769, 6, '2026-10-13', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (770, 6, '2026-10-13', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (771, 6, '2026-10-13', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (772, 6, '2026-10-13', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (773, 6, '2026-10-13', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (774, 6, '2026-10-13', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (775, 6, '2026-10-14', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (776, 6, '2026-10-14', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (777, 6, '2026-10-14', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (778, 6, '2026-10-14', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (779, 6, '2026-10-14', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (780, 6, '2026-10-14', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (781, 6, '2026-10-14', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (782, 6, '2026-10-14', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (783, 6, '2026-10-14', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (784, 6, '2026-10-14', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (785, 6, '2026-10-14', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (786, 6, '2026-10-14', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (787, 6, '2026-10-14', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (788, 6, '2026-10-14', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (789, 6, '2026-10-14', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (790, 6, '2026-10-14', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (791, 6, '2026-10-15', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (792, 6, '2026-10-15', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (793, 6, '2026-10-15', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (794, 6, '2026-10-15', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (795, 6, '2026-10-15', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (796, 6, '2026-10-15', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (797, 6, '2026-10-15', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (798, 6, '2026-10-15', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (799, 6, '2026-10-15', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (800, 6, '2026-10-15', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (801, 6, '2026-10-15', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (802, 6, '2026-10-15', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (803, 6, '2026-10-15', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (804, 6, '2026-10-15', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (805, 6, '2026-10-15', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (806, 6, '2026-10-15', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (807, 6, '2026-10-16', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (808, 6, '2026-10-16', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (809, 6, '2026-10-16', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (810, 6, '2026-10-16', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (811, 6, '2026-10-16', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (812, 6, '2026-10-16', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (813, 6, '2026-10-16', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (814, 6, '2026-10-16', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (815, 6, '2026-10-16', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (816, 6, '2026-10-16', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (817, 6, '2026-10-16', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (818, 6, '2026-10-16', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (819, 6, '2026-10-16', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (820, 6, '2026-10-16', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (821, 6, '2026-10-16', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (822, 6, '2026-10-16', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (823, 6, '2026-10-17', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (824, 6, '2026-10-17', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (825, 6, '2026-10-17', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (826, 6, '2026-10-17', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (827, 6, '2026-10-17', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (828, 6, '2026-10-17', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (829, 6, '2026-10-17', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (830, 6, '2026-10-17', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (831, 6, '2026-10-17', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (832, 6, '2026-10-17', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (833, 6, '2026-10-17', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (834, 6, '2026-10-17', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (835, 6, '2026-10-17', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (836, 6, '2026-10-17', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (837, 6, '2026-10-17', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (838, 6, '2026-10-17', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (839, 6, '2026-10-18', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (840, 6, '2026-10-18', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (841, 6, '2026-10-18', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (842, 6, '2026-10-18', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (843, 6, '2026-10-18', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (844, 6, '2026-10-18', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (845, 6, '2026-10-18', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (846, 6, '2026-10-18', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (847, 6, '2026-10-18', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (848, 6, '2026-10-18', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (849, 6, '2026-10-18', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (850, 6, '2026-10-18', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (851, 6, '2026-10-18', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (852, 6, '2026-10-18', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (853, 6, '2026-10-18', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (854, 6, '2026-10-18', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (855, 6, '2026-10-19', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (856, 6, '2026-10-19', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (857, 6, '2026-10-19', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (858, 6, '2026-10-19', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (859, 6, '2026-10-19', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (860, 6, '2026-10-19', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (861, 6, '2026-10-19', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (862, 6, '2026-10-19', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (863, 6, '2026-10-19', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (864, 6, '2026-10-19', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (865, 6, '2026-10-19', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (866, 6, '2026-10-19', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (867, 6, '2026-10-19', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (868, 6, '2026-10-19', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (869, 6, '2026-10-19', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (870, 6, '2026-10-19', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (871, 6, '2026-10-20', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (872, 6, '2026-10-20', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (873, 6, '2026-10-20', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (874, 6, '2026-10-20', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (875, 6, '2026-10-20', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (876, 6, '2026-10-20', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (877, 6, '2026-10-20', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (878, 6, '2026-10-20', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (879, 6, '2026-10-20', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (880, 6, '2026-10-20', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (881, 6, '2026-10-20', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (882, 6, '2026-10-20', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (883, 6, '2026-10-20', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (884, 6, '2026-10-20', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (885, 6, '2026-10-20', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (886, 6, '2026-10-20', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (887, 6, '2026-10-21', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (888, 6, '2026-10-21', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (889, 6, '2026-10-21', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (890, 6, '2026-10-21', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (892, 6, '2026-10-21', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (893, 6, '2026-10-21', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (894, 6, '2026-10-21', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (895, 6, '2026-10-21', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (896, 6, '2026-10-21', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (897, 6, '2026-10-21', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (898, 6, '2026-10-21', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (899, 6, '2026-10-21', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (900, 6, '2026-10-21', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (901, 6, '2026-10-21', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (902, 6, '2026-10-21', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (903, 6, '2026-10-22', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (904, 6, '2026-10-22', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (905, 6, '2026-10-22', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (906, 6, '2026-10-22', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (907, 6, '2026-10-22', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (908, 6, '2026-10-22', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (909, 6, '2026-10-22', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (910, 6, '2026-10-22', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (911, 6, '2026-10-22', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (912, 6, '2026-10-22', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (913, 6, '2026-10-22', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (914, 6, '2026-10-22', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (915, 6, '2026-10-22', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (916, 6, '2026-10-22', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (917, 6, '2026-10-22', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (918, 6, '2026-10-22', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (919, 6, '2026-10-23', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (920, 6, '2026-10-23', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (921, 6, '2026-10-23', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (922, 6, '2026-10-23', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (923, 6, '2026-10-23', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (924, 6, '2026-10-23', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (925, 6, '2026-10-23', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (926, 6, '2026-10-23', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (927, 6, '2026-10-23', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (928, 6, '2026-10-23', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (929, 6, '2026-10-23', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (930, 6, '2026-10-23', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (931, 6, '2026-10-23', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (932, 6, '2026-10-23', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (933, 6, '2026-10-23', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (934, 6, '2026-10-23', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (935, 6, '2026-10-24', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (936, 6, '2026-10-24', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (937, 6, '2026-10-24', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (938, 6, '2026-10-24', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (939, 6, '2026-10-24', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (940, 6, '2026-10-24', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (941, 6, '2026-10-24', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (942, 6, '2026-10-24', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (943, 6, '2026-10-24', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (944, 6, '2026-10-24', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (945, 6, '2026-10-24', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (946, 6, '2026-10-24', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (947, 6, '2026-10-24', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (948, 6, '2026-10-24', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (949, 6, '2026-10-24', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (950, 6, '2026-10-24', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (951, 6, '2026-10-25', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (952, 6, '2026-10-25', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (953, 6, '2026-10-25', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (954, 6, '2026-10-25', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (955, 6, '2026-10-25', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (956, 6, '2026-10-25', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (957, 6, '2026-10-25', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (958, 6, '2026-10-25', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (959, 6, '2026-10-25', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (960, 6, '2026-10-25', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (961, 6, '2026-10-25', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (962, 6, '2026-10-25', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (963, 6, '2026-10-25', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (964, 6, '2026-10-25', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (965, 6, '2026-10-25', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (966, 6, '2026-10-25', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (967, 6, '2026-10-26', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (968, 6, '2026-10-26', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (969, 6, '2026-10-26', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (970, 6, '2026-10-26', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (971, 6, '2026-10-26', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (972, 6, '2026-10-26', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (973, 6, '2026-10-26', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (974, 6, '2026-10-26', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (975, 6, '2026-10-26', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (976, 6, '2026-10-26', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (977, 6, '2026-10-26', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (978, 6, '2026-10-26', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (979, 6, '2026-10-26', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (980, 6, '2026-10-26', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (981, 6, '2026-10-26', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (982, 6, '2026-10-26', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (983, 6, '2026-10-27', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (984, 6, '2026-10-27', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (985, 6, '2026-10-27', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (986, 6, '2026-10-27', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (987, 6, '2026-10-27', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (988, 6, '2026-10-27', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (989, 6, '2026-10-27', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (990, 6, '2026-10-27', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (991, 6, '2026-10-27', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (992, 6, '2026-10-27', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (993, 6, '2026-10-27', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (994, 6, '2026-10-27', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (995, 6, '2026-10-27', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (996, 6, '2026-10-27', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (997, 6, '2026-10-27', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (998, 6, '2026-10-27', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (999, 6, '2026-10-28', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1000, 6, '2026-10-28', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1001, 6, '2026-10-28', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1002, 6, '2026-10-28', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1003, 6, '2026-10-28', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1004, 6, '2026-10-28', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1005, 6, '2026-10-28', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1006, 6, '2026-10-28', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1007, 6, '2026-10-28', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1008, 6, '2026-10-28', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1009, 6, '2026-10-28', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1010, 6, '2026-10-28', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1011, 6, '2026-10-28', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1012, 6, '2026-10-28', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1013, 6, '2026-10-28', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1014, 6, '2026-10-28', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1015, 6, '2026-10-29', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1016, 6, '2026-10-29', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1017, 6, '2026-10-29', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1018, 6, '2026-10-29', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1019, 6, '2026-10-29', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1020, 6, '2026-10-29', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1021, 6, '2026-10-29', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1022, 6, '2026-10-29', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1023, 6, '2026-10-29', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1024, 6, '2026-10-29', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1025, 6, '2026-10-29', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1026, 6, '2026-10-29', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1027, 6, '2026-10-29', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1028, 6, '2026-10-29', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1029, 6, '2026-10-29', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1030, 6, '2026-10-29', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1031, 6, '2026-10-30', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1032, 6, '2026-10-30', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1033, 6, '2026-10-30', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1034, 6, '2026-10-30', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1035, 6, '2026-10-30', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1036, 6, '2026-10-30', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1037, 6, '2026-10-30', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1038, 6, '2026-10-30', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1039, 6, '2026-10-30', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1040, 6, '2026-10-30', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1041, 6, '2026-10-30', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1042, 6, '2026-10-30', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1043, 6, '2026-10-30', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1044, 6, '2026-10-30', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1045, 6, '2026-10-30', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1046, 6, '2026-10-30', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1047, 6, '2026-10-31', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1048, 6, '2026-10-31', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1049, 6, '2026-10-31', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1050, 6, '2026-10-31', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1051, 6, '2026-10-31', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1052, 6, '2026-10-31', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1053, 6, '2026-10-31', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1054, 6, '2026-10-31', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1055, 6, '2026-10-31', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1056, 6, '2026-10-31', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1057, 6, '2026-10-31', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1058, 6, '2026-10-31', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1059, 6, '2026-10-31', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1060, 6, '2026-10-31', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1061, 6, '2026-10-31', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1062, 6, '2026-10-31', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1063, 6, '2026-11-01', '09:00', '09:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1064, 6, '2026-11-01', '09:30', '10:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1065, 6, '2026-11-01', '10:00', '10:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1066, 6, '2026-11-01', '10:30', '11:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1067, 6, '2026-11-01', '11:00', '11:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1068, 6, '2026-11-01', '11:30', '12:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1069, 6, '2026-11-01', '12:00', '12:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1070, 6, '2026-11-01', '12:30', '13:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1071, 6, '2026-11-01', '13:00', '13:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1072, 6, '2026-11-01', '13:30', '14:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1073, 6, '2026-11-01', '14:00', '14:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1074, 6, '2026-11-01', '14:30', '15:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1075, 6, '2026-11-01', '15:00', '15:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1076, 6, '2026-11-01', '15:30', '16:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1077, 6, '2026-11-01', '16:00', '16:30', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (1078, 6, '2026-11-01', '16:30', '17:00', 1, 0, 'AVAILABLE', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:34.855+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (10, 1, '2026-10-12', '10:00', '11:00', 2, 1, 'AVAILABLE', '2026-10-18 01:41:34.733+07', '2026-10-18 01:41:34.937+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (272, 3, '2026-10-12', '12:00', '13:30', 2, 1, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:34.964+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (394, 4, '2026-10-13', '12:00', '13:00', 2, 1, 'AVAILABLE', '2026-10-18 01:41:34.807+07', '2026-10-18 01:41:34.991+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (296, 3, '2026-10-17', '10:30', '12:00', 2, 1, 'AVAILABLE', '2026-10-18 01:41:34.786+07', '2026-10-18 01:41:35.072+07');
INSERT INTO public.schedules (id, service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at) VALUES (891, 6, '2026-10-21', '11:00', '11:30', 1, 1, 'FULL', '2026-10-18 01:41:34.855+07', '2026-10-18 01:41:35.108+07');


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
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.services (id, category_id, name, description, price, duration_minutes, status, image_url, created_at, updated_at, deleted_at) VALUES (1, 1, 'Haircut & Styling', 'Haircut, wash and styling by a senior stylist.', 75000.00, 60, 'ACTIVE', NULL, '2026-10-18 01:41:34.716+07', '2026-10-18 01:41:34.716+07', NULL);
INSERT INTO public.services (id, category_id, name, description, price, duration_minutes, status, image_url, created_at, updated_at, deleted_at) VALUES (2, 1, 'Hair Coloring', 'Full hair coloring with premium products.', 250000.00, 120, 'ACTIVE', NULL, '2026-10-18 01:41:34.721+07', '2026-10-18 01:41:34.721+07', NULL);
INSERT INTO public.services (id, category_id, name, description, price, duration_minutes, status, image_url, created_at, updated_at, deleted_at) VALUES (3, 2, 'Balinese Massage', 'Traditional full body massage.', 180000.00, 90, 'ACTIVE', NULL, '2026-10-18 01:41:34.723+07', '2026-10-18 01:41:34.723+07', NULL);
INSERT INTO public.services (id, category_id, name, description, price, duration_minutes, status, image_url, created_at, updated_at, deleted_at) VALUES (4, 2, 'Facial Treatment', 'Deep cleansing facial for all skin types.', 150000.00, 60, 'ACTIVE', NULL, '2026-10-18 01:41:34.725+07', '2026-10-18 01:41:34.725+07', NULL);
INSERT INTO public.services (id, category_id, name, description, price, duration_minutes, status, image_url, created_at, updated_at, deleted_at) VALUES (5, 3, 'Manicure & Pedicure', 'Nail cleaning, shaping and polish.', 120000.00, 60, 'ACTIVE', NULL, '2026-10-18 01:41:34.727+07', '2026-10-18 01:41:34.727+07', NULL);
INSERT INTO public.services (id, category_id, name, description, price, duration_minutes, status, image_url, created_at, updated_at, deleted_at) VALUES (6, 4, 'Beauty Consultation', 'One on one consultation with a beauty expert.', 50000.00, 30, 'ACTIVE', NULL, '2026-10-18 01:41:34.73+07', '2026-10-18 01:41:34.73+07', NULL);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (id, name, email, phone, password_hash, role, is_active, created_at, updated_at) VALUES ('676e3705-4e5b-4a84-a2b2-959f93790941', 'Admin Booking', 'admin@booking.com', '081100000001', '$2a$10$XyEUOKOWN5G5bu9YTVOZMuUaDXJWzkE4YfgOzyNoa2xzvCZ/neV3G', 'ADMIN', true, '2026-10-18 01:41:34.685+07', '2026-10-18 01:41:34.685+07');
INSERT INTO public.users (id, name, email, phone, password_hash, role, is_active, created_at, updated_at) VALUES ('11dc6b8a-4ff0-45aa-ba2f-1396b8bde472', 'Budi Santoso', 'budi@example.com', '081234567890', '$2a$10$MSynIRJ2BPECN/vboQ5ULeckkCfJPqk9dlUrqxJw0MEivhCWttt0u', 'USER', true, '2026-10-18 01:41:34.705+07', '2026-10-18 01:41:34.705+07');
INSERT INTO public.users (id, name, email, phone, password_hash, role, is_active, created_at, updated_at) VALUES ('cf5973aa-96c9-4e60-bbcd-ec91b31e7e9d', 'Siti Rahma', 'siti@example.com', '081298765432', '$2a$10$MSynIRJ2BPECN/vboQ5ULeckkCfJPqk9dlUrqxJw0MEivhCWttt0u', 'USER', true, '2026-10-18 01:41:34.705+07', '2026-10-18 01:41:34.705+07');


--
-- Name: booking_status_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_status_logs_id_seq', 26, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 4, true);


--
-- Name: schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.schedules_id_seq', 1078, true);


--
-- Name: services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.services_id_seq', 6, true);


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


