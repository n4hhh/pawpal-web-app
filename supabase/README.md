PawPals Supabase setup notes

1) Run schema
- Open Supabase Dashboard -> SQL -> New query
- Paste contents of `schema.sql` and Run

2) Seed data
- `schema.sql` includes basic seed rows for quick dev. Verify tables in Table editor.

3) Images
- For dev you can use public URLs (picsum) or upload images to Storage:
  - Storage -> New bucket (name `pets`) -> Public or private
  - Upload files -> copy Public URL
  - Update `pets.image` or `feed_posts.image` to the public URL

4) RLS and Security
- For quick dev, you can enable a permissive SELECT policy on `feed_posts` and `pets`.
- For production: enable Supabase Auth and add per-table RLS policies that check `auth.uid()` and ownership.

5) REST endpoints & frontend mapping
- Supabase auto REST: `https://<project>.supabase.co/rest/v1/feed_posts?select=*`
- Example mapping to frontend `FeedPost` props:
  - petName  <= pet_name
  - ownerName <= owner_name
  - avatar   <= avatar
  - image    <= image
  - caption  <= caption
  - likes    <= likes
  - comments <= comments
  - timeAgo  <= time_ago

6) React Query hooks (suggestions)
- `usePets()` -> `supabase.from('pets').select('*')`
- `useFeed()` -> `supabase.from('feed_posts').select('*').order('created_at', { ascending: false })`
- Use `staleTime` and caching as appropriate.

7) Signed URLs (private storage)
- To serve private images, create signed URLs server-side using service_role key and return to client.

8) Next steps
- Add tables for conversations, notifications, analytics as needed.
- Create migration.sql files and put under `supabase/migrations` if you prefer versioned migrations.
