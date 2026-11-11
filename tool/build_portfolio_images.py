"""Build portfolio platform images from raw ChatPilot screenshots.

Pipeline: raw capture -> crop status bar / overlay capsule -> platform template.
Raw files stay untouched in raw/; finished images go to fiverr/ instagram/ chengjubao/.
"""
from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "docs" / "screenshots" / "raw"
OUT = ROOT / "docs" / "screenshots"

CROP_TOP = 100  # remove status bar + "协同中" overlay capsule, keep AppBar

# Palette (coral theme)
BG = (249, 250, 251)
SURFACE = (255, 255, 255)
BORDER = (229, 231, 235)
TEXT = (17, 24, 39)
SECONDARY = (107, 114, 128)
ORANGE = (234, 88, 12)

FONT_REG = r"C:\Windows\Fonts\arial.ttf"
FONT_BOLD = r"C:\Windows\Fonts\arialbd.ttf"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)


def load_clean(name: str, crop_top2: int = 0) -> Image.Image:
    with Image.open(RAW / name) as im:
        w, h = im.size
        clean = im.crop((0, CROP_TOP, w, h))
        if crop_top2:
            clean = clean.crop((0, crop_top2, clean.size[0], clean.size[1]))
        return clean.convert("RGB")


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return mask


def fit_height(im: Image.Image, target_h: int) -> Image.Image:
    w, h = im.size
    target_w = round(w * target_h / h)
    return im.resize((target_w, target_h), Image.LANCZOS)


def fit_width(im: Image.Image, target_w: int) -> Image.Image:
    w, h = im.size
    target_h = round(h * target_w / w)
    return im.resize((target_w, target_h), Image.LANCZOS)


def paste_rounded(canvas: Image.Image, shot: Image.Image, x: int, y: int, radius: int = 18) -> None:
    mask = rounded_mask(shot.size, radius)
    canvas.paste(shot, (x, y), mask)
    d = ImageDraw.Draw(canvas)
    d.rounded_rectangle([x, y, x + shot.size[0] - 1, y + shot.size[1] - 1],
                        radius=radius, outline=BORDER, width=2)


# ---- Platform templates ----------------------------------------------------

def fiverr_4x3(shot: Image.Image, title: str, subtitle: str) -> Image.Image:
    W, H = 1400, 1050
    canvas = Image.new("RGB", (W, H), SURFACE)
    d = ImageDraw.Draw(canvas)

    d.text((72, 56), title, fill=TEXT, font=font(40, True))
    d.text((72, 118), subtitle, fill=SECONDARY, font=font(22))

    shot_h = 800
    shot_r = fit_height(shot, shot_h)
    x = (W - shot_r.size[0]) // 2
    y = 170
    paste_rounded(canvas, shot_r, x, y)
    return canvas


def instagram_4x5(shot: Image.Image, title: str, subtitle: str) -> Image.Image:
    W, H = 1080, 1350
    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)

    d.text((72, 72), title, fill=TEXT, font=font(36, True))
    d.text((72, 128), subtitle, fill=SECONDARY, font=font(21))

    shot_h = 1020
    shot_r = fit_height(shot, shot_h)
    x = (W - shot_r.size[0]) // 2
    y = 180
    paste_rounded(canvas, shot_r, x, y)
    return canvas


def chengjubao_16x9(shot: Image.Image, title: str, subtitle: str) -> Image.Image:
    W, H = 1920, 1080
    canvas = Image.new("RGB", (W, H), SURFACE)
    d = ImageDraw.Draw(canvas)

    d.text((72, 64), title, fill=TEXT, font=font(38, True))
    d.text((72, 124), subtitle, fill=SECONDARY, font=font(22))

    shot_h = 880
    shot_r = fit_height(shot, shot_h)
    x = (W - shot_r.size[0]) // 2
    y = (H - shot_r.size[1]) // 2
    paste_rounded(canvas, shot_r, x, y)
    return canvas


# ---- Asset manifest ---------------------------------------------------------

