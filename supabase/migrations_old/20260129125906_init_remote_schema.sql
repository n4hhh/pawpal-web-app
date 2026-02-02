


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


CREATE TABLE IF NOT EXISTS "public"."matches" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "pet_id" "uuid",
    "status" "text" DEFAULT 'pending'::"text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."matches" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "conversation_id" "uuid",
    "sender_id" "uuid",
    "recipient_id" "uuid",
    "body" "text",
    "delivered" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


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
    "user_id" "text",
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


CREATE TABLE IF NOT EXISTS "public"."purchases" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "item_id" "uuid",
    "quantity" integer DEFAULT 1,
    "amount_paid" numeric(10,2),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."purchases" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."shop_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "price" numeric(10,2) NOT NULL,
    "image" "text",
    "stock" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "images" "text"[]
);


ALTER TABLE "public"."shop_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "email" "text",
    "username" "text",
    "display_name" "text",
    "avatar" "text",
    "bio" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."feed_posts"
    ADD CONSTRAINT "feed_posts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pet_matches"
    ADD CONSTRAINT "pet_matches_pet_a_pet_b_key" UNIQUE ("pet_a", "pet_b");



ALTER TABLE ONLY "public"."pet_matches"
    ADD CONSTRAINT "pet_matches_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pet_messages"
    ADD CONSTRAINT "pet_messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pet_preferences"
    ADD CONSTRAINT "pet_preferences_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pet_swipes"
    ADD CONSTRAINT "pet_swipes_from_pet_id_to_pet_id_key" UNIQUE ("from_pet_id", "to_pet_id");



ALTER TABLE ONLY "public"."pet_swipes"
    ADD CONSTRAINT "pet_swipes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pets"
    ADD CONSTRAINT "pets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."post_comments"
    ADD CONSTRAINT "post_comments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_post_id_user_id_key" UNIQUE ("post_id", "user_id");



