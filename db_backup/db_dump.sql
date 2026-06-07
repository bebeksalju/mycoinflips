--
-- PostgreSQL database dump
--

\restrict n7ZhbFsffBjO2nGH8samwrAAbkVX3PJFP4jw3wYdYdzG2qtJrtk6DSl7mbe2yPl

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
1	BTC	19rEvUZZjYJcALwhnxb2iMnvGdwAf5fjid	2026-03-04 18:50:39.953	2026-06-03 03:26:34.995
2	ETH	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.96	2026-06-03 03:26:35
3	USDT_ERC20	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.962	2026-06-03 03:26:35.002
4	USDT_TRC20	TCbk3i9dmvGz3shUFpDsfAteQsCK67VkG5	2026-03-04 18:50:39.964	2026-06-03 03:26:35.004
5	USDC	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.966	2026-06-03 03:26:35.006
\.


--
-- Data for Name: AuditLog; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."AuditLog" (id, "userId", "userEmail", "userName", action, "ipAddress", "createdAt") FROM stdin;
1	9	wawong77@mycoinflips.com	Admin	Changed block status of user ID 22	153.124.163.253	2026-06-02 07:28:52.553
2	8	tkenrsi@mycoinflips.com	Admin	Updated the admin deposit wallet addresses	153.124.163.253	2026-06-03 03:26:35.009
3	9	wawong77@mycoinflips.com	Admin	Changed balance of user Baylan Yuen (baylany@gmail.com) to $1314065	153.124.163.253	2026-06-04 15:08:13.674
4	9	wawong77@mycoinflips.com	Admin	Changed balance of user Michael Schultz (niveabutter779@gmail.com) to $230	104.28.163.235	2026-06-06 05:09:16.845
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
46	30	user	I just have a question about my balance	f	2026-06-05 04:42:00.286
47	30	user	I had 230 something in my account with 2 successful trades	f	2026-06-05 04:43:59.866
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
166	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJlbWFpbCI6ImVsYXNzb3dpcG9oQGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3NzcyNTE5MTEsImV4cCI6MTc3NzMzODMxMX0.li7pBGABg2LaHuRfdhobTnlq9WjRbtDVEpEHIzU2_P0	2026-04-28 01:05:11.786	2026-04-27 01:05:11.786
169	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJlbWFpbCI6ImJheWxhbnlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NzQyNTk1MSwiZXhwIjoxNzc3NTEyMzUxfQ.Hf39HMZmWb6M68atXWZEUCM__HHv_rFA8n_isLMVfsI	2026-04-30 01:25:51.895	2026-04-29 01:25:51.896
171	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJlbWFpbCI6ImJheWxhbnlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NzQzNDM2MywiZXhwIjoxNzc3NTIwNzYzfQ.g6m6_xBfJVhOHUGTO-ZYm7kZQgFhKn-loxY-5qHojJ8	2026-04-30 03:46:03.592	2026-04-29 03:46:03.592
172	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJlbWFpbCI6ImJheWxhbnlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NzQ0MDc3MywiZXhwIjoxNzc3NTI3MTczfQ.JLp0hOE0fusZz-LTI1mRwCSQSNtR-nOUdjgAPbmgEPI	2026-04-30 05:32:53.418	2026-04-29 05:32:53.418
191	26	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjI2LCJlbWFpbCI6Im1pa2Vjb2ZmZXkzNTdAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc4MDQ1Njc0OCwiZXhwIjoxNzgwNTQzMTQ4fQ.LzQwxbQyBgCgo2C4n1dyRoj9YxX7MHgOnFC5b2gQd4k	2026-06-04 03:19:08.18	2026-06-03 03:19:08.181
202	28	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjI4LCJlbWFpbCI6ImdyaWZmaW5qbzc3QGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODA1NTkxODEsImV4cCI6MTc4MDY0NTU4MX0.Uwf7tO7Qj1xlYwkBFUDjCxA0tNUGRQw0zhXQZUukCTA	2026-06-05 07:46:21.843	2026-06-04 07:46:21.843
207	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEzLCJlbWFpbCI6IkFubmFzbWl0aDE1QGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODA2NzI4ODEsImV4cCI6MTc4MDc1OTI4MX0.J-OV0V7goIBT-cBImdNdifYUnog-wbZAEs0xJBkcoXo	2026-06-06 15:21:21.942	2026-06-05 15:21:21.942
209	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEzLCJlbWFpbCI6IkFubmFzbWl0aDE1QGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODA3MTgxMTEsImV4cCI6MTc4MDgwNDUxMX0.9G5AXQKp-ZK1crrXtYNBSxKEjfYxHgvGN3d--btgWFU	2026-06-07 03:55:11.918	2026-06-06 03:55:11.918
211	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImVtYWlsIjoid2F3b25nNzdAbXljb2luZmxpcHMuY29tIiwicm9sZSI6IkFETUlOIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3ODA3MjIzNjAsImV4cCI6MTc4MDgwODc2MH0.7QWRP6boRu8S66CvsMN3ajqPjwdf3Vgc80GTFxlqDSU	2026-06-07 05:06:00.569	2026-06-06 05:06:00.57
212	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoiYWRtaW5AbXlmbGlwY29pbi5jb20iLCJyb2xlIjoiU1VQRVJVU0VSIiwidG9rZW5WZXJzaW9uIjo5LCJpYXQiOjE3ODA3MjI5OTEsImV4cCI6MTc4MDgwOTM5MX0._jdA-XZgVQrv8u0rK3Mt4MQuHk20ETPQf9Exc7rVkjk	2026-06-07 05:16:31.703	2026-06-06 05:16:31.703
214	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoiYWRtaW5AbXlmbGlwY29pbi5jb20iLCJyb2xlIjoiU1VQRVJVU0VSIiwidG9rZW5WZXJzaW9uIjo5LCJpYXQiOjE3ODA3OTMzMjQsImV4cCI6MTc4MDg3OTcyNH0.3_OxXt0c3LNTWKhla9aJQQabrjsLaoQo8NssSlHYnUo	2026-06-08 00:48:44.724	2026-06-07 00:48:44.726
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
28	griffinjo77@gmail.com	91Huskies	Griffin  Johnson	USER	random	active	2026-06-04 07:46:03.566	2026-06-04 07:46:03.566	0
30	niveabutter779@gmail.com	GideonStone9864$@#	Michael Schultz	USER	random	active	2026-06-05 04:40:07.314	2026-06-05 04:40:07.314	0
\.


