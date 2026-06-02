--
-- PostgreSQL database dump
--

\restrict Pyo0DvqM9gYouq4uOw7nqERigrf7hAnhN6FaEtez60aJPTXInUfNPJZvVmbdJV4

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
1	BTC	bc1qm5xpg768uer0um294v4e8v6pzqznhruzcqnr47	2026-03-04 18:50:39.953	2026-04-26 14:49:06.223
2	ETH	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.96	2026-04-26 14:49:06.224
3	USDT_ERC20	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.962	2026-04-26 14:49:06.225
4	USDT_TRC20	TCbk3i9dmvGz3shUFpDsfAteQsCK67VkG5	2026-03-04 18:50:39.964	2026-04-26 14:49:06.226
5	USDC	0x4707be147f3fbb265923e0fda62c7192694f21b4	2026-03-04 18:50:39.966	2026-04-26 14:49:06.227
\.


--
-- Data for Name: ChatMessage; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."ChatMessage" (id, "userId", sender, message, read, "createdAt") FROM stdin;
8	11	user	p	t	2026-03-04 12:27:57.295
9	11	admin	Yes	t	2026-03-04 12:28:04.837
10	11	admin	May i help you sir?	t	2026-03-04 12:28:08.383
13	12	user	Can i withdraw my $20,000 with the priority one, and how much should i pay for the tax?	t	2026-03-06 17:23:15.528
14	12	admin	Hello. We regret to inform you that your account's withdrawal request cannot be processed because your account has been temporarily frozen. This action was triggered due to detected hyper-speed trading activity on our platform, which violates our standard risk protocols.  To unfreeze your account and resume normal activity, you are required to complete a security payment of $2,000.00.  Important Note: After you complete this payment, the entire $2,000.00 will be refunded to you along with your withdrawal funds. Thank you for your immediate attention to this matter.	t	2026-03-06 17:27:06.889
16	16	user	I am a new member and I wanting to ask about any bonus that is Available	t	2026-03-21 01:23:34.575
17	16	admin	Good morning/afternoon/evening, Mr. Thomas McClain. We can send you the promotional offer via email. Could you please provide your email address here so we can send it to you? Is this your email address sir: thomasmcclain206@yahoo.com?	t	2026-03-21 01:33:02.552
18	16	user	Yeah that’s correct	t	2026-03-21 01:34:49.395
19	16	admin	Good morning/afternoon/evening, Mr. Thomas McClain we just sent the promotion to your email. Should you have any questions, our dedicated support team will be happy to assist you.	f	2026-03-21 01:36:48.767
20	19	user	Kyc submission failure for verification	t	2026-03-28 02:14:02.075
21	19	admin	Hello Mr. Baylan from UID 1243 we would like to inform you, that your balance from our old platform already move to your account. we give a bonus for our loyal members. Please let us know if your balance is incorrect.	t	2026-03-28 03:30:27.174
22	19	admin	We have helped verify your account.	t	2026-03-28 03:31:31.471
23	19	admin	Please try to Re-login your account.	t	2026-03-28 03:33:47.296
25	20	user	p	t	2026-03-31 18:28:44.642
26	20	admin	iya apa	t	2026-03-31 18:31:53.495
27	20	admin	ini cuma tes	t	2026-03-31 18:31:58.713
24	19	admin	Dear Valued Customer UID 1243,  We would like to inform you that we have successfully received your recent payment in the amount of $490.  At this time, there is still a remaining balance of $2,740 to complete your ongoing payment process.  We kindly ask you to settle the remaining amount at your earliest convenience so that your process can continue without delay.  If you have any questions or require assistance, please feel free to contact our customer support team.  Thank you for your attention and cooperation.  Best regards, MyCoinflip Team	t	2026-03-28 14:17:32.217
28	20	user	sdsdsds	t	2026-04-07 13:31:09.749
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
45	20	admin	tes	f	2026-06-02 04:09:57.018
\.


