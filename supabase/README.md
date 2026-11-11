# ChatPilot Supabase

## Apply migration

SQL Editor → run:

`migrations/20261110210000_chatpilot_conversations.sql`

Auth → Providers → Email → **Confirm email = OFF** for local demos.

## Local config (gitignored)

```powershell
copy .vscode\supabase.example.json .vscode\supabase.local.json
# fill SUPABASE_URL + SUPABASE_ANON_KEY
flutter run --dart-define-from-file=.vscode/supabase.local.json
```

## Sync policy

- Local SharedPreferences is always the working set.
- Signed-in + Supabase: **pull on login** (newer `updated_at` wins per conversation id), **push on each local write**.
- Signed-out: local-only (DeepSeek still works with your API key).
