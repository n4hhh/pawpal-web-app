
  create table "public"."purchases" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "item_id" uuid,
    "quantity" integer default 1,
    "amount_paid" numeric(10,2),
    "created_at" timestamp with time zone default now()
      );


alter table "public"."purchases" enable row level security;


  create table "public"."shop_items" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "description" text,
    "price" numeric(10,2) not null,
    "image" text,
    "stock" integer default 0,
    "created_at" timestamp with time zone default now(),
    "images" text[]
      );


alter table "public"."shop_items" enable row level security;


  create table "public"."users" (
    "id" uuid not null default gen_random_uuid(),
    "email" text,
    "username" text,
    "display_name" text,
    "avatar" text,
    "bio" text,
    "created_at" timestamp with time zone default now()
      );


CREATE UNIQUE INDEX purchases_pkey ON public.purchases USING btree (id);

CREATE UNIQUE INDEX shop_items_pkey ON public.shop_items USING btree (id);

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);

alter table "public"."purchases" add constraint "purchases_pkey" PRIMARY KEY using index "purchases_pkey";

alter table "public"."shop_items" add constraint "shop_items_pkey" PRIMARY KEY using index "shop_items_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."matches" add constraint "matches_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE not valid;

alter table "public"."matches" validate constraint "matches_user_id_fkey";

alter table "public"."messages" add constraint "messages_recipient_id_fkey" FOREIGN KEY (recipient_id) REFERENCES public.users(id) ON DELETE SET NULL not valid;

alter table "public"."messages" validate constraint "messages_recipient_id_fkey";

alter table "public"."messages" add constraint "messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE SET NULL not valid;

alter table "public"."messages" validate constraint "messages_sender_id_fkey";

alter table "public"."purchases" add constraint "purchases_item_id_fkey" FOREIGN KEY (item_id) REFERENCES public.shop_items(id) ON DELETE SET NULL not valid;

alter table "public"."purchases" validate constraint "purchases_item_id_fkey";

alter table "public"."purchases" add constraint "purchases_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL not valid;

alter table "public"."purchases" validate constraint "purchases_user_id_fkey";

alter table "public"."users" add constraint "users_email_key" UNIQUE using index "users_email_key";

alter table "public"."users" add constraint "users_username_key" UNIQUE using index "users_username_key";

grant delete on table "public"."purchases" to "anon";

grant insert on table "public"."purchases" to "anon";

grant references on table "public"."purchases" to "anon";

grant select on table "public"."purchases" to "anon";

grant trigger on table "public"."purchases" to "anon";

grant truncate on table "public"."purchases" to "anon";

grant update on table "public"."purchases" to "anon";

grant delete on table "public"."purchases" to "authenticated";

grant insert on table "public"."purchases" to "authenticated";

grant references on table "public"."purchases" to "authenticated";

grant select on table "public"."purchases" to "authenticated";

grant trigger on table "public"."purchases" to "authenticated";

grant truncate on table "public"."purchases" to "authenticated";

grant update on table "public"."purchases" to "authenticated";

grant delete on table "public"."purchases" to "service_role";

grant insert on table "public"."purchases" to "service_role";

grant references on table "public"."purchases" to "service_role";

grant select on table "public"."purchases" to "service_role";

grant trigger on table "public"."purchases" to "service_role";

grant truncate on table "public"."purchases" to "service_role";

grant update on table "public"."purchases" to "service_role";

grant delete on table "public"."shop_items" to "anon";

grant insert on table "public"."shop_items" to "anon";

grant references on table "public"."shop_items" to "anon";

grant select on table "public"."shop_items" to "anon";

grant trigger on table "public"."shop_items" to "anon";

grant truncate on table "public"."shop_items" to "anon";

grant update on table "public"."shop_items" to "anon";

grant delete on table "public"."shop_items" to "authenticated";

grant insert on table "public"."shop_items" to "authenticated";

grant references on table "public"."shop_items" to "authenticated";

grant select on table "public"."shop_items" to "authenticated";

grant trigger on table "public"."shop_items" to "authenticated";

grant truncate on table "public"."shop_items" to "authenticated";

grant update on table "public"."shop_items" to "authenticated";

grant delete on table "public"."shop_items" to "service_role";

grant insert on table "public"."shop_items" to "service_role";

grant references on table "public"."shop_items" to "service_role";

grant select on table "public"."shop_items" to "service_role";

grant trigger on table "public"."shop_items" to "service_role";

grant truncate on table "public"."shop_items" to "service_role";

grant update on table "public"."shop_items" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";


  create policy "Purchases: self delete"
  on "public"."purchases"
  as permissive
  for delete
  to public
using (((user_id)::text = (auth.uid())::text));



  create policy "Purchases: self insert"
  on "public"."purchases"
  as permissive
  for insert
  to public
with check (((user_id)::text = (auth.uid())::text));



  create policy "Purchases: self select"
  on "public"."purchases"
  as permissive
  for select
  to public
using (((user_id)::text = (auth.uid())::text));



  create policy "Purchases: self update"
  on "public"."purchases"
  as permissive
  for update
  to public
using (((user_id)::text = (auth.uid())::text))
with check (((user_id)::text = (auth.uid())::text));



  create policy "ShopItems: public select"
  on "public"."shop_items"
  as permissive
  for select
  to public
using (true);