# key: raw file, title, subtitle, target platforms
ASSETS: list[dict] = [
    {
        "key": "01_conversation_list",
        "raw": "01_conversation_list_raw.png",
        "title": "Conversations",
        "subtitle": "Seeded chats with relative timestamps, saved locally first",
        "platforms": ["fiverr", "instagram", "chengjubao"],
    },
    {
        "key": "02_chat_translator",
        "raw": "02_chat_translator_raw.png",
        "title": "Multi-persona AI chat",
        "subtitle": "Translate, polish, review and tutor in one offline-first app",
        "platforms": ["fiverr", "instagram", "chengjubao"],
    },
    {
        "key": "03_persona_picker",
        "raw": "03_persona_picker_raw.png",
        "title": "Five built-in personas",
        "subtitle": "General, Translator, Writer, Engineer, Tutor",
        "platforms": ["fiverr", "instagram", "chengjubao"],
    },
    {
        "key": "04_model_selector",
        "raw": "04_model_selector_raw.png",
        "title": "Five model backends",
        "subtitle": "Mock offline plus DeepSeek, GPT-4o, Claude 3.5, Gemini 1.5",
        "platforms": ["fiverr", "instagram", "chengjubao"],
    },
    {
        "key": "05_settings_overview",
        "raw": "05_settings_overview_raw.png",
        "title": "Settings and account sync",
        "subtitle": "Language, API keys and Supabase sync in one place",
        "platforms": ["instagram"],
    },
    {
        "key": "06_settings_keys_a",
        "raw": "06_settings_keys_a_raw.png",
        "title": "Bring your own keys",
        "subtitle": "Provider keys stay on device, never bundled or committed",
        "platforms": ["fiverr", "chengjubao"],
    },
    {
        "key": "07_models_status",
        "raw": "07_models_status_raw.png",
        "title": "Offline Mock mode",
        "subtitle": "Local mock stream works without any API key",
        "platforms": ["fiverr", "instagram"],
        "clean_crop_top": 260,
    },
    {
        "key": "08_voice_engine",
        "raw": "08_voice_engine_raw.png",
        "title": "Streaming voice dictation",
        "subtitle": "Mic input with interrupt; device STT, Whisper, then Mock",
        "platforms": ["instagram", "chengjubao"],
    },
    {
        "key": "09_language_selector",
        "raw": "09_language_selector_raw.png",
        "title": "English / Chinese UI",
        "subtitle": "Follow system language, lock English or Chinese",
        "platforms": ["instagram"],
    },
    {
        "key": "10_sign_in",
        "raw": "10_sign_in_raw.png",
        "title": "Optional cloud sync",
        "subtitle": "Sign in with Supabase to sync history across devices",
        "platforms": ["fiverr", "instagram", "chengjubao"],
    },
    {
        "key": "11_chat_engineer",
        "raw": "11_chat_engineer_raw.png",
        "title": "Code review assistant",
        "subtitle": "Null-safety review and safer Dart examples",
        "platforms": ["instagram"],
    },
    {
        "key": "12_chat_writer",
        "raw": "12_chat_writer_raw.png",
        "title": "Writing assistant",
        "subtitle": "Polish, expand and shorten email drafts",
        "platforms": ["instagram"],
    },
    {
        "key": "15_voice_listening",
        "raw": "15_voice_listening_raw.png",
        "title": "Voice input with Stop",
        "subtitle": "Partial transcription and one-tap interrupt",
        "platforms": ["instagram"],
    },
]


def main() -> None:
    for asset in ASSETS:
        shot = load_clean(asset["raw"], asset.get("clean_crop_top", 0))
        for platform in asset["platforms"]:
            if platform == "fiverr":
                img = fiverr_4x3(shot, asset["title"], asset["subtitle"])
                out_dir = OUT / "fiverr"
                name = f"{asset['key']}_4x3.png"
            elif platform == "instagram":
                img = instagram_4x5(shot, asset["title"], asset["subtitle"])
                out_dir = OUT / "instagram"
                name = f"{asset['key']}_4x5.png"
            else:
                img = chengjubao_16x9(shot, asset["title"], asset["subtitle"])
                out_dir = OUT / "chengjubao"
                name = f"{asset['key']}_16x9.png"
            out_dir.mkdir(parents=True, exist_ok=True)
            img.save(out_dir / name, quality=92)
            print(f"wrote {out_dir.name}/{name} {img.size}")


if __name__ == "__main__":
    main()
