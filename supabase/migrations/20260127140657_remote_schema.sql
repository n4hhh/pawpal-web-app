


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
    "avatar" "text",
    "image" "text",
    "caption" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "author_id" "uuid",
    "pet_id" "uuid"
);


ALTER TABLE "public"."feed_posts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."order_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid",
    "product_id" "uuid",
    "quantity" integer NOT NULL,
    "price" numeric(10,2) NOT NULL
);


ALTER TABLE "public"."order_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "status" "text" DEFAULT 'pending'::"text",
    "total" numeric(10,2),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."orders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pet_matches" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pet_a" "uuid",
    "pet_b" "uuid",
    "matched_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."pet_matches" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pet_messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "match_id" "uuid",
    "sender_pet_id" "uuid",
    "content" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."pet_messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pet_preferences" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pet_id" "uuid",
    "preferred_breed" "text",
    "preferred_age_min" integer,
    "preferred_age_max" integer,
    "max_distance_km" integer,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."pet_preferences" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pet_swipes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "from_pet_id" "uuid",
    "to_pet_id" "uuid",
    "liked" boolean NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."pet_swipes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "age" "text",
    "breed" "text",
    "location" "text",
    "image" "text",
    "bio" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "owner_id" "uuid"
);


ALTER TABLE "public"."pets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."post_comments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "post_id" "uuid",
    "user_id" "uuid",
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."post_comments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."post_likes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "post_id" "uuid",
    "user_id" "uuid"
);


ALTER TABLE "public"."post_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."product_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL
);


ALTER TABLE "public"."product_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."product_category_map" (
    "product_id" "uuid" NOT NULL,
    "category_id" "uuid" NOT NULL
);


ALTER TABLE "public"."product_category_map" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "price" numeric(10,2) NOT NULL,
    "image_url" "text",
    "stock" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."products" OWNER TO "postgres";


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
        WHERE conname = 'order_items_pkey'
            AND conrelid = 'public.order_items'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."order_items"
            ADD CONSTRAINT "order_items_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'orders_pkey'
            AND conrelid = 'public.orders'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."orders"
            ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_matches_pet_a_pet_b_key'
            AND conrelid = 'public.pet_matches'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_matches"
            ADD CONSTRAINT "pet_matches_pet_a_pet_b_key" UNIQUE ("pet_a", "pet_b");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_matches_pkey'
            AND conrelid = 'public.pet_matches'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_matches"
            ADD CONSTRAINT "pet_matches_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_messages_pkey'
            AND conrelid = 'public.pet_messages'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_messages"
            ADD CONSTRAINT "pet_messages_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_preferences_pkey'
            AND conrelid = 'public.pet_preferences'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_preferences"
            ADD CONSTRAINT "pet_preferences_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_swipes_from_pet_id_to_pet_id_key'
            AND conrelid = 'public.pet_swipes'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_swipes"
            ADD CONSTRAINT "pet_swipes_from_pet_id_to_pet_id_key" UNIQUE ("from_pet_id", "to_pet_id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_swipes_pkey'
            AND conrelid = 'public.pet_swipes'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_swipes"
            ADD CONSTRAINT "pet_swipes_pkey" PRIMARY KEY ("id");
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
        WHERE conname = 'post_comments_pkey'
            AND conrelid = 'public.post_comments'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."post_comments"
            ADD CONSTRAINT "post_comments_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'post_likes_pkey'
            AND conrelid = 'public.post_likes'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."post_likes"
            ADD CONSTRAINT "post_likes_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'post_likes_post_id_user_id_key'
            AND conrelid = 'public.post_likes'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."post_likes"
            ADD CONSTRAINT "post_likes_post_id_user_id_key" UNIQUE ("post_id", "user_id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'product_categories_pkey'
            AND conrelid = 'public.product_categories'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."product_categories"
            ADD CONSTRAINT "product_categories_pkey" PRIMARY KEY ("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'product_category_map_pkey'
            AND conrelid = 'public.product_category_map'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."product_category_map"
            ADD CONSTRAINT "product_category_map_pkey" PRIMARY KEY ("product_id", "category_id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'products_pkey'
            AND conrelid = 'public.products'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."products"
            ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");
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
        WHERE conname = 'feed_posts_author_id_fkey'
            AND conrelid = 'public.feed_posts'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."feed_posts"
            ADD CONSTRAINT "feed_posts_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "auth"."users"("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'feed_posts_pet_id_fkey'
            AND conrelid = 'public.feed_posts'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."feed_posts"
            ADD CONSTRAINT "feed_posts_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "public"."pets"("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'order_items_order_id_fkey'
            AND conrelid = 'public.order_items'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."order_items"
            ADD CONSTRAINT "order_items_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'order_items_product_id_fkey'
            AND conrelid = 'public.order_items'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."order_items"
            ADD CONSTRAINT "order_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'orders_user_id_fkey'
            AND conrelid = 'public.orders'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."orders"
            ADD CONSTRAINT "orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_matches_pet_a_fkey'
            AND conrelid = 'public.pet_matches'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_matches"
            ADD CONSTRAINT "pet_matches_pet_a_fkey" FOREIGN KEY ("pet_a") REFERENCES "public"."pets"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_matches_pet_b_fkey'
            AND conrelid = 'public.pet_matches'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_matches"
            ADD CONSTRAINT "pet_matches_pet_b_fkey" FOREIGN KEY ("pet_b") REFERENCES "public"."pets"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_messages_match_id_fkey'
            AND conrelid = 'public.pet_messages'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_messages"
            ADD CONSTRAINT "pet_messages_match_id_fkey" FOREIGN KEY ("match_id") REFERENCES "public"."pet_matches"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_messages_sender_pet_id_fkey'
            AND conrelid = 'public.pet_messages'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_messages"
            ADD CONSTRAINT "pet_messages_sender_pet_id_fkey" FOREIGN KEY ("sender_pet_id") REFERENCES "public"."pets"("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_preferences_pet_id_fkey'
            AND conrelid = 'public.pet_preferences'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_preferences"
            ADD CONSTRAINT "pet_preferences_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "public"."pets"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_swipes_from_pet_id_fkey'
            AND conrelid = 'public.pet_swipes'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_swipes"
            ADD CONSTRAINT "pet_swipes_from_pet_id_fkey" FOREIGN KEY ("from_pet_id") REFERENCES "public"."pets"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pet_swipes_to_pet_id_fkey'
            AND conrelid = 'public.pet_swipes'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pet_swipes"
            ADD CONSTRAINT "pet_swipes_to_pet_id_fkey" FOREIGN KEY ("to_pet_id") REFERENCES "public"."pets"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'pets_owner_id_fkey'
            AND conrelid = 'public.pets'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."pets"
            ADD CONSTRAINT "pets_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id");
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'post_comments_post_id_fkey'
            AND conrelid = 'public.post_comments'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."post_comments"
            ADD CONSTRAINT "post_comments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."feed_posts"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'post_comments_user_id_fkey'
            AND conrelid = 'public.post_comments'::regclass
    ) AND EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'post_comments'
          AND column_name = 'user_id'
          AND udt_name = 'uuid'
    ) THEN
        ALTER TABLE ONLY "public"."post_comments"
            ADD CONSTRAINT "post_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'post_likes_post_id_fkey'
            AND conrelid = 'public.post_likes'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."post_likes"
            ADD CONSTRAINT "post_likes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."feed_posts"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'post_likes_user_id_fkey'
            AND conrelid = 'public.post_likes'::regclass
    ) AND EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'post_likes'
          AND column_name = 'user_id'
          AND udt_name = 'uuid'
    ) THEN
        ALTER TABLE ONLY "public"."post_likes"
            ADD CONSTRAINT "post_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'product_category_map_category_id_fkey'
            AND conrelid = 'public.product_category_map'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."product_category_map"
            ADD CONSTRAINT "product_category_map_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."product_categories"("id") ON DELETE CASCADE;
    END IF;
