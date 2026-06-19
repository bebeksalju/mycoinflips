--
-- PostgreSQL database dump
--

\restrict VGYfZ9TX7dpSvGpFPofQ13Eqbd52ZqbOYSXEAgmn0seGKgC0T85qw3Euh4w5lCt

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
1	BTC	19rEvUZZjYJcALwhnxb2iMnvGdwAf5fjid	2026-03-04 18:50:39.953	2026-06-08 06:39:54.857
2	ETH	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.96	2026-06-08 06:39:54.869
3	USDT_ERC20	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.962	2026-06-08 06:39:54.871
4	USDT_TRC20	TCbk3i9dmvGz3shUFpDsfAteQsCK67VkG5	2026-03-04 18:50:39.964	2026-06-08 06:39:54.873
5	USDC	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.966	2026-06-08 06:39:54.875
\.


--
-- Data for Name: AuditLog; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."AuditLog" (id, "userId", "userEmail", "userName", action, "ipAddress", "createdAt") FROM stdin;
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
\.


--
-- Data for Name: ChatMessage; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."ChatMessage" (id, "userId", sender, message, read, "createdAt") FROM stdin;
20	19	user	Kyc submission failure for verification	t	2026-03-28 02:14:02.075
21	19	admin	Hello Mr. Baylan from UID 1243 we would like to inform you, that your balance from our old platform already move to your account. we give a bonus for our loyal members. Please let us know if your balance is incorrect.	t	2026-03-28 03:30:27.174
22	19	admin	We have helped verify your account.	t	2026-03-28 03:31:31.471
23	19	admin	Please try to Re-login your account.	t	2026-03-28 03:33:47.296
24	19	admin	Dear Valued Customer UID 1243,  We would like to inform you that we have successfully received your recent payment in the amount of $490.  At this time, there is still a remaining balance of $2,740 to complete your ongoing payment process.  We kindly ask you to settle the remaining amount at your earliest convenience so that your process can continue without delay.  If you have any questions or require assistance, please feel free to contact our customer support team.  Thank you for your attention and cooperation.  Best regards, MyCoinflip Team	t	2026-03-28 14:17:32.217
29	19	user	I received an email about my remaining balance and replied with the final payment. can you confirm the payment was  completed	t	2026-04-08 02:40:58.318
30	19	user	??	t	2026-04-08 04:52:31.117
31	19	user	Can someone notify me via email once received please	t	2026-04-08 05:44:52.823
32	19	user	cid:mf_3CC74024-5506-4318-A6DF-A80BE13BE511/L0/001	t	2026-04-08 14:43:22.831
33	19	user	I submitted the payment via email. Can you tell me if it has gone through?	t	2026-04-08 14:43:59.858
34	19	user	What is the remaining balance	t	2026-04-08 21:00:29.828
35	19	user	Is anyone going to reply	t	2026-04-09 03:02:16.618
36	19	admin	We just reply to your email sir, We've just finished weekly maintenance	t	2026-04-20 02:05:40.334
37	19	user	Is there an update on my transaction?	t	2026-04-24 23:27:50.055
38	19	user	I still have not received funds. I was supposed to receive them earlier todayh	t	2026-04-25 01:54:43.674
39	19	user	Still no funds and no response by email	t	2026-04-25 22:16:54.402
40	19	user	Can someone respond	t	2026-04-26 03:05:16.723
41	19	user	???	t	2026-04-26 15:05:54.48
42	19	admin	We just respond to your email sir. please try to check your email	t	2026-04-26 15:20:12.199
43	19	user	Can you tell me where my first withdrawal is. I am still waiting. The 20k withdrawal was done in error.	t	2026-04-26 17:17:40.315
44	19	user	Can someone respond to my email or reply to me here	t	2026-04-29 03:46:18.203
48	34	user	I can’t figure out my bitcoin address	t	2026-06-08 06:39:34.704
46	30	user	I just have a question about my balance	t	2026-06-05 04:42:00.286
47	30	user	I had 230 something in my account with 2 successful trades	t	2026-06-05 04:43:59.866
49	30	user	I'm trying to withdraw everything but it won't work	f	2026-06-10 01:30:03.943
50	37	user	Ini akun IT digunakan khusus untuk maintenance	t	2026-06-12 06:33:09.222
51	19	user	What will be the required cost for the withdrawal I just started	f	2026-06-16 02:43:14.583
\.


