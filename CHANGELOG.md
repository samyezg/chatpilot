# Changelog

All notable changes to ChatPilot are documented in this file.

## 1.0.0 — 2026-11-11

### Added

- Initial public release of the Flutter ChatPilot app
- Multi-model chat: Mock, DeepSeek, OpenAI GPT-4o, Claude 3.5, Gemini 1.5 (streaming)
- Voice dictation: device STT / OpenAI Whisper / Mock with interrupt
- Personas, Markdown bubbles, local conversation persistence
- Optional Supabase auth + local-first conversation sync
- Coral-orange brand (icon + `ThemePalette.coral`); indigo palette retained as switch
- Application id `com.samyezg.chatpilot`
- CI workflow (`flutter analyze` + `flutter test`)
- Streaming demo GIF under `docs/screenshots/`

### Notes

- API keys are never shipped; configure in Settings or via your own secrets
- Supabase is optional; use `.vscode/supabase.example.json` as a template
