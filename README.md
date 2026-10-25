# Mobile Budget App

Expo/React Native budget app with Supabase email authentication/RLS, per-user SQLite cache, offline outbox, timestamp-based last-write-wins synchronization, account selection, currency validation, monthly spending bars and pure logic tests. Account creation requires connectivity; transaction entry works from cached accounts.

## Run

Create a Supabase project and run schema.sql. Copy .env.example to .env with its public URL/anon key. `npm install && npm test && npm start`. Last-write-wins assumes reasonably synchronized client clocks.