--
-- Data for Name: Wallet; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Wallet" (id, "userId", balance, assets, "createdAt", "updatedAt") FROM stdin;
1	1	0	{}	2026-02-27 15:31:14.339	2026-02-27 15:31:14.339
8	8	0	{}	2026-03-03 17:05:22.089	2026-03-03 17:05:22.089
9	9	0	{}	2026-03-03 17:05:22.169	2026-03-03 17:05:22.169
10	10	0	{}	2026-03-03 17:05:22.221	2026-03-03 17:05:22.221
21	21	0	{}	2026-04-27 01:05:05.696	2026-04-27 01:05:05.696
26	26	0	{}	2026-06-03 03:18:56.383	2026-06-03 03:18:56.383
27	27	0	{}	2026-06-03 14:57:14.12	2026-06-03 14:57:14.12
28	28	0	{}	2026-06-04 07:46:03.566	2026-06-04 07:46:03.566
19	19	1314065	{}	2026-03-28 02:09:41.475	2026-06-04 15:08:13.671
13	13	176900	{}	2026-03-12 02:28:29.356	2026-06-06 03:57:24.123
30	30	230	{}	2026-06-05 04:40:07.314	2026-06-06 05:09:16.833
\.


--
-- Name: AdminWallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."AdminWallet_id_seq"', 40, true);


--
-- Name: AuditLog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."AuditLog_id_seq"', 4, true);


--
-- Name: ChatMessage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."ChatMessage_id_seq"', 47, true);


--
-- Name: Kyc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Kyc_id_seq"', 5, true);


--
-- Name: Session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Session_id_seq"', 214, true);


--
-- Name: TradingDuration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."TradingDuration_id_seq"', 10, true);


--
-- Name: Transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Transaction_id_seq"', 124, true);


--
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."User_id_seq"', 32, true);


--
-- Name: Wallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Wallet_id_seq"', 32, true);


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

\unrestrict n7ZhbFsffBjO2nGH8samwrAAbkVX3PJFP4jw3wYdYdzG2qtJrtk6DSl7mbe2yPl

