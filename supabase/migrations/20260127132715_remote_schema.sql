


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


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."feed_posts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pet_name" "text" NOT NULL,
    "owner_name" "text" NOT NULL,
    "avatar" "text",
    "image" "text",
    "caption" "text",
    "likes" integer DEFAULT 0,
    "comments" integer DEFAULT 0,
    "time_ago" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."feed_posts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "age" "text",
    "breed" "text",
    "location" "text",
    "image" "text",
    "bio" "text",
    "owner" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."pets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "email" character varying(255) NOT NULL,
    "full_name" character varying(255),
    "phone_number" character varying(20),
    "age" integer,
    "bio" "text",
    "favorite_breed" character varying(255),
    "avatar_url" character varying(500),
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'feed_posts_pkey'
            AND conrelid = 'public.feed_posts'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."feed_posts"
            ADD CONSTRAINT "feed_posts_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pets_pkey'
            AND conrelid = 'public.pets'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pets"
            ADD CONSTRAINT "pets_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'profiles_email_key'
            AND conrelid = 'public.profiles'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."profiles"
            ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'profiles_pkey'
            AND conrelid = 'public.profiles'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."profiles"
            ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



CREATE INDEX IF NOT EXISTS "idx_profiles_email" ON "public"."profiles" USING "btree" ("email");



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'profiles_id_fkey'
            AND conrelid = 'public.profiles'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."profiles"
            ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
            AND tablename = 'feed_posts'
            AND policyname = 'Allow select for anon'
    ) THEN
        CREATE POLICY "Allow select for anon" ON "public"."feed_posts" FOR SELECT USING (true);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
            AND tablename = 'pets'
            AND policyname = 'Allow select for anon'
    ) THEN
        CREATE POLICY "Allow select for anon" ON "public"."pets" FOR SELECT USING (true);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
            AND tablename = 'profiles'
            AND policyname = 'Users can insert own profile'
    ) THEN
        CREATE POLICY "Users can insert own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
            AND tablename = 'profiles'
            AND policyname = 'Users can read own profile'
    ) THEN
        CREATE POLICY "Users can read own profile" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "id"));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
            AND tablename = 'profiles'
            AND policyname = 'Users can update own profile'
    ) THEN
        CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));
    END IF;
END $$;



ALTER TABLE "public"."feed_posts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";


















GRANT ALL ON TABLE "public"."feed_posts" TO "anon";
GRANT ALL ON TABLE "public"."feed_posts" TO "authenticated";
GRANT ALL ON TABLE "public"."feed_posts" TO "service_role";



GRANT ALL ON TABLE "public"."pets" TO "anon";
GRANT ALL ON TABLE "public"."pets" TO "authenticated";
GRANT ALL ON TABLE "public"."pets" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































drop extension if exists "pg_net";

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'on_auth_user_created'
            AND tgrelid = 'auth.users'::regclass
    ) THEN
        CREATE TRIGGER on_auth_user_created
            AFTER INSERT ON auth.users
            FOR EACH ROW
            EXECUTE FUNCTION public.handle_new_user();
    END IF;
END $$;


