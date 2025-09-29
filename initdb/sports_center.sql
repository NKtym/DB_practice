--
-- PostgreSQL database dump
--

\restrict IcyIPtOq9QHy6BxxaCT6Hof3jWhCXGHYQtQFOIBbm0lkVl9Ef5JEK3poP2JYDHF

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

-- Started on 2025-09-23 17:06:26 +07

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
-- TOC entry 852 (class 1247 OID 16396)
-- Name: card_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.card_status AS ENUM (
    'ACTIVE',
    'SUSPENDED'
);


ALTER TYPE public.card_status OWNER TO postgres;

--
-- TOC entry 858 (class 1247 OID 16402)
-- Name: payment_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.payment_type AS ENUM (
    'CASH',
    'CARD'
);


ALTER TYPE public.payment_type OWNER TO postgres;

--
-- TOC entry 849 (class 1247 OID 16394)
-- Name: role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.role AS ENUM (
    'ADMIN',
    'TRAINER',
    'MANAGER',
    'ACCOUNTANT',
    'JANITOR'
);


ALTER TYPE public.role OWNER TO postgres;

--
-- TOC entry 900 (class 1247 OID 16728)
-- Name: slot_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.slot_status AS ENUM (
    'PLANNED',
    'CANCELLED',
    'DONE'
);


ALTER TYPE public.slot_status OWNER TO postgres;

--
-- TOC entry 855 (class 1247 OID 16398)
-- Name: zone_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.zone_status AS ENUM (
    'FREE',
    'OCCUPIED'
);


ALTER TYPE public.zone_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16427)
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    client_id uuid NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    phone character varying NOT NULL,
    registration_date date NOT NULL,
    card_status public.card_status NOT NULL,
    preference character varying,
    emerhency_contact character varying
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16408)
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    employee_id uuid NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    login character varying NOT NULL,
    password character varying NOT NULL,
    role public.role NOT NULL,
    salary_rate integer NOT NULL,
    hire_date date NOT NULL
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16443)
-- Name: equipments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipments (
    equipment_id uuid NOT NULL,
    inventory_num integer NOT NULL,
    name character varying NOT NULL,
    buy_date date NOT NULL,
    garant_date date NOT NULL,
    zone_id uuid NOT NULL
);


ALTER TABLE public.equipments OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16469)
-- Name: group_clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_clients (
    group_id uuid NOT NULL,
    client_id uuid NOT NULL
);


ALTER TABLE public.group_clients OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16457)
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    group_id uuid NOT NULL,
    name character varying NOT NULL,
    trainer_id uuid NOT NULL
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16403)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id uuid NOT NULL,
    base_price integer NOT NULL,
    product_type character varying NOT NULL,
    category character varying NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16484)
-- Name: slots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slots (
    slot_id uuid NOT NULL,
    start_datatime date NOT NULL,
    end_datatime date NOT NULL,
    zone_id uuid NOT NULL,
    current_capacity integer NOT NULL,
    max_capacity integer NOT NULL,
    group_id uuid NOT NULL,
    status public.slot_status NOT NULL
);


ALTER TABLE public.slots OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16541)
-- Name: subscription_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscription_products (
    subscription_id uuid NOT NULL,
    product_id uuid NOT NULL
);


ALTER TABLE public.subscription_products OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16524)
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriptions (
    subscription_id uuid NOT NULL,
    sale_date date NOT NULL,
    activation_date date NOT NULL,
    total_price integer NOT NULL,
    terms character varying,
    client_id uuid NOT NULL,
    transaction_id uuid NOT NULL
);


ALTER TABLE public.subscriptions OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16504)
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    transaction_id uuid NOT NULL,
    datatime date NOT NULL,
    total_amount integer NOT NULL,
    employee_id uuid NOT NULL,
    payment_type public.payment_type NOT NULL,
    client_id uuid NOT NULL,
    product_id uuid NOT NULL
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16556)
-- Name: visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visits (
    visit_id uuid NOT NULL,
    visit_in date NOT NULL,
    visit_out date,
    slot_id uuid NOT NULL,
    subscription_id uuid NOT NULL
);


ALTER TABLE public.visits OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16417)
-- Name: work_schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_schedules (
    schedule_id uuid NOT NULL,
    employee_id uuid NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    date date NOT NULL
);


ALTER TABLE public.work_schedules OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16436)
-- Name: zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zones (
    zone_id uuid NOT NULL,
    type character varying NOT NULL,
    status public.zone_status NOT NULL
);


ALTER TABLE public.zones OWNER TO postgres;

--
-- TOC entry 3456 (class 0 OID 16427)
-- Dependencies: 217
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3454 (class 0 OID 16408)
-- Dependencies: 215
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3458 (class 0 OID 16443)
-- Dependencies: 219
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3460 (class 0 OID 16469)
-- Dependencies: 221
-- Data for Name: group_clients; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3459 (class 0 OID 16457)
-- Dependencies: 220
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3453 (class 0 OID 16403)
-- Dependencies: 214
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3461 (class 0 OID 16484)
-- Dependencies: 222
-- Data for Name: slots; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3464 (class 0 OID 16541)
-- Dependencies: 225
-- Data for Name: subscription_products; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3463 (class 0 OID 16524)
-- Dependencies: 224
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3462 (class 0 OID 16504)
-- Dependencies: 223
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3465 (class 0 OID 16556)
-- Dependencies: 226
-- Data for Name: visits; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3455 (class 0 OID 16417)
-- Dependencies: 216
-- Data for Name: work_schedules; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3457 (class 0 OID 16436)
-- Dependencies: 218
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3270 (class 2606 OID 16435)
-- Name: clients clients_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_phone_key UNIQUE (phone);


