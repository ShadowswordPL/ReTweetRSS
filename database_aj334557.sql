--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: addtweets(integer, integer); Type: FUNCTION; Schema: public; Owner: 11643591_bd
--

CREATE FUNCTION addtweets(uid integer, numbof integer) RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE
  size int;
  sumc int;
  added int;
  j int;
  vid int;
  vc int;
  cont varchar;
  l varchar;
  m int;
  d date;
  byl int;
  uidtest int;
  numof int;
BEGIN
  select count(*) INTO uidtest FROM user_data WHERE id = uid;
  IF uidtest = 0 THEN raise exception 'USER DONT EXIST'; END IF;
  CREATE TEMP TABLE arr AS 
  (
  SELECT
     id, count as c
  FROM
  (
     SELECT 
         * 
     FROM 
         messege
     WHERE 
         id
     NOT IN
     (
         SELECT
             messege_id
         FROM
             tweets
      )
   ) AS msg
   LEFT JOIN
   (
       SELECT 
           m.feed_id, count(shared) AS count
       FROM 
           "tweets"
       RIGHT JOIN 
       (
           SELECT id, feed_id FROM "messege" WHERE feed_id IN
           (
               SELECT id FROM "feed" WHERE user_id = uid
           ) 
       ) m
       ON
           "messege_id" = m.id
       GROUP BY
           m.feed_id
   ) m
   ON
       msg.feed_id = m.feed_id
  ); 
  SELECT count(*), sum(c) INTO size, sumc FROM arr; 
  SELECT mood, last_number INTO m, numof FROM user_data WHERE id = uid;

  IF numof < size THEN
      size := numof;
  END IF;    
  
  added = 0;
  j = 0;

  WHILE size > added LOOP
      FOR vid, vc IN SELECT id, c FROM arr LOOP
          SELECT count(*) INTO byl FROM tweets WHERE messege_id = vid;
          IF random()*100 < (vc*100/size + 2) AND byl = 0 THEN
            added := added + 1;
                SELECT date, short_link INTO d, l FROM messege WHERE id = vid;
            IF random() * 10 < 5 THEN
                SELECT '\"' || substring(substring(content from '\[\.\].\{10,122\}\[\.\]'), 3, 130) || '\"' INTO cont FROM messege WHERE id = vid;
            ELSE
                IF random() * 5 <= m THEN
                    SELECT content INTO cont FROM gloss RIGHT JOIN usergloss ON id = gloss_id WHERE user_id = uid AND ispositive = True ORDER BY random() LIMIT 1;
                ELSE
                    SELECT content INTO cont FROM gloss RIGHT JOIN usergloss ON id = gloss_id WHERE user_id = uid AND ispositive = False ORDER BY random() LIMIT 1;
                END IF;
            END IF;
            INSERT INTO tweets (messege_id, content, date) VALUES (vid, coalesce(cont, '') || ' ' || l, d);
            IF size <= added THEN EXIT; END IF;
          END IF;
      END LOOP;
  END LOOP;
 
  
END$$;


ALTER FUNCTION public.addtweets(uid integer, numbof integer) OWNER TO "11643591_bd";

--
-- Name: polish_stem; Type: TEXT SEARCH DICTIONARY; Schema: public; Owner: radoslaw.ziemniewicz
--

CREATE TEXT SEARCH DICTIONARY polish_stem (
    TEMPLATE = pg_catalog.ispell,
    dictfile = 'polish', afffile = 'polish', stopwords = 'polish' );


ALTER TEXT SEARCH DICTIONARY public.polish_stem OWNER TO "radoslaw.ziemniewicz";

--
-- Name: polish; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: radoslaw.ziemniewicz
--