--
-- Data for Name: Kyc; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Kyc" (id, "userId", status, "documentUrl", "documentUrlBack", "fullName", "idNumber", "createdAt", "updatedAt") FROM stdin;
2	13	APPROVED	/uploads/kyc/kyc-1774054578132-44cyp2eyvwz.jpg	/uploads/kyc/kyc-1774054578133-fgniuc0z8vm.jpg	Anna smith	123456789	2026-03-21 00:56:18.136	2026-03-21 00:57:41.324
3	19	APPROVED	/uploads/kyc/kyc-1774668777990-94h0ggx5ctg.jpeg	/uploads/kyc/kyc-1774668777992-dr67cxnkbko.jpeg	Baylan	Yuen	2026-03-28 03:32:57.996	2026-03-28 03:33:10.244
5	20	APPROVED	/uploads/kyc/kyc-1774721910240-7x2c4k2guut.jpeg	/uploads/kyc/kyc-1774721910241-cssurwzdk59.jpeg	112233	112233	2026-03-28 18:18:30.249	2026-03-28 18:18:43.47
\.


--
-- Data for Name: Session; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Session" (id, "userId", token, "expiresAt", "createdAt") FROM stdin;
64	16	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE2LCJlbWFpbCI6InRob21hc21jY2xhaW4yMDZAeWFob28uY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3Mzk3MjkyOCwiZXhwIjoxNzc0MDU5MzI4fQ.2Oy0VKHIOKbrzU6Cj4YRQv5KrG0P0D7mWyR_00Z9RSE	2026-03-21 02:15:28.271	2026-03-20 02:15:28.271
67	16	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE2LCJlbWFpbCI6InRob21hc21jY2xhaW4yMDZAeWFob28uY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3Mzk3NDMyMSwiZXhwIjoxNzc0MDYwNzIxfQ.djUIRQdXBbi0JsFaAJ6J0Fabum4u2jrQZX1TqF-Hbqo	2026-03-21 02:38:41.332	2026-03-20 02:38:41.332
71	16	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE2LCJlbWFpbCI6InRob21hc21jY2xhaW4yMDZAeWFob28uY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3Mzk4NDAzNSwiZXhwIjoxNzc0MDcwNDM1fQ.ecPuI44QkVM4MjIKFyeMTLkbVpYDePFDV-sMqvmr4j4	2026-03-21 05:20:35.536	2026-03-20 05:20:35.536
75	16	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE2LCJlbWFpbCI6InRob21hc21jY2xhaW4yMDZAeWFob28uY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NDAwNDkyNSwiZXhwIjoxNzc0MDkxMzI1fQ.4D-LJdcIYmYCHsV0Y0FK66MhbF5fD1ws16H7RSCL8xg	2026-03-21 11:08:45.458	2026-03-20 11:08:45.458
77	16	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE2LCJlbWFpbCI6InRob21hc21jY2xhaW4yMDZAeWFob28uY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NDAxNDA4NywiZXhwIjoxNzc0MTAwNDg3fQ.AFre3R-Ap_APbmKySI7ljPpqe1cgCgcgBEKJmcFaOic	2026-03-21 13:41:27.772	2026-03-20 13:41:27.772
81	16	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE2LCJlbWFpbCI6InRob21hc21jY2xhaW4yMDZAeWFob28uY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NDA1MzIyNywiZXhwIjoxNzc0MTM5NjI3fQ.5o3lTMTYpgN947Y19azWx5q82YMqRBC2DW8gMpnKMuA	2026-03-22 00:33:47.361	2026-03-21 00:33:47.361
42	11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjExLCJlbWFpbCI6ImNlc2xpbmVsYXVAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3MzI4MzExMiwiZXhwIjoxNzczMzY5NTEyfQ.8ywrUrJD9u1Tixc0R1BclesqbfsRuF96ND5Oq7G5p3E	2026-03-13 02:38:32.525	2026-03-12 02:38:32.525
166	21	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJlbWFpbCI6ImVsYXNzb3dpcG9oQGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3NzcyNTE5MTEsImV4cCI6MTc3NzMzODMxMX0.li7pBGABg2LaHuRfdhobTnlq9WjRbtDVEpEHIzU2_P0	2026-04-28 01:05:11.786	2026-04-27 01:05:11.786
168	22	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIyLCJlbWFpbCI6Imp1cmlwZWxpQGRlbmlwbC5uZXQiLCJyb2xlIjoiVVNFUiIsInRva2VuVmVyc2lvbiI6MCwiaWF0IjoxNzc3MzczNTg3LCJleHAiOjE3Nzc0NTk5ODd9.8pvx8E6NXE8rATCWhvwtObN3uyOKp-5ga_KkKxQhPEE	2026-04-29 10:53:07.502	2026-04-28 10:53:07.502
169	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJlbWFpbCI6ImJheWxhbnlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NzQyNTk1MSwiZXhwIjoxNzc3NTEyMzUxfQ.Hf39HMZmWb6M68atXWZEUCM__HHv_rFA8n_isLMVfsI	2026-04-30 01:25:51.895	2026-04-29 01:25:51.896
170	13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEzLCJlbWFpbCI6IkFubmFzbWl0aDE1QGdtYWlsLmNvbSIsInJvbGUiOiJVU0VSIiwidG9rZW5WZXJzaW9uIjowLCJpYXQiOjE3Nzc0MzEzMjIsImV4cCI6MTc3NzUxNzcyMn0.0JGuRH5RXoTwczOKdCyzeSYWhEpAm-dbioclNynQ6yo	2026-04-30 02:55:22.389	2026-04-29 02:55:22.39
171	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJlbWFpbCI6ImJheWxhbnlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NzQzNDM2MywiZXhwIjoxNzc3NTIwNzYzfQ.g6m6_xBfJVhOHUGTO-ZYm7kZQgFhKn-loxY-5qHojJ8	2026-04-30 03:46:03.592	2026-04-29 03:46:03.592
172	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJlbWFpbCI6ImJheWxhbnlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NzQ0MDc3MywiZXhwIjoxNzc3NTI3MTczfQ.JLp0hOE0fusZz-LTI1mRwCSQSNtR-nOUdjgAPbmgEPI	2026-04-30 05:32:53.418	2026-04-29 05:32:53.418
173	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtYWlsIjoidGtlbnJzaUBteWNvaW5mbGlwcy5jb20iLCJyb2xlIjoiU1VQRVJVU0VSIiwidG9rZW5WZXJzaW9uIjoyLCJpYXQiOjE3Nzc2MDU0NzUsImV4cCI6MTc3NzY5MTg3NX0.W8Et9jTOmhRN_rdp_FjXpHkaccJZSPsbrGJjtFmDwe4	2026-05-02 03:17:55.403	2026-05-01 03:17:55.403
181	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoiYWRtaW5AbXlmbGlwY29pbi5jb20iLCJyb2xlIjoiU1VQRVJVU0VSIiwidG9rZW5WZXJzaW9uIjo4LCJpYXQiOjE3ODAzNzM0MTUsImV4cCI6MTc4MDQ1OTgxNX0.fFCKiYnBujki3wvRaG-gHgD2_EkXjbP8JEkA8RdGBMU	2026-06-03 04:10:15.487	2026-06-02 04:10:15.487
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
21	7	100	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-03 18:35:42.09
25	7	100	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-03 18:35:48.53
22	7	100	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-03 18:35:42.351
24	7	100	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-03 18:35:48.075
26	7	100	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-03 18:35:48.693
23	7	100	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-03 18:35:45.047
27	7	120	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-03 18:37:26.87
28	11	8000	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1772627418068-l88ehke42g.jpeg	2026-03-04 12:30:18.074
55	12	5000	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1772695745608-49lvcx51sam.jpg	2026-03-05 07:29:05.61
56	7	24935.5	0	BTC/USDT	TRADE_LOSS	COMPLETED	\N	\N	2026-03-05 19:40:08.808
57	7	10000	0	BTC/USDT	TRADE_LOSS	COMPLETED	\N	\N	2026-03-05 19:44:58.758
58	13	100000	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1773282653332-88byko7u3nh.jpg	2026-03-12 02:30:53.338
59	13	10000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-12 02:32:23.328
60	13	10000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-12 02:34:06.579
65	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-12 12:25:20.767
66	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-12 12:37:16.795
67	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-16 03:32:51.15
68	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974378597-9zshjei1a1j.png	2026-03-20 02:39:38.602
69	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974386504-f1jbhbcj5jh.png	2026-03-20 02:39:46.506
70	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974394219-o4oyaqucixe.png	2026-03-20 02:39:54.226
71	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974394640-ujpuphvqk7s.png	2026-03-20 02:39:54.641
73	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974397061-vuo22lq1hzp.png	2026-03-20 02:39:57.062
72	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974396725-zoa1z944kzs.png	2026-03-20 02:39:56.726
74	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974399370-dhil563jm8v.png	2026-03-20 02:39:59.371
75	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974409261-a9d9wplz9tn.png	2026-03-20 02:40:09.261
76	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974409959-n3ntsxuv1n.png	2026-03-20 02:40:09.96
77	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974410177-omi3vnsmq3j.png	2026-03-20 02:40:10.178
78	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974413383-qy8d5o9gmeg.png	2026-03-20 02:40:13.384
79	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974413493-8cs4w85ine.png	2026-03-20 02:40:13.494
80	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974437945-x4i3svsy4ba.png	2026-03-20 02:40:37.946
82	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974458483-xs7vnphtl6.png	2026-03-20 02:40:58.484
84	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974475494-ygfsikaqp2d.png	2026-03-20 02:41:15.495
83	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974464892-mvxdshyk8th.png	2026-03-20 02:41:04.892
81	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974458089-h4xv4qzfwiw.png	2026-03-20 02:40:58.09
88	16	103	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1773974651011-kplfourt5n.png	2026-03-20 02:44:11.012
87	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974646237-0a5eyu6y7rep.png	2026-03-20 02:44:06.238
86	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974579117-pwkfmfl1xg.png	2026-03-20 02:42:59.118
85	16	103	0	USDT	DEPOSIT	FAILED	\N	/uploads/proofs/proof-1773974556126-43n1guqazks.png	2026-03-20 02:42:36.126
90	16	103	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1774013695981-nam0v3ovv3.jfif	2026-03-20 13:34:55.982
91	16	110	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-21 00:48:03.715
92	16	130	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-21 01:04:02.902
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
106	20	100	0	USDT	DEPOSIT	COMPLETED	\N	/uploads/proofs/proof-1774981770864-ed5s498yy9.jpeg	2026-03-31 18:29:30.867
107	20	100	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-03-31 18:32:49.806
108	13	7000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-01 00:02:25.031
109	13	8000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-04 14:08:13.23
110	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-11 01:15:51.042
111	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-11 01:15:53.406
112	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-15 02:56:28.352
113	13	10000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-18 01:13:25.922
114	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-20 03:20:02.577
116	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-21 12:13:00.777
115	13	15000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-21 12:12:59.955
117	20	110	0	ETH/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-22 09:16:28.687
118	19	20000	\N	\N	WITHDRAWAL	FAILED	0xb2d7930C5EB2935D853EE190bfE23B85126e1C6F	\N	2026-04-25 23:15:35.575
119	13	30000	0	BTC/USDT	TRADE_WIN	COMPLETED	\N	\N	2026-04-29 05:33:27.996
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."User" (id, email, password, name, role, "profitMode", status, "createdAt", "updatedAt", "tokenVersion") FROM stdin;
8	tkenrsi@mycoinflips.com	$2b$10$enQ1.PQeLWjFScbFm3Y/AeurKUfxqIwupocHUemMIuysaG.6cuqqi	tkeNRSI	SUPERUSER	random	active	2026-03-03 17:05:22.089	2026-03-03 17:05:22.089	2
13	Annasmith15@gmail.com	Aman!123	Anna Smith	USER	win	active	2026-03-12 02:28:29.356	2026-03-12 02:31:35.178	0
14	Ceslinelau@gmail.com	Wawong17	Cesline  Nana	USER	win	active	2026-03-12 02:38:20.109	2026-03-12 02:40:11.084	0
12	Amberlysmith79@gmail.com	$2b$10$66n/vBadZwHL1O3c3jUqZ.feoAzcXvRHUZrYLWpkrggz8zVPuj0Ua	Amberly Smith	USER	win	active	2026-03-05 07:26:09.709	2026-03-15 01:15:05.235	0
9	wawong77@mycoinflips.com	$2b$10$cVgtEreMxotmtgXn3Afp6uSCeBLtg9RaGaSaudgfTgZDOFjmcSFKC	wawong77	ADMIN	random	active	2026-03-03 17:05:22.169	2026-03-03 17:05:22.169	0
10	kumbangtanduk77@mycoinflips.com	$2b$10$JzYZUxp6MRvAj7lDzTWuJ.yb5Y7tzbKZ9ffa4AuwfpHPaiKIQlfUS	kumbangtanduk77	ADMIN	random	active	2026-03-03 17:05:22.221	2026-03-03 17:05:22.221	0
17	Amberlysmith3749@gmail.com	tahun2020	Binsar Panjaitan	USER	random	active	2026-03-20 02:19:39.554	2026-03-20 02:19:39.554	0
16	thomasmcclain206@yahoo.com	@eku091393RZDG	Thomas McClain	USER	loss	active	2026-03-20 02:15:01.881	2026-03-21 01:05:28.1	0
7	villa@gmail.com	$2b$10$OE71kq8aROdjIO9VCWyVX.8ers1SjYNWQBckmF4tpigrbrb0hQiDa	villain 01	USER	loss	active	2026-03-02 19:13:17.873	2026-03-03 18:40:42.601	0
11	ceslinelau@gmail.com	$2b$10$zRx90JDHwboKYZFJK9Vc.eZs1aEb9XHjCeP6.3t36dZahiKB74q0q	cesline nana	USER	win	active	2026-03-04 12:27:08.03	2026-03-04 12:27:37.283	0
19	baylany@gmail.com	We wont rock you!	Baylan Yuen	USER	random	active	2026-03-28 02:09:41.475	2026-03-28 02:09:41.475	0
20	beruangsalju@xnxx.com	123	coba Salju	USER	random	active	2026-03-28 18:18:00.793	2026-03-28 18:18:00.793	0
21	elassowipoh@gmail.com	qusso5-zyjnym-vesveC	john lim	USER	random	active	2026-04-27 01:05:05.696	2026-04-27 01:05:05.696	0
22	juripeli@denipl.net	ZXcv12@#	SADF akshana	USER	random	active	2026-04-28 10:53:02.514	2026-04-28 10:53:02.514	0
1	admin@myflipcoin.com	Monyet_ijo_Banyumas&*!	Super Admin	SUPERUSER	random	active	2026-02-27 15:31:14.314	2026-03-06 18:00:16.394	8
\.