--
-- TOC entry 3272 (class 2606 OID 16433)
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- TOC entry 3264 (class 2606 OID 16416)
-- Name: employees employees_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_login_key UNIQUE (login);


--
-- TOC entry 3266 (class 2606 OID 16414)
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 3276 (class 2606 OID 16451)
-- Name: equipments equipments_inventory_num_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_inventory_num_key UNIQUE (inventory_num);


--
-- TOC entry 3278 (class 2606 OID 16449)
-- Name: equipments equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_pkey PRIMARY KEY (equipment_id);


--
-- TOC entry 3282 (class 2606 OID 16473)
-- Name: group_clients group_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_clients
    ADD CONSTRAINT group_clients_pkey PRIMARY KEY (group_id, client_id);


--
-- TOC entry 3280 (class 2606 OID 16463)
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (group_id);


--
-- TOC entry 3286 (class 2606 OID 16508)
-- Name: transactions orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT orders_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 3262 (class 2606 OID 16407)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- TOC entry 3284 (class 2606 OID 16488)
-- Name: slots slots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slots
    ADD CONSTRAINT slots_pkey PRIMARY KEY (slot_id);


--
-- TOC entry 3292 (class 2606 OID 16545)
-- Name: subscription_products subscription_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_products
    ADD CONSTRAINT subscription_products_pkey PRIMARY KEY (subscription_id, product_id);


--
-- TOC entry 3288 (class 2606 OID 16530)
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (subscription_id);


--
-- TOC entry 3290 (class 2606 OID 16633)
-- Name: subscriptions unq_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT unq_order UNIQUE (transaction_id);


--
-- TOC entry 3294 (class 2606 OID 16560)
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (visit_id);


--
-- TOC entry 3268 (class 2606 OID 16421)
-- Name: work_schedules work_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_schedules
    ADD CONSTRAINT work_schedules_pkey PRIMARY KEY (schedule_id);


--
-- TOC entry 3274 (class 2606 OID 16442)
-- Name: zones zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (zone_id);


--
-- TOC entry 3296 (class 2606 OID 16452)
-- Name: equipments equipments_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.zones(zone_id) ON DELETE SET NULL;


--
-- TOC entry 3300 (class 2606 OID 16627)
-- Name: slots fk_slots_groups; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slots
    ADD CONSTRAINT fk_slots_groups FOREIGN KEY (group_id) REFERENCES public.groups(group_id);


--
-- TOC entry 3298 (class 2606 OID 16479)
-- Name: group_clients group_clients_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_clients
    ADD CONSTRAINT group_clients_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON DELETE CASCADE;


--
-- TOC entry 3299 (class 2606 OID 16474)
-- Name: group_clients group_clients_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_clients
    ADD CONSTRAINT group_clients_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(group_id) ON DELETE CASCADE;


--
-- TOC entry 3297 (class 2606 OID 16464)
-- Name: groups groups_trainer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.employees(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3302 (class 2606 OID 16514)
-- Name: transactions orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON DELETE CASCADE;


--
-- TOC entry 3303 (class 2606 OID 16509)
-- Name: transactions orders_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT orders_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id) ON DELETE SET NULL;


--
-- TOC entry 3304 (class 2606 OID 16519)
-- Name: transactions orders_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT orders_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- TOC entry 3301 (class 2606 OID 16494)
-- Name: slots slots_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slots
    ADD CONSTRAINT slots_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.zones(zone_id) ON DELETE SET NULL;


--
-- TOC entry 3307 (class 2606 OID 16551)
-- Name: subscription_products subscription_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_products
    ADD CONSTRAINT subscription_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- TOC entry 3308 (class 2606 OID 16546)
-- Name: subscription_products subscription_products_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_products
    ADD CONSTRAINT subscription_products_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(subscription_id) ON DELETE CASCADE;


--
-- TOC entry 3305 (class 2606 OID 16531)
-- Name: subscriptions subscriptions_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON DELETE CASCADE;


--
-- TOC entry 3306 (class 2606 OID 16536)
-- Name: subscriptions subscriptions_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_order_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(transaction_id) ON DELETE CASCADE;


--
-- TOC entry 3309 (class 2606 OID 16571)
-- Name: visits visits_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.slots(slot_id) ON DELETE SET NULL;


--
-- TOC entry 3310 (class 2606 OID 16576)
-- Name: visits visits_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(subscription_id) ON DELETE SET NULL;


--
-- TOC entry 3295 (class 2606 OID 16422)
-- Name: work_schedules work_schedules_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_schedules
    ADD CONSTRAINT work_schedules_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner

CREATE ROLE simple_user LOGIN PASSWORD '112233';
GRANT CONNECT ON DATABASE sports_center TO simple_user;
GRANT USAGE ON SCHEMA public TO simple_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO simple_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO simple_user;
--

GRANT USAGE ON SCHEMA public TO simple_user;


--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE clients; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.clients TO simple_user;


--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE employees; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.employees TO simple_user;


--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE equipments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.equipments TO simple_user;


--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE group_clients; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.group_clients TO simple_user;


--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE groups; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.groups TO simple_user;


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE products; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.products TO simple_user;


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE slots; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.slots TO simple_user;


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE subscription_products; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.subscription_products TO simple_user;


--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE subscriptions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.subscriptions TO simple_user;


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE transactions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.transactions TO simple_user;


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE visits; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.visits TO simple_user;


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE work_schedules; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.work_schedules TO simple_user;


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE zones; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.zones TO simple_user;


-- Completed on 2025-09-23 17:06:27 +07

--
-- PostgreSQL database dump complete
--

\unrestrict IcyIPtOq9QHy6BxxaCT6Hof3jWhCXGHYQtQFOIBbm0lkVl9Ef5JEK3poP2JYDHF

