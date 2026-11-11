# Screenshots & demo capture

Portfolio stills and a short streaming GIF for README / social. Raw phone captures stay local (`raw/` is gitignored).

## Included

| Path | Purpose |
| :--- | :--- |
| `stream_demo.gif` | Looping Mock typewriter stream (README hero) |
| `architecture.png` | High-level module diagram |
| `fiverr/` | 4×3 crops for marketplace / README gallery |
| `instagram/` | 4×5 crops for vertical social |
| `chengjubao/` | 16×9 crops for landscape decks |

## Suggested stills (English UI)

1. Conversation list  
2. Chat (Translator / stream)  
3. Persona picker  
4. Model selector  
5. Settings overview / API keys  
6. Models status  
7. Voice engine  
8. Language selector  
9. Sign in  
10. Voice listening (optional)

## 30–60s demo script

1. Open list → tap **Translator** seed chat → show history  
2. Send a short message on **Mock** → show typewriter stream  
3. Tap mic (**Device** or **Whisper**) → show listening / partials → Stop → Send  
4. While assistant streams → tap **Stop** to interrupt generation  
5. Settings → API keys + voice engine (do not reveal real keys)  
6. Optional: DeepSeek / other live model with key  
7. Optional: Sign in banner → Sign in screen (Supabase-configured builds)

## Local regen (maintainers)

From this repo root (or your private working copy):

```bash
flutter pub get
flutter run
# with cloud sync:
flutter run --dart-define-from-file=.vscode/supabase.local.json
```

Optional image tooling in `tool/`:

- `make_stream_gif.py` — README GIF  
- `build_architecture_diagram.py` — architecture PNG  
- `build_portfolio_images.py` — platform crops from raw captures  

Do not commit `raw/` or temporary `_*.png` probe files.