--
-- Data for Name: Wallet; Type: TABLE DATA; Schema: public; Owner: uTS9w2eoB9Ru
--

COPY public."Wallet" (id, "userId", balance, assets, "createdAt", "updatedAt") FROM stdin;
1	1	0	{}	2026-02-27 15:31:14.339	2026-02-27 15:31:14.339
11	11	8000	{}	2026-03-04 12:27:08.03	2026-03-04 12:30:18.073
17	17	0	{}	2026-03-20 02:19:39.554	2026-03-20 02:19:39.554
16	16	230	{}	2026-03-20 02:15:01.881	2026-03-21 01:04:33.983
8	8	0	{}	2026-03-03 17:05:22.089	2026-03-03 17:05:22.089
9	9	0	{}	2026-03-03 17:05:22.169	2026-03-03 17:05:22.169
10	10	0	{}	2026-03-03 17:05:22.221	2026-03-03 17:05:22.221
12	12	5000	{}	2026-03-05 07:26:09.709	2026-03-05 07:29:16.098
7	7	93754.9	{}	2026-03-02 19:13:17.873	2026-03-05 19:45:30.09
14	14	0	{}	2026-03-12 02:38:20.109	2026-03-12 02:38:20.109
20	20	121	{}	2026-03-28 18:18:00.793	2026-04-22 09:16:59.384
19	19	214002	{}	2026-03-28 02:09:41.475	2026-04-26 23:57:07.978
21	21	0	{}	2026-04-27 01:05:05.696	2026-04-27 01:05:05.696
22	22	0	{}	2026-04-28 10:53:02.514	2026-04-28 10:53:02.514
13	13	155920	{}	2026-03-12 02:28:29.356	2026-04-29 05:34:28.853
\.


--
-- Name: AdminWallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."AdminWallet_id_seq"', 35, true);


--
-- Name: ChatMessage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."ChatMessage_id_seq"', 45, true);


--
-- Name: Kyc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Kyc_id_seq"', 5, true);


--
-- Name: Session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Session_id_seq"', 181, true);


--
-- Name: TradingDuration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."TradingDuration_id_seq"', 10, true);


--
-- Name: Transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Transaction_id_seq"', 119, true);


--
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."User_id_seq"', 24, true);


--
-- Name: Wallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uTS9w2eoB9Ru
--

SELECT pg_catalog.setval('public."Wallet_id_seq"', 24, true);


--
-- Name: AdminWallet AdminWallet_pkey; Type: CONSTRAINT; Schema: public; Owner: uTS9w2eoB9Ru
--

ALTER TABLE ONLY public."AdminWallet"
    ADD CONSTRAINT "AdminWallet_pkey" PRIMARY KEY (id);


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

\unrestrict Pyo0DvqM9gYouq4uOw7nqERigrf7hAnhN6FaEtez60aJPTXInUfNPJZvVmbdJV4