--
-- Data for Name: Kyc; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Kyc" (id, "userId", status, "documentUrl", "documentUrlBack", "fullName", "idNumber", "createdAt", "updatedAt") FROM stdin;
2	13	APPROVED	/uploads/kyc/kyc-1774054578132-44cyp2eyvwz.jpg	/uploads/kyc/kyc-1774054578133-fgniuc0z8vm.jpg	Anna smith	123456789	2026-03-21 00:56:18.136	2026-03-21 00:57:41.324
3	19	APPROVED	/uploads/kyc/kyc-1774668777990-94h0ggx5ctg.jpeg	/uploads/kyc/kyc-1774668777992-dr67cxnkbko.jpeg	Baylan	Yuen	2026-03-28 03:32:57.996	2026-03-28 03:33:10.244
\.


--
-- Data for Name: Session; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Session" (id, "userId", token, "expiresAt", "createdAt") FROM stdin;
287	34	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjM0LCJlbWFpbCI6Im12cGFudGFsbGljYUBnbWFpbC5jb20iLCJyb2xlIjoiVVNFUiIsInRva2VuVmVyc2lvbiI6MCwiaWF0IjoxNzgxNzYxNDY4LCJleHAiOjE3ODE4NDc4Njh9.ZXdMo8i2w_f6HuA28lh9kU3_43e81HXD6x-ZPPGTEOo	2026-06-19 05:44:28.493	2026-06-18 05:44:28.493
288	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoiYWRtaW5AbXlmbGlwY29pbi5jb20iLCJyb2xlIjoiU1VQRVJVU0VSIiwidG9rZW5WZXJzaW9uIjo5LCJpYXQiOjE3ODE4NTkwODYsImV4cCI6MTc4MTk0NTQ4Nn0.bp5hz62UaPcLix1uKeezpFddf3RLK4t1uGK2e-nbiWA	2026-06-20 08:51:26.472	2026-06-19 08:51:26.472
166	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJlbWFpbCI6ImVsYXNzb3dpcG9oQGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3NzcyNTE5MTEsImV4cCI6MTc3NzMzODMxMX0.li7pBGABg2LaHuRfdhobTnlq9WjRbtDVEpEHIzU2_P0	2026-04-28 01:05:11.786	2026-04-27 01:05:11.786
248	30	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMwLCJlbWFpbCI6Im5pdmVhYnV0dGVyNzc5QGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODA5NzcxOTMsImV4cCI6MTc4MTA2MzU5M30.PJzTSwFuMNNBtpHPvxVCVyRygRx7vHqC3GKtpNC2HJY	2026-06-10 03:53:13.538	2026-06-09 03:53:13.538
250	30	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMwLCJlbWFpbCI6Im5pdmVhYnV0dGVyNzc5QGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODEwNDk0NTksImV4cCI6MTc4MTEzNTg1OX0.qL88x67VpTefhc0OF3Pq9mTIyP6lPqnGrkfg9tVLi84	2026-06-10 23:57:39.587	2026-06-09 23:57:39.587
191	26	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjI2LCJlbWFpbCI6Im1pa2Vjb2ZmZXkzNTdAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc4MDQ1Njc0OCwiZXhwIjoxNzgwNTQzMTQ4fQ.LzQwxbQyBgCgo2C4n1dyRoj9YxX7MHgOnFC5b2gQd4k	2026-06-04 03:19:08.18	2026-06-03 03:19:08.181
219	33	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMzLCJlbWFpbCI6ImNoYXNyYWZpdGlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc4MDgwOTYzOCwiZXhwIjoxNzgwODk2MDM4fQ.26yLxQYlkX-v7IywySQw7OBvLEHEifUrewzRzu7wt4U	2026-06-08 05:20:38.703	2026-06-07 05:20:38.704
221	28	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjI4LCJlbWFpbCI6ImdyaWZmaW5qbzc3QGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODA4MzgxMjIsImV4cCI6MTc4MDkyNDUyMn0.KdbOEatqdYPUlaNTuzJWM5bxCaNXIdMRLxQy84wXlVo	2026-06-08 13:15:22.349	2026-06-07 13:15:22.349
282	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJlbWFpbCI6ImJheWxhbnlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc4MTU3NzExMiwiZXhwIjoxNzgxNjYzNTEyfQ.QHujgbCA0K6wZyFhitbVdang0vylKRO48pawSQtw8Xk	2026-06-17 02:31:52.91	2026-06-16 02:31:52.91
225	35	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjM1LCJlbWFpbCI6ImNlc2xpbmVsYXVAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc4MDg5NDk2NSwiZXhwIjoxNzgwOTgxMzY1fQ.mA8yRerU0k392AMxwphHFTEMyguC3tBSubcl_irZwVA	2026-06-09 05:02:45.865	2026-06-08 05:02:45.866
283	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJlbWFpbCI6ImJheWxhbnlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc4MTU3NzYzOCwiZXhwIjoxNzgxNjY0MDM4fQ.vg91RRrqZifQblM48_hRbAJ9wx6YGm4Arg191WgBaIw	2026-06-17 02:40:38.475	2026-06-16 02:40:38.475
284	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImVtYWlsIjoid2F3b25nNzdAbXljb2luZmxpcHMuY29tIiwicm9sZSI6IkFETUlOIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODE1NzkwNDYsImV4cCI6MTc4MTY2NTQ0Nn0.BhhsQphU7Q1mjSXm7rkTCkqqQhD6c3qrqy79-OoLs54	2026-06-17 03:04:06.995	2026-06-16 03:04:06.995
285	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEzLCJlbWFpbCI6IkFubmFzbWl0aDE1QGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODE2NTgwMTgsImV4cCI6MTc4MTc0NDQxOH0.URmyVn_JvfSyCfQau2z6DzyV0eTZWsrTNCgW5GQsyV0	2026-06-18 01:00:18.128	2026-06-17 01:00:18.128
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
144	13	5000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-15 05:31:15.01
145	19	30000	\N	BTC	WITHDRAWAL	COMPLETED	0x17884aC617d8b946F4EEc8F359C79FfE9dc31FF4	\N	2026-06-16 02:42:12.876
146	13	5000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-17 01:00:37.499
58	13	100000	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1773282653332-88byko7u3nh.jpg	2026-03-12 02:30:53.338
59	13	10000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-12 02:32:23.328
60	13	10000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-12 02:34:06.579
65	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-12 12:25:20.767
66	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-12 12:37:16.795
67	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-16 03:32:51.15
93	13	5000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-22 09:29:24.365
94	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-24 00:36:45.093
95	13	7500	0	BTC/USDT	TRADE_SELL	PENDING	\N	\N	2026-03-24 02:39:02.255
96	13	7500	0	BTC/USDT	TRADE_SELL	PENDING	\N	\N	2026-03-24 02:39:02.888
97	13	7500	0	BTC/USDT	TRADE_SELL	PENDING	\N	\N	2026-03-24 02:39:06.235
98	13	75000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-24 02:39:15.918
99	13	7500	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-24 02:40:47.671
100	13	8700	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-24 02:43:48.011
101	13	8700	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-24 02:45:54.261
102	13	8700	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-24 02:45:57.884
103	13	6000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-24 02:47:24.875
104	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-24 15:02:38.997
105	13	7500	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-28 03:15:21.333
108	13	7000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-01 00:02:25.031
109	13	8000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-04 14:08:13.23
110	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-11 01:15:51.042
111	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-11 01:15:53.406
112	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-15 02:56:28.352
113	13	10000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-18 01:13:25.922
114	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-20 03:20:02.577
116	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-21 12:13:00.777
115	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-21 12:12:59.955
118	19	20000	\N	\N	WITHDRAWAL	FAILED	0xb2d7930C5EB2935D853EE190bfE23B85126e1C6F	\N	2026-04-25 23:15:35.575
119	13	30000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-29 05:33:27.996
120	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-04 01:04:25.53
121	13	7400	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-05 02:44:52.632
122	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-06 03:05:40.998
123	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-06 03:14:46.449
124	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-06 03:55:23.168
125	13	1000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-07 13:30:06.893
126	28	1000	0	BTC/USDT	TRADE_LOSS	COMPLETED	\N	\N	2026-06-07 13:32:30.081
127	28	1000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-07 13:33:43.266
128	28	1000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-07 13:34:44.271
129	28	5000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-07 13:43:01.76
130	13	88500	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-10 00:35:16.563
131	13	16000	0	XRP/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-10 00:37:13.488
132	13	10000	0	SOL/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-10 00:57:21.92
133	13	20000	\N	\N	WITHDRAWAL	FAILED	BLABLABLABLABLA	\N	2026-06-11 05:45:41.325
135	13	7000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-12 15:19:18.948
136	13	140	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1781439375021-593owth4zij.jfif	2026-06-14 12:16:15.026
137	34	140	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1781439415495-7xvr5bhs90p.png	2026-06-14 12:16:55.495
138	34	101	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1781440251287-x1m9oy0w3j.png	2026-06-14 12:30:51.291
139	34	240	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-14 12:46:29.294
140	34	260	0	ETH/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-14 12:51:47.07
141	13	8500	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-15 02:06:00.814
142	13	3000	0	XRP/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-15 05:24:24.466
143	13	7500	0	ETH/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-06-15 05:28:05.095
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."User" (id, email, password, name, role, "profitMode", status, "createdAt", "updatedAt", "tokenVersion") FROM stdin;
8	tkenrsi@mycoinflips.com	$2b$10$enQ1.PQeLWjFScbFm3Y/AeurKUfxqIwupocHUemMIuysaG.6cuqqi	tkeNRSI	SUPERUSER	random	active	2026-03-03 17:05:22.089	2026-03-03 17:05:22.089	2
13	Annasmith15@gmail.com	Aman!123	Anna Smith	USER	win	active	2026-03-12 02:28:29.356	2026-03-12 02:31:35.178	0
9	wawong77@mycoinflips.com	$2b$10$cVgtEreMxotmtgXn3Afp6uSCeBLtg9RaGaSaudgfTgZDOFjmcSFKC	wawong77	ADMIN	random	active	2026-03-03 17:05:22.169	2026-03-03 17:05:22.169	0
10	kumbangtanduk77@mycoinflips.com	$2b$10$JzYZUxp6MRvAj7lDzTWuJ.yb5Y7tzbKZ9ffa4AuwfpHPaiKIQlfUS	kumbangtanduk77	ADMIN	random	active	2026-03-03 17:05:22.221	2026-03-03 17:05:22.221	0
19	baylany@gmail.com	We wont rock you!	Baylan Yuen	USER	random	active	2026-03-28 02:09:41.475	2026-03-28 02:09:41.475	0
21	elassowipoh@gmail.com	qusso5-zyjnym-vesveC	john lim	USER	random	active	2026-04-27 01:05:05.696	2026-04-27 01:05:05.696	0
1	admin@myflipcoin.com	Monyet_ijo_Banyumas&*!	Super Admin	SUPERUSER	random	active	2026-02-27 15:31:14.314	2026-03-06 18:00:16.394	9
26	mikecoffey357@gmail.com	Invest100	Mike Coffey	USER	random	active	2026-06-03 03:18:56.383	2026-06-03 03:18:56.383	0
27	drvnchevy@gmail.com	Mufasa1995!	Jake Nordberg	USER	random	active	2026-06-03 14:57:14.12	2026-06-03 14:57:14.12	0
33	chasrafiti@gmail.com	Love!123	Chas Rafiti	USER	random	active	2026-06-07 05:12:02.874	2026-06-07 05:12:02.874	0
28	griffinjo77@gmail.com	91Huskies	Griffin  Johnson	USER	random	active	2026-06-04 07:46:03.566	2026-06-07 13:44:09.922	0
35	ceslinelau@gmail.com	wawong17	cesline lau	USER	random	active	2026-06-08 05:02:31.801	2026-06-08 05:02:31.801	0
30	niveabutter779@gmail.com	GideonStone9864$@#	Michael Schultz	USER	loss	active	2026-06-05 04:40:07.314	2026-06-10 03:34:42.61	0
37	akunit@mycoinflips.com	bokepindoh	Akun IT Mycoinflips	USER	random	active	2026-06-12 06:31:43.484	2026-06-12 06:31:43.484	0
34	mvpantallica@gmail.com	Zebra@1993	Mark Vogel	USER	loss	active	2026-06-07 07:25:20.449	2026-06-14 13:33:07	0
\.


