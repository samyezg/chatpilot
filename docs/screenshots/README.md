# Screenshots & demo capture

Place portfolio assets here (avoid committing huge raw videos if hosted elsewhere).

## Included

- `stream_demo.gif` — looping Mock typewriter streaming (coral UI mockup for README)

## Suggested stills (phone frame, English UI)

1. `01_conversation_list.png` — seeded chats + relative times  
2. `02_chat_stream.png` — bubbles + streaming / Markdown reply  
3. `03_persona_picker.png` — five persona cards  
4. `04_model_selector.png` — Mock / DeepSeek / GPT-4o / Claude / Gemini  
 
5. `05_settings_keys.png` — API keys + voice engine  
6. `06_mock_mode.png` — offline mock typewriter reply  
7. `07_sign_in.png` — sync sign-in form  
8. `08_sync_banner.png` — “Local only — sign in to sync” banner  
9. `09_voice_listening.png` — mic listening + partial dictation  

## 30–60s demo script

1. Open list → tap **Translator** seed chat → show history  
2. Send a short message on **Mock** → show typewriter stream  
3. Tap mic (Mock voice) → show streaming dictation → Stop → Send  
4. While assistant streams → tap **Stop** to interrupt generation  
5. Settings → API keys + voice engine (do not reveal real keys)  
6. Optional: DeepSeek / other live model with key  
7. Optional: Sign in banner → Sign in screen (Supabase configured builds)

## Commands

```powershell
. D:\AI\12-落地\工具\android_sdk_env.ps1
cd D:\AI\12-落地\作品集\02_AI聊天机器人\app
flutter run
# with cloud sync:
flutter run --dart-define-from-file=.vscode/supabase.local.json
```

Release APK (ASCII artifacts path, if script present):

```powershell
. D:\AI\12-落地\工具\flutter_build_apk.ps1 -AppDir "D:\AI\12-落地\作品集\02_AI聊天机器人\app" -AppId chatpilot -Release
```