ALTER TABLE ONLY "public"."product_categories"
    ADD CONSTRAINT "product_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."product_category_map"
    ADD CONSTRAINT "product_category_map_pkey" PRIMARY KEY ("product_id", "category_id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."shop_items"
    ADD CONSTRAINT "shop_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_username_key" UNIQUE ("username");



CREATE INDEX "idx_feed_posts_created" ON "public"."feed_posts" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_messages_conv" ON "public"."messages" USING "btree" ("conversation_id");



CREATE INDEX "idx_pets_owner" ON "public"."pets" USING "btree" ("owner_id");



CREATE INDEX "idx_profiles_email" ON "public"."profiles" USING "btree" ("email");



ALTER TABLE ONLY "public"."feed_posts"
    ADD CONSTRAINT "feed_posts_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."feed_posts"
    ADD CONSTRAINT "feed_posts_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "public"."pets"("id");



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "public"."pets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."matches"
    ADD CONSTRAINT "matches_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."pet_matches"
    ADD CONSTRAINT "pet_matches_pet_a_fkey" FOREIGN KEY ("pet_a") REFERENCES "public"."pets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pet_matches"
    ADD CONSTRAINT "pet_matches_pet_b_fkey" FOREIGN KEY ("pet_b") REFERENCES "public"."pets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pet_messages"
    ADD CONSTRAINT "pet_messages_match_id_fkey" FOREIGN KEY ("match_id") REFERENCES "public"."pet_matches"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pet_messages"
    ADD CONSTRAINT "pet_messages_sender_pet_id_fkey" FOREIGN KEY ("sender_pet_id") REFERENCES "public"."pets"("id");



ALTER TABLE ONLY "public"."pet_preferences"
    ADD CONSTRAINT "pet_preferences_pet_id_fkey" FOREIGN KEY ("pet_id") REFERENCES "public"."pets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pet_swipes"
    ADD CONSTRAINT "pet_swipes_from_pet_id_fkey" FOREIGN KEY ("from_pet_id") REFERENCES "public"."pets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pet_swipes"
    ADD CONSTRAINT "pet_swipes_to_pet_id_fkey" FOREIGN KEY ("to_pet_id") REFERENCES "public"."pets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pets"
    ADD CONSTRAINT "pets_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."post_comments"
    ADD CONSTRAINT "post_comments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."feed_posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."feed_posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."post_likes"
    ADD CONSTRAINT "post_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product_category_map"
    ADD CONSTRAINT "product_category_map_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."product_categories"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product_category_map"
    ADD CONSTRAINT "product_category_map_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."shop_items"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



CREATE POLICY "Allow public insert" ON "public"."feed_posts" FOR INSERT WITH CHECK (true);



CREATE POLICY "Allow public select" ON "public"."feed_posts" FOR SELECT USING (true);



CREATE POLICY "Allow select for anon" ON "public"."feed_posts" FOR SELECT USING (true);



CREATE POLICY "Allow select for anon" ON "public"."pets" FOR SELECT USING (true);



CREATE POLICY "Feed: delete owner" ON "public"."feed_posts" FOR DELETE USING (("author_id" = "auth"."uid"()));



CREATE POLICY "Feed: insert as owner" ON "public"."feed_posts" FOR INSERT WITH CHECK (("author_id" = "auth"."uid"()));



CREATE POLICY "Feed: public select" ON "public"."feed_posts" FOR SELECT USING (true);



CREATE POLICY "Feed: update owner" ON "public"."feed_posts" FOR UPDATE USING (("author_id" = "auth"."uid"())) WITH CHECK (("author_id" = "auth"."uid"()));



CREATE POLICY "Messages: sender delete" ON "public"."messages" FOR DELETE USING (("sender_id" = "auth"."uid"()));



CREATE POLICY "Messages: sender insert" ON "public"."messages" FOR INSERT WITH CHECK (("sender_id" = "auth"."uid"()));



CREATE POLICY "Messages: sender update" ON "public"."messages" FOR UPDATE USING (("sender_id" = "auth"."uid"())) WITH CHECK (("sender_id" = "auth"."uid"()));



CREATE POLICY "OrderItems: order owner select" ON "public"."order_items" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_items"."order_id") AND ("o"."user_id" = "auth"."uid"())))));



CREATE POLICY "Orders: self delete" ON "public"."orders" FOR DELETE USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Orders: self insert" ON "public"."orders" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Orders: self select" ON "public"."orders" FOR SELECT USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Orders: self update" ON "public"."orders" FOR UPDATE USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "PetMatches: participant select" ON "public"."pet_matches" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = ANY (ARRAY["pet_matches"."pet_a", "pet_matches"."pet_b"])) AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetMessages: participant select" ON "public"."pet_messages" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."pet_matches" "m"
     JOIN "public"."pets" "p" ON ((("p"."id" = "m"."pet_a") OR ("p"."id" = "m"."pet_b"))))
  WHERE (("m"."id" = "pet_messages"."match_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetMessages: sender delete" ON "public"."pet_messages" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_messages"."sender_pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetMessages: sender insert" ON "public"."pet_messages" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_messages"."sender_pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetMessages: sender update" ON "public"."pet_messages" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_messages"."sender_pet_id") AND ("p"."owner_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_messages"."sender_pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetPreferences: owner delete" ON "public"."pet_preferences" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_preferences"."pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetPreferences: owner insert" ON "public"."pet_preferences" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_preferences"."pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetPreferences: owner select" ON "public"."pet_preferences" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_preferences"."pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetPreferences: owner update" ON "public"."pet_preferences" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_preferences"."pet_id") AND ("p"."owner_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_preferences"."pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetSwipes: owner delete" ON "public"."pet_swipes" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_swipes"."from_pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetSwipes: owner insert" ON "public"."pet_swipes" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_swipes"."from_pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetSwipes: owner select" ON "public"."pet_swipes" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_swipes"."from_pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "PetSwipes: owner update" ON "public"."pet_swipes" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_swipes"."from_pet_id") AND ("p"."owner_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."pets" "p"
  WHERE (("p"."id" = "pet_swipes"."from_pet_id") AND ("p"."owner_id" = "auth"."uid"())))));