CREATE TEXT SEARCH CONFIGURATION polish (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR asciiword WITH polish_stem, simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR word WITH polish_stem, simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR hword_part WITH polish_stem, simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR hword_asciipart WITH polish_stem, simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR asciihword WITH polish_stem, simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR hword WITH polish_stem, simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION polish
    ADD MAPPING FOR uint WITH simple;


ALTER TEXT SEARCH CONFIGURATION public.polish OWNER TO "radoslaw.ziemniewicz";

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: feed; Type: TABLE; Schema: public; Owner: 11643591_bd; Tablespace: 
--

CREATE TABLE feed (
    id integer NOT NULL,
    name character varying,
    link character varying,
    user_id integer
);


ALTER TABLE public.feed OWNER TO "11643591_bd";

--
-- Name: feed_id_seq; Type: SEQUENCE; Schema: public; Owner: 11643591_bd
--

CREATE SEQUENCE feed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.feed_id_seq OWNER TO "11643591_bd";

--
-- Name: feed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 11643591_bd
--

ALTER SEQUENCE feed_id_seq OWNED BY feed.id;


--
-- Name: gloss; Type: TABLE; Schema: public; Owner: 11643591_bd; Tablespace: 
--

CREATE TABLE gloss (
    id integer NOT NULL,
    content character varying,
    ispositive boolean
);


ALTER TABLE public.gloss OWNER TO "11643591_bd";

--
-- Name: gloss_id_seq; Type: SEQUENCE; Schema: public; Owner: 11643591_bd
--

CREATE SEQUENCE gloss_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gloss_id_seq OWNER TO "11643591_bd";

--
-- Name: gloss_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 11643591_bd
--

ALTER SEQUENCE gloss_id_seq OWNED BY gloss.id;


--
-- Name: messege; Type: TABLE; Schema: public; Owner: 11643591_bd; Tablespace: 
--

CREATE TABLE messege (
    id integer NOT NULL,
    feed_id integer NOT NULL,
    date date NOT NULL,
    title character varying NOT NULL,
    content character varying NOT NULL,
    link character varying NOT NULL,
    short_link character varying NOT NULL
);


ALTER TABLE public.messege OWNER TO "11643591_bd";

--
-- Name: messege_id_seq; Type: SEQUENCE; Schema: public; Owner: 11643591_bd
--

CREATE SEQUENCE messege_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messege_id_seq OWNER TO "11643591_bd";

--
-- Name: messege_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 11643591_bd
--

ALTER SEQUENCE messege_id_seq OWNED BY messege.id;


--
-- Name: tweets; Type: TABLE; Schema: public; Owner: 11643591_bd; Tablespace: 
--

CREATE TABLE tweets (
    id integer NOT NULL,
    messege_id integer NOT NULL,
    content character varying NOT NULL,
    shared integer DEFAULT 0 NOT NULL,
    date date NOT NULL,
    send boolean DEFAULT false NOT NULL,
    tweetnum character varying
);


ALTER TABLE public.tweets OWNER TO "11643591_bd";

--
-- Name: tweets_id_seq; Type: SEQUENCE; Schema: public; Owner: 11643591_bd
--

CREATE SEQUENCE tweets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tweets_id_seq OWNER TO "11643591_bd";

--
-- Name: tweets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 11643591_bd
--

ALTER SEQUENCE tweets_id_seq OWNED BY tweets.id;


--
-- Name: user_data; Type: TABLE; Schema: public; Owner: 11643591_bd; Tablespace: 
--

CREATE TABLE user_data (
    twitter_id bigint NOT NULL,
    auth_token integer NOT NULL,
    mood integer DEFAULT 5 NOT NULL,
    id integer NOT NULL,
    last_number integer DEFAULT 5 NOT NULL
);


ALTER TABLE public.user_data OWNER TO "11643591_bd";

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: 11643591_bd
--

CREATE SEQUENCE user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO "11643591_bd";

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 11643591_bd
--

ALTER SEQUENCE user_id_seq OWNED BY user_data.id;


--
-- Name: usergloss; Type: TABLE; Schema: public; Owner: 11643591_bd; Tablespace: 
--

CREATE TABLE usergloss (
    user_id integer NOT NULL,
    gloss_id integer NOT NULL
);


ALTER TABLE public.usergloss OWNER TO "11643591_bd";

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: 11643591_bd
--

ALTER TABLE ONLY feed ALTER COLUMN id SET DEFAULT nextval('feed_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: 11643591_bd
--

ALTER TABLE ONLY gloss ALTER COLUMN id SET DEFAULT nextval('gloss_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: 11643591_bd
--

ALTER TABLE ONLY messege ALTER COLUMN id SET DEFAULT nextval('messege_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: 11643591_bd
--

ALTER TABLE ONLY tweets ALTER COLUMN id SET DEFAULT nextval('tweets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: 11643591_bd
--

ALTER TABLE ONLY user_data ALTER COLUMN id SET DEFAULT nextval('user_id_seq'::regclass);


--
-- Name: gloss_pkey; Type: CONSTRAINT; Schema: public; Owner: 11643591_bd; Tablespace: 
--

ALTER TABLE ONLY gloss
    ADD CONSTRAINT gloss_pkey PRIMARY KEY (id);


--
-- Name: tweets_pkey; Type: CONSTRAINT; Schema: public; Owner: 11643591_bd; Tablespace: 
--

ALTER TABLE ONLY tweets
    ADD CONSTRAINT tweets_pkey PRIMARY KEY (id);


--
-- Name: user_pkey; Type: CONSTRAINT; Schema: public; Owner: 11643591_bd; Tablespace: 
--

ALTER TABLE ONLY user_data
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: pgsql
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM pgsql;
GRANT ALL ON SCHEMA public TO pgsql;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: feed; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON TABLE feed FROM PUBLIC;
REVOKE ALL ON TABLE feed FROM "11643591_bd";
GRANT ALL ON TABLE feed TO "11643591_bd";


--
-- Name: feed_id_seq; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON SEQUENCE feed_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE feed_id_seq FROM "11643591_bd";
GRANT ALL ON SEQUENCE feed_id_seq TO "11643591_bd";


--
-- Name: gloss; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON TABLE gloss FROM PUBLIC;
REVOKE ALL ON TABLE gloss FROM "11643591_bd";
GRANT ALL ON TABLE gloss TO "11643591_bd";


--
-- Name: gloss_id_seq; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON SEQUENCE gloss_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gloss_id_seq FROM "11643591_bd";
GRANT ALL ON SEQUENCE gloss_id_seq TO "11643591_bd";


--
-- Name: messege; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON TABLE messege FROM PUBLIC;
REVOKE ALL ON TABLE messege FROM "11643591_bd";
GRANT ALL ON TABLE messege TO "11643591_bd";


--
-- Name: messege_id_seq; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON SEQUENCE messege_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE messege_id_seq FROM "11643591_bd";
GRANT ALL ON SEQUENCE messege_id_seq TO "11643591_bd";


--
-- Name: user_data; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON TABLE user_data FROM PUBLIC;
REVOKE ALL ON TABLE user_data FROM "11643591_bd";
GRANT ALL ON TABLE user_data TO "11643591_bd";


--
-- Name: user_id_seq; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON SEQUENCE user_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE user_id_seq FROM "11643591_bd";
GRANT ALL ON SEQUENCE user_id_seq TO "11643591_bd";


--
-- Name: usergloss; Type: ACL; Schema: public; Owner: 11643591_bd
--

REVOKE ALL ON TABLE usergloss FROM PUBLIC;
REVOKE ALL ON TABLE usergloss FROM "11643591_bd";
GRANT ALL ON TABLE usergloss TO "11643591_bd";


--
-- PostgreSQL database dump complete
--