END $$;



DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'product_category_map_product_id_fkey'
            AND conrelid = 'public.product_category_map'::regclass
    ) THEN
        ALTER TABLE ONLY "public"."product_category_map"
            ADD CONSTRAINT "product_category_map_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;
    END IF;
END $$;



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



GRANT ALL ON TABLE "public"."order_items" TO "anon";
GRANT ALL ON TABLE "public"."order_items" TO "authenticated";
GRANT ALL ON TABLE "public"."order_items" TO "service_role";



GRANT ALL ON TABLE "public"."orders" TO "anon";
GRANT ALL ON TABLE "public"."orders" TO "authenticated";
GRANT ALL ON TABLE "public"."orders" TO "service_role";



GRANT ALL ON TABLE "public"."pet_matches" TO "anon";
GRANT ALL ON TABLE "public"."pet_matches" TO "authenticated";
GRANT ALL ON TABLE "public"."pet_matches" TO "service_role";



GRANT ALL ON TABLE "public"."pet_messages" TO "anon";
GRANT ALL ON TABLE "public"."pet_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."pet_messages" TO "service_role";



GRANT ALL ON TABLE "public"."pet_preferences" TO "anon";
GRANT ALL ON TABLE "public"."pet_preferences" TO "authenticated";
GRANT ALL ON TABLE "public"."pet_preferences" TO "service_role";



GRANT ALL ON TABLE "public"."pet_swipes" TO "anon";
GRANT ALL ON TABLE "public"."pet_swipes" TO "authenticated";
GRANT ALL ON TABLE "public"."pet_swipes" TO "service_role";



GRANT ALL ON TABLE "public"."pets" TO "anon";
GRANT ALL ON TABLE "public"."pets" TO "authenticated";
GRANT ALL ON TABLE "public"."pets" TO "service_role";



GRANT ALL ON TABLE "public"."post_comments" TO "anon";
GRANT ALL ON TABLE "public"."post_comments" TO "authenticated";
GRANT ALL ON TABLE "public"."post_comments" TO "service_role";



GRANT ALL ON TABLE "public"."post_likes" TO "anon";
GRANT ALL ON TABLE "public"."post_likes" TO "authenticated";
GRANT ALL ON TABLE "public"."post_likes" TO "service_role";



GRANT ALL ON TABLE "public"."product_categories" TO "anon";
GRANT ALL ON TABLE "public"."product_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."product_categories" TO "service_role";



GRANT ALL ON TABLE "public"."product_category_map" TO "anon";
GRANT ALL ON TABLE "public"."product_category_map" TO "authenticated";
GRANT ALL ON TABLE "public"."product_category_map" TO "service_role";



GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";



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


