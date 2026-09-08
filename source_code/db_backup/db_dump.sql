--
-- PostgreSQL database dump
--

\restrict ZEk1VUGdh7mmZHNI7pjWCeQBdjU2qngFKhIqIqbztn3SZWTvo3ltpUHQ8xI7Awb

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: uTS9w2eoB9Ru
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO "uTS9w2eoB9Ru";

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: uTS9w2eoB9Ru
--

COMMENT ON SCHEMA public IS '';


--
-- Name: KycStatus; Type: TYPE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TYPE public."KycStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."KycStatus" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Role; Type: TYPE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TYPE public."Role" AS ENUM (
    'USER',
    'ADMIN',
    'SUPERUSER'
);


ALTER TYPE public."Role" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: TransactionStatus; Type: TYPE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TYPE public."TransactionStatus" AS ENUM (
    'PENDING',
    'COMPLETED',
    'FAILED'
);


ALTER TYPE public."TransactionStatus" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: TransactionType; Type: TYPE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TYPE public."TransactionType" AS ENUM (
    'DEPOSIT',
    'WITHDRAWAL',
    'TRADE_BUY',
    'TRADE_SELL',
    'TRADE_WIN',
    'TRADE_LOSS'
);


ALTER TYPE public."TransactionType" OWNER TO "uTS9w2eoB9Ru";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AdminWallet; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."AdminWallet" (
    id integer NOT NULL,
    network text NOT NULL,
    address text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."AdminWallet" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: AdminWallet_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."AdminWallet_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."AdminWallet_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: AdminWallet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."AdminWallet_id_seq" OWNED BY public."AdminWallet".id;


--
-- Name: AuditLog; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."AuditLog" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "userEmail" text NOT NULL,
    "userName" text,
    action text NOT NULL,
    "ipAddress" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."AuditLog" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: AuditLog_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."AuditLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."AuditLog_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: AuditLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."AuditLog_id_seq" OWNED BY public."AuditLog".id;


--
-- Name: ChatMessage; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."ChatMessage" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    sender text NOT NULL,
    message text NOT NULL,
    read boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ChatMessage" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: ChatMessage_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."ChatMessage_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ChatMessage_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: ChatMessage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."ChatMessage_id_seq" OWNED BY public."ChatMessage".id;


--
-- Name: Kyc; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."Kyc" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    status public."KycStatus" DEFAULT 'PENDING'::public."KycStatus" NOT NULL,
    "documentUrl" text,
    "documentUrlBack" text,
    "fullName" text,
    "idNumber" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Kyc" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Kyc_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."Kyc_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Kyc_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Kyc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."Kyc_id_seq" OWNED BY public."Kyc".id;


--
-- Name: Session; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."Session" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "lastActivity" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Session" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Session_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."Session_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Session_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."Session_id_seq" OWNED BY public."Session".id;


--
-- Name: TradingDuration; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."TradingDuration" (
    id integer NOT NULL,
    seconds integer NOT NULL,
    percentage double precision DEFAULT 80 NOT NULL,
    "minBalance" double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public."TradingDuration" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: TradingDuration_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."TradingDuration_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."TradingDuration_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: TradingDuration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."TradingDuration_id_seq" OWNED BY public."TradingDuration".id;


--
-- Name: Transaction; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."Transaction" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    amount double precision NOT NULL,
    price double precision,
    "coinSymbol" text,
    type public."TransactionType" NOT NULL,
    status public."TransactionStatus" DEFAULT 'PENDING'::public."TransactionStatus" NOT NULL,
    "targetAddress" text,
    "proofUrl" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Transaction" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."Transaction_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Transaction_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."Transaction_id_seq" OWNED BY public."Transaction".id;


--
-- Name: User; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."User" (
    id integer NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    name text,
    role public."Role" DEFAULT 'USER'::public."Role" NOT NULL,
    "profitMode" text DEFAULT 'random'::text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "tokenVersion" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."User" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."User_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- Name: Wallet; Type: TABLE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE TABLE public."Wallet" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    balance double precision DEFAULT 0.0 NOT NULL,
    assets jsonb DEFAULT '{}'::jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Wallet" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Wallet_id_seq; Type: SEQUENCE; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE SEQUENCE public."Wallet_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Wallet_id_seq" OWNER TO "uTS9w2eoB9Ru";

--
-- Name: Wallet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER SEQUENCE public."Wallet_id_seq" OWNED BY public."Wallet".id;


--
-- Name: AdminWallet id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."AdminWallet" ALTER COLUMN id SET DEFAULT nextval('public."AdminWallet_id_seq"'::regclass);


--
-- Name: AuditLog id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."AuditLog" ALTER COLUMN id SET DEFAULT nextval('public."AuditLog_id_seq"'::regclass);


--
-- Name: ChatMessage id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."ChatMessage" ALTER COLUMN id SET DEFAULT nextval('public."ChatMessage_id_seq"'::regclass);


--
-- Name: Kyc id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Kyc" ALTER COLUMN id SET DEFAULT nextval('public."Kyc_id_seq"'::regclass);


--
-- Name: Session id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Session" ALTER COLUMN id SET DEFAULT nextval('public."Session_id_seq"'::regclass);


--
-- Name: TradingDuration id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."TradingDuration" ALTER COLUMN id SET DEFAULT nextval('public."TradingDuration_id_seq"'::regclass);


--
-- Name: Transaction id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Transaction" ALTER COLUMN id SET DEFAULT nextval('public."Transaction_id_seq"'::regclass);


--
-- Name: User id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- Name: Wallet id; Type: DEFAULT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Wallet" ALTER COLUMN id SET DEFAULT nextval('public."Wallet_id_seq"'::regclass);


--
-- Data for Name: AdminWallet; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."AdminWallet" (id, network, address, "createdAt", "updatedAt") FROM stdin;
1	BTC	19rEvUZZjYJcALwhnxb2iMnvGdwAf5fjid	2026-03-04 18:50:39.953	2026-07-11 02:14:21.307
2	ETH	0xaf35b7402d3db4bc57c77782fda8e5192631d7b8	2026-03-04 18:50:39.96	2026-07-11 02:14:21.311
3	USDT_ERC20	0xaf35b7402d3db4bc57c77782fda8e5192631d7b8	2026-03-04 18:50:39.962	2026-07-11 02:14:21.312
4	USDT_TRC20	TCbk3i9dmvGz3shUFpDsfAteQsCK67VkG5	2026-03-04 18:50:39.964	2026-07-11 02:14:21.313
5	USDC	0xaf35b7402d3db4bc57c77782fda8e5192631d7b8	2026-03-04 18:50:39.966	2026-07-11 02:14:21.314
\.


--
-- Data for Name: AuditLog; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."AuditLog" (id, "userId", "userEmail", "userName", action, "ipAddress", "createdAt") FROM stdin;
40	9	wawong77@mycoinflips.com	Admin	Rejected a withdrawal of $123 for Anna Smith (Annasmith15@gmail.com)	59.153.130.242	2026-06-23 02:01:10.198
41	9	wawong77@mycoinflips.com	Admin	Approved a withdrawal of $12 for Mark Vogel (mvpantallica@gmail.com)	104.28.156.136	2026-06-23 02:15:19.79
42	9	wawong77@mycoinflips.com	Admin	Rejected a withdrawal of $50 for Mark Vogel (mvpantallica@gmail.com)	59.153.130.242	2026-06-25 07:46:25.508
43	9	wawong77@mycoinflips.com	Admin	Rejected a withdrawal of $500 for Mark Vogel (mvpantallica@gmail.com)	59.153.130.242	2026-06-25 07:46:26.142
2	8	tkenrsi@mycoinflips.com	Admin	Updated the cryptocurrency deposit addresses for the system	153.124.163.253	2026-06-03 03:26:35.009
3	9	wawong77@mycoinflips.com	Admin	Set the balance of Baylan Yuen (baylany@gmail.com) to $1314065	153.124.163.253	2026-06-04 15:08:13.674
4	9	wawong77@mycoinflips.com	Admin	Set the balance of Michael Schultz (niveabutter779@gmail.com) to $230	104.28.163.235	2026-06-06 05:09:16.845
1	9	wawong77@mycoinflips.com	Admin	Changed the block status of SADF akshana (juripeli@denipl.net)	153.124.163.253	2026-06-02 07:28:52.553
5	9	wawong77@mycoinflips.com	Admin	Set the balance of Mark Vogel (mvpantallica@gmail.com) to $10000	153.124.163.253	2026-06-07 13:11:13.44
6	9	wawong77@mycoinflips.com	Admin	Set the balance of Mark Vogel (mvpantallica@gmail.com) to $0	153.124.163.253	2026-06-07 13:11:20.117
7	9	wawong77@mycoinflips.com	Admin	Set the balance of Griffin  Johnson (griffinjo77@gmail.com) to $10000	153.124.163.253	2026-06-07 13:11:28.084
8	9	wawong77@mycoinflips.com	Admin	Set Griffin  Johnson (griffinjo77@gmail.com) to always win trades	104.28.163.232	2026-06-07 13:33:41.496
9	9	wawong77@mycoinflips.com	Admin	Set Griffin  Johnson (griffinjo77@gmail.com) to always lose trades	104.28.163.232	2026-06-07 13:34:30.486
10	9	wawong77@mycoinflips.com	Admin	Set Griffin  Johnson (griffinjo77@gmail.com) to win/lose trades randomly	104.28.163.232	2026-06-07 13:34:31.552
11	9	wawong77@mycoinflips.com	Admin	Set Griffin  Johnson (griffinjo77@gmail.com) to always win trades	104.28.163.232	2026-06-07 13:42:27.885
12	9	wawong77@mycoinflips.com	Admin	Set Griffin  Johnson (griffinjo77@gmail.com) to win/lose trades randomly	104.28.163.232	2026-06-07 13:44:09.925
13	8	tkenrsi@mycoinflips.com	Admin	Updated the cryptocurrency deposit addresses for the system	153.124.163.253	2026-06-08 06:35:57.749
14	8	tkenrsi@mycoinflips.com	Admin	Updated the cryptocurrency deposit addresses for the system	153.124.163.253	2026-06-08 06:39:08.061
15	8	tkenrsi@mycoinflips.com	Admin	Updated the cryptocurrency deposit addresses for the system	153.124.163.253	2026-06-08 06:39:21.552
16	8	tkenrsi@mycoinflips.com	Admin	Updated the cryptocurrency deposit addresses for the system	153.124.163.253	2026-06-08 06:39:27.843
17	8	tkenrsi@mycoinflips.com	Admin	Updated the cryptocurrency deposit addresses for the system	153.124.163.253	2026-06-08 06:39:43.511
18	8	tkenrsi@mycoinflips.com	Admin	Updated the cryptocurrency deposit addresses for the system	153.124.163.253	2026-06-08 06:39:54.878
19	9	wawong77@mycoinflips.com	Admin	Set the balance of Baylan Yuen (baylany@gmail.com) to $1314565	153.124.163.253	2026-06-09 05:48:10.742
20	9	wawong77@mycoinflips.com	Admin	Set Michael Schultz (niveabutter779@gmail.com) to always win trades	153.124.163.253	2026-06-10 03:34:41.382
21	9	wawong77@mycoinflips.com	Admin	Set Michael Schultz (niveabutter779@gmail.com) to win/lose trades randomly	153.124.163.253	2026-06-10 03:34:42.232
22	9	wawong77@mycoinflips.com	Admin	Set Michael Schultz (niveabutter779@gmail.com) to always lose trades	153.124.163.253	2026-06-10 03:34:42.613
23	9	wawong77@mycoinflips.com	Admin	Rejected a withdrawal of $20000 for Anna Smith (Annasmith15@gmail.com)	153.124.163.253	2026-06-11 08:59:43.558
24	9	wawong77@mycoinflips.com	Admin	Rejected a deposit of $140 for Anna Smith (Annasmith15@gmail.com)	153.124.163.253	2026-06-14 12:16:51.104
25	9	wawong77@mycoinflips.com	Admin	Approved a deposit of $140 for Mark Vogel (mvpantallica@gmail.com)	104.28.160.162	2026-06-14 12:19:30.629
26	9	wawong77@mycoinflips.com	Admin	Approved a deposit of $101 for Mark Vogel (mvpantallica@gmail.com)	104.28.160.162	2026-06-14 12:30:56.283
27	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to always win trades	104.28.160.162	2026-06-14 12:43:14.41
28	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to win/lose trades randomly	104.28.160.162	2026-06-14 12:43:17.095
29	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to always win trades	104.28.160.162	2026-06-14 12:43:17.542
30	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to always win trades	104.28.160.162	2026-06-14 12:43:35.318
31	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to win/lose trades randomly	104.28.160.162	2026-06-14 12:54:08.867
32	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to always lose trades	104.28.160.162	2026-06-14 12:54:09.867
33	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to win/lose trades randomly	104.28.160.162	2026-06-14 12:54:18.888
34	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to always lose trades	104.28.160.162	2026-06-14 13:33:07.004
35	9	wawong77@mycoinflips.com	Admin	Approved a withdrawal of $30000 for Baylan Yuen (baylany@gmail.com)	59.153.130.189	2026-06-16 03:04:13.281
36	9	wawong77@mycoinflips.com	Admin	Approved a deposit of $120 for Mark Vogel (mvpantallica@gmail.com)	59.153.130.242	2026-06-23 00:22:22.91
37	9	wawong77@mycoinflips.com	Admin	Approved a deposit of $101 for Mark Vogel (mvpantallica@gmail.com)	59.153.130.242	2026-06-23 00:50:58.251
38	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to always win trades	59.153.130.242	2026-06-23 01:28:00.548
39	9	wawong77@mycoinflips.com	Admin	Set Mark Vogel (mvpantallica@gmail.com) to always lose trades	59.153.130.242	2026-06-23 01:29:46.523
44	9	wawong77@mycoinflips.com	Admin	Approved a deposit of $486 for Kai Connally (kai.connally@gmail.com)	59.153.130.242	2026-06-29 11:12:20.787
45	9	wawong77@mycoinflips.com	Admin	Set Kai Connally (kai.connally@gmail.com) to always win trades	59.153.130.242	2026-06-29 15:13:46.396
46	9	wawong77@mycoinflips.com	Admin	Set Kai Connally (kai.connally@gmail.com) to always lose trades	59.153.130.242	2026-06-30 00:29:29.57
47	9	wawong77@mycoinflips.com	Admin	Set the balance of Kai Connally (kai.connally@gmail.com) to $173147.99	202.58.194.36, 104.22.66.32	2026-07-11 02:10:28.848
48	8	tkenrsi@mycoinflips.com	Admin	Updated the cryptocurrency deposit addresses for the system	202.58.194.36, 172.71.124.176	2026-07-11 02:14:21.316
49	9	wawong77@mycoinflips.com	Admin	Set Kai Connally (kai.connally@gmail.com) to always win trades	202.58.194.36, 172.70.142.53	2026-07-11 02:59:36.062
50	9	wawong77@mycoinflips.com	Admin	Set the balance of Kai Connally (kai.connally@gmail.com) to $2282182.9	202.58.194.36, 162.158.108.170	2026-07-11 03:40:38.126
51	9	wawong77@mycoinflips.com	Admin	Set the balance of Anna Smith (Annasmith15@gmail.com) to $39660069	202.58.194.36, 172.69.176.24	2026-07-11 03:50:37.404
52	9	wawong77@mycoinflips.com	Admin	Approved the identity verification (KYC) request for Kai Connally (kai.connally@gmail.com)	202.58.194.36, 172.71.124.176	2026-07-11 05:40:09.629
53	9	wawong77@mycoinflips.com	Admin	Rejected a withdrawal of $450 for Mark Vogel (mvpantallica@gmail.com)	202.58.194.36, 172.70.142.53	2026-07-11 05:47:18.251
54	9	wawong77@mycoinflips.com	Admin	Approved a deposit of $124980.22 for Kai Connally (kai.connally@gmail.com)	2001:e68:5452:b49:99cb:871:20d4:128e, 172.69.166.102	2026-07-16 15:09:55.068
55	9	wawong77@mycoinflips.com	Admin	Set the balance of Kai Connally (kai.connally@gmail.com) to $266182.9	2001:e68:5452:b49:99cb:871:20d4:128e, 172.69.166.102	2026-07-16 15:10:26.78
56	9	wawong77@mycoinflips.com	Admin	Approved a deposit of $123094.16 for Kai Connally (kai.connally@gmail.com)	2001:e68:5452:b49:a9fe:f1ae:b0e2:b9c2, 172.70.208.42	2026-07-17 01:10:05.331
57	9	wawong77@mycoinflips.com	Admin	Set the balance of Kai Connally (kai.connally@gmail.com) to $266182.9	2001:e68:5452:b49:a9fe:f1ae:b0e2:b9c2, 172.70.208.42	2026-07-17 01:10:18.479
\.


--
-- Data for Name: ChatMessage; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."ChatMessage" (id, "userId", sender, message, read, "createdAt") FROM stdin;
\.


--
-- Data for Name: Kyc; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Kyc" (id, "userId", status, "documentUrl", "documentUrlBack", "fullName", "idNumber", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Session; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Session" (id, "userId", token, "expiresAt", "createdAt", "lastActivity") FROM stdin;
\.


--
-- Data for Name: TradingDuration; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."TradingDuration" (id, seconds, percentage, "minBalance") FROM stdin;
5	30	10	100
6	60	20	5000
7	120	40	15000
8	180	60	50000
9	240	80	200000
10	300	100	1000000
\.


--
-- Data for Name: Transaction; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Transaction" (id, "userId", amount, price, "coinSymbol", type, status, "targetAddress", "proofUrl", "createdAt") FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."User" (id, email, password, name, role, "profitMode", status, "createdAt", "updatedAt", "tokenVersion") FROM stdin;
39	tkenrsi@mcfoption.com	$2b$10$PkyjhqZmhlAxFflQrZnyyOWI3qNhmW2hsIN9ta3ckHcyB1633aCiW	tkeNRSI	SUPERUSER	random	active	2026-09-08 00:49:53.314	2026-09-08 00:49:53.314	0
40	zhuang@mcfoption.com	$2b$10$hFIpyo/Z7pI19YjU0uiXFeoDt4ajHlKn9a9.VJjPanPPDmmWXJslS	zhuang	ADMIN	random	active	2026-09-08 00:49:53.483	2026-09-08 00:49:53.483	0
41	binsar@mcfoption.com	$2b$10$3/I2xqh5LpalcF6Y53C63.uubPRaJE8N31QWgIAVUOPZkHKrqLeaG	binsar	ADMIN	random	active	2026-09-08 00:49:53.584	2026-09-08 00:49:53.584	0
\.


--
-- Data for Name: Wallet; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Wallet" (id, "userId", balance, assets, "createdAt", "updatedAt") FROM stdin;
39	39	0	{}	2026-09-08 00:49:53.314	2026-09-08 00:49:53.314
40	40	0	{}	2026-09-08 00:49:53.483	2026-09-08 00:49:53.483
41	41	0	{}	2026-09-08 00:49:53.584	2026-09-08 00:49:53.584
\.


--
-- Name: AdminWallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."AdminWallet_id_seq"', 75, true);


--
-- Name: AuditLog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."AuditLog_id_seq"', 57, true);


--
-- Name: ChatMessage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."ChatMessage_id_seq"', 58, true);


--
-- Name: Kyc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Kyc_id_seq"', 9, true);


--
-- Name: Session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Session_id_seq"', 413, true);


--
-- Name: TradingDuration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."TradingDuration_id_seq"', 10, true);


--
-- Name: Transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Transaction_id_seq"', 193, true);


--
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."User_id_seq"', 41, true);


--
-- Name: Wallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Wallet_id_seq"', 41, true);


--
-- Name: AdminWallet AdminWallet_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."AdminWallet"
    ADD CONSTRAINT "AdminWallet_pkey" PRIMARY KEY (id);


--
-- Name: AuditLog AuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_pkey" PRIMARY KEY (id);


--
-- Name: ChatMessage ChatMessage_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."ChatMessage"
    ADD CONSTRAINT "ChatMessage_pkey" PRIMARY KEY (id);


--
-- Name: Kyc Kyc_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Kyc"
    ADD CONSTRAINT "Kyc_pkey" PRIMARY KEY (id);


--
-- Name: Session Session_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_pkey" PRIMARY KEY (id);


--
-- Name: TradingDuration TradingDuration_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."TradingDuration"
    ADD CONSTRAINT "TradingDuration_pkey" PRIMARY KEY (id);


--
-- Name: Transaction Transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Transaction"
    ADD CONSTRAINT "Transaction_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Wallet Wallet_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Wallet"
    ADD CONSTRAINT "Wallet_pkey" PRIMARY KEY (id);


--
-- Name: AdminWallet_network_key; Type: INDEX; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE UNIQUE INDEX "AdminWallet_network_key" ON public."AdminWallet" USING btree (network);


--
-- Name: Kyc_userId_key; Type: INDEX; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE UNIQUE INDEX "Kyc_userId_key" ON public."Kyc" USING btree ("userId");


--
-- Name: Session_token_key; Type: INDEX; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE UNIQUE INDEX "Session_token_key" ON public."Session" USING btree (token);


--
-- Name: TradingDuration_seconds_key; Type: INDEX; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE UNIQUE INDEX "TradingDuration_seconds_key" ON public."TradingDuration" USING btree (seconds);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: Wallet_userId_key; Type: INDEX; Schema: public; Owner: uTS9w2eoB9Ru
--

CREATE UNIQUE INDEX "Wallet_userId_key" ON public."Wallet" USING btree ("userId");


--
-- Name: ChatMessage ChatMessage_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."ChatMessage"
    ADD CONSTRAINT "ChatMessage_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Kyc Kyc_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Kyc"
    ADD CONSTRAINT "Kyc_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Session Session_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Transaction Transaction_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Transaction"
    ADD CONSTRAINT "Transaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Wallet Wallet_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."Wallet"
    ADD CONSTRAINT "Wallet_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: uTS9w2eoB9Ru
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict ZEk1VUGdh7mmZHNI7pjWCeQBdjU2qngFKhIqIqbztn3SZWTvo3ltpUHQ8xI7Awb