CREATE POLICY "Pets: owner delete" ON "public"."pets" FOR DELETE USING (("owner_id" = "auth"."uid"()));



CREATE POLICY "Pets: owner insert" ON "public"."pets" FOR INSERT WITH CHECK (("owner_id" = "auth"."uid"()));



CREATE POLICY "Pets: owner update" ON "public"."pets" FOR UPDATE USING (("owner_id" = "auth"."uid"())) WITH CHECK (("owner_id" = "auth"."uid"()));



CREATE POLICY "Pets: public select" ON "public"."pets" FOR SELECT USING (true);



CREATE POLICY "PostComments: author delete" ON "public"."post_comments" FOR DELETE USING (("user_id" = ("auth"."uid"())::"text"));



CREATE POLICY "PostComments: author insert" ON "public"."post_comments" FOR INSERT WITH CHECK (("user_id" = ("auth"."uid"())::"text"));



CREATE POLICY "PostComments: author update" ON "public"."post_comments" FOR UPDATE USING (("user_id" = ("auth"."uid"())::"text")) WITH CHECK (("user_id" = ("auth"."uid"())::"text"));



CREATE POLICY "PostComments: public select" ON "public"."post_comments" FOR SELECT USING (true);



CREATE POLICY "PostLikes: delete by profile" ON "public"."post_likes" FOR DELETE USING (("user_id" = "auth"."uid"()));



CREATE POLICY "PostLikes: insert by profile" ON "public"."post_likes" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "PostLikes: public select" ON "public"."post_likes" FOR SELECT USING (true);



CREATE POLICY "ProductCategories: public select" ON "public"."product_categories" FOR SELECT USING (true);



CREATE POLICY "ProductCategoryMap: public select" ON "public"."product_category_map" FOR SELECT USING (true);



CREATE POLICY "Products: public select" ON "public"."products" FOR SELECT USING (true);



CREATE POLICY "Profiles: self delete" ON "public"."profiles" FOR DELETE USING (("auth"."uid"() = "id"));



CREATE POLICY "Profiles: self insert" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Profiles: self select" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Profiles: self update" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Purchases: self delete" ON "public"."purchases" FOR DELETE USING ((("user_id")::"text" = ("auth"."uid"())::"text"));



CREATE POLICY "Purchases: self insert" ON "public"."purchases" FOR INSERT WITH CHECK ((("user_id")::"text" = ("auth"."uid"())::"text"));



CREATE POLICY "Purchases: self select" ON "public"."purchases" FOR SELECT USING ((("user_id")::"text" = ("auth"."uid"())::"text"));



CREATE POLICY "Purchases: self update" ON "public"."purchases" FOR UPDATE USING ((("user_id")::"text" = ("auth"."uid"())::"text")) WITH CHECK ((("user_id")::"text" = ("auth"."uid"())::"text"));



CREATE POLICY "ShopItems: public select" ON "public"."shop_items" FOR SELECT USING (true);



CREATE POLICY "Users can insert own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can read own profile" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



ALTER TABLE "public"."feed_posts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."matches" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."order_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pet_matches" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pet_messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pet_preferences" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pet_swipes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."post_comments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."post_likes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."product_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."product_category_map" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."purchases" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."shop_items" ENABLE ROW LEVEL SECURITY;




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



GRANT ALL ON TABLE "public"."matches" TO "anon";
GRANT ALL ON TABLE "public"."matches" TO "authenticated";
GRANT ALL ON TABLE "public"."matches" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



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



GRANT ALL ON TABLE "public"."purchases" TO "anon";
GRANT ALL ON TABLE "public"."purchases" TO "authenticated";
GRANT ALL ON TABLE "public"."purchases" TO "service_role";



GRANT ALL ON TABLE "public"."shop_items" TO "anon";
GRANT ALL ON TABLE "public"."shop_items" TO "authenticated";
GRANT ALL ON TABLE "public"."shop_items" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";









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

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


  create policy "Allow public reads"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'pet-images'::text));



  create policy "Allow public uploads"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check ((bucket_id = 'pet-images'::text));