--
-- Data for Name: Wallet; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Wallet" (id, "userId", balance, assets, "createdAt", "updatedAt") FROM stdin;
1	1	0	{}	2026-02-27 15:31:14.339	2026-02-27 15:31:14.339
8	8	0	{}	2026-03-03 17:05:22.089	2026-03-03 17:05:22.089
9	9	0	{}	2026-03-03 17:05:22.169	2026-03-03 17:05:22.169
10	10	0	{}	2026-03-03 17:05:22.221	2026-03-03 17:05:22.221
34	34	291	{}	2026-06-07 07:25:20.449	2026-06-14 12:52:18.23
21	21	0	{}	2026-04-27 01:05:05.696	2026-04-27 01:05:05.696
26	26	0	{}	2026-06-03 03:18:56.383	2026-06-03 03:18:56.383
27	27	0	{}	2026-06-03 14:57:14.12	2026-06-03 14:57:14.12
19	19	1284565	{}	2026-03-28 02:09:41.475	2026-06-16 02:42:12.875
13	13	210000	{}	2026-03-12 02:28:29.356	2026-06-17 01:01:38.424
30	30	230	{}	2026-06-05 04:40:07.314	2026-06-06 05:09:16.833
33	33	0	{}	2026-06-07 05:12:02.874	2026-06-07 05:12:02.874
28	28	11100	{}	2026-06-04 07:46:03.566	2026-06-07 13:44:02.677
35	35	0	{}	2026-06-08 05:02:31.801	2026-06-08 05:02:31.801
37	37	0	{}	2026-06-12 06:31:43.484	2026-06-12 06:31:43.484
\.


--
-- Name: AdminWallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."AdminWallet_id_seq"', 70, true);


--
-- Name: AuditLog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."AuditLog_id_seq"', 35, true);


--
-- Name: ChatMessage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."ChatMessage_id_seq"', 51, true);


--
-- Name: Kyc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Kyc_id_seq"', 6, true);


--
-- Name: Session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Session_id_seq"', 288, true);


--
-- Name: TradingDuration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."TradingDuration_id_seq"', 10, true);


--
-- Name: Transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Transaction_id_seq"', 146, true);


--
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."User_id_seq"', 37, true);


--
-- Name: Wallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Wallet_id_seq"', 37, true);


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

\unrestrict VGYfZ9TX7dpSvGpFPofQ13Eqbd52ZqbOYSXEAgmn0seGKgC0T85qw3Euh4w5lCt

