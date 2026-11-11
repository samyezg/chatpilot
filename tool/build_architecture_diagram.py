"""Generate the ChatPilot architecture diagram (16:9 PNG) for portfolio use.

Layers follow the real feature-first layout under lib/features:
Presentation -> Domain -> Data -> External services. English labels, Coral theme.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parents[1] / "docs" / "screenshots" / "architecture.png"

W, H = 1920, 1080
M = 60
BAR_W = 170
CARDS_X = M + BAR_W + 20
CARDS_W = W - M - CARDS_X

# Theme
BG = (249, 250, 251)
WHITE = (255, 255, 255)
TEXT = (17, 24, 39)
SUB = (107, 114, 128)

LAYERS = {
    "l1": {"bar": (234, 88, 12), "band": (253, 243, 238), "border": (240, 184, 150)},
    "l2": {"bar": (71, 85, 105), "band": (241, 245, 249), "border": (203, 213, 225)},
    "l3": {"bar": (22, 163, 74), "band": (240, 247, 242), "border": (187, 229, 200)},
    "l4": {"bar": (107, 114, 128), "band": (243, 244, 246), "border": (209, 213, 219)},
}

FONT_REG = r"C:\Windows\Fonts\arial.ttf"
FONT_BOLD = r"C:\Windows\Fonts\arialbd.ttf"


def f(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)


def center_text(d: ImageDraw.Draw, cx: int, y: int, text: str, font: ImageFont.FreeTypeFont, fill) -> None:
    box = d.textbbox((0, 0), text, font=font)
    tw = box[2] - box[0]
    d.text((cx - tw / 2, y), text, font=font, fill=fill)


def rounded(d: ImageDraw.Draw, x: int, y: int, w: int, h: int, fill, border, radius: int = 14, width: int = 2) -> None:
    d.rounded_rectangle([x, y, x + w, y + h], radius=radius, fill=fill, outline=border, width=width)


def card(canvas: Image.Image, x: int, y: int, w: int, h: int, title: str,
         lines: list[str], border: tuple, title_size: int = 18, line_size: int = 15) -> None:
    d = ImageDraw.Draw(canvas)
    rounded(d, x, y, w, h, WHITE, border)
    center_text(d, x + w / 2, y + 14, title, f(title_size, True), TEXT)
    ly = y + 14 + title_size + 8
    for line in lines:
        center_text(d, x + w / 2, ly, line, f(line_size), SUB)
        ly += line_size + 6


def layer_band(canvas: Image.Image, y: int, h: int, key: str, label: str, sub: str) -> None:
    d = ImageDraw.Draw(canvas)
    c = LAYERS[key]
    d.rounded_rectangle([M, y, W - M, y + h], radius=18, fill=c["band"], outline=c["border"], width=2)
    d.rounded_rectangle([M, y, M + BAR_W, y + h], radius=18, fill=c["bar"])
    # square off inner edge of the bar so it reads as a side rail
    d.rectangle([M + BAR_W - 24, y, M + BAR_W, y + h], fill=c["bar"])
    center_text(d, M + BAR_W / 2, y + h / 2 - 26, label, f(21, True), WHITE)
    center_text(d, M + BAR_W / 2, y + h / 2 + 14, sub, f(14), (255, 255, 255))


def down_arrow(canvas: Image.Image, x: int, y: int) -> None:
    d = ImageDraw.Draw(canvas)
    d.line([x, y, x, y + 16], fill=SUB, width=3)
    d.polygon([(x - 8, y + 16), (x + 8, y + 16), (x, y + 26)], fill=SUB)


def main() -> None:
    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)

    # Title
    d.text((M, 40), "ChatPilot Architecture", font=f(44, True), fill=TEXT)
    d.text((M, 102), "Flutter + Riverpod  ·  Feature-first  ·  Local-first offline chat", font=f(22), fill=SUB)

    # ---- Layer 1: Presentation ----
    l1_y, l1_h = 150, 196
    layer_band(canvas, l1_y, l1_h, "l1", "Presentation", "UI layer")
    page_titles = ["Chat Page", "Conversation List", "Persona Picker", "Settings", "Sign In & Up"]
    gap = 16
    cw = (CARDS_W - 4 * gap) / 5
    for i, t in enumerate(page_titles):
        x = CARDS_X + i * (cw + gap)
        card(canvas, int(x), l1_y + 22, int(cw), 72, t, [], LAYERS["l1"]["border"], title_size=17)
    wide_w = (CARDS_W - gap) / 2
    card(canvas, CARDS_X, l1_y + 108, int(wide_w), 66, "Riverpod Providers & Notifiers", [],
         LAYERS["l1"]["border"], title_size=17)
    card(canvas, int(CARDS_X + wide_w + gap), l1_y + 108, int(wide_w), 66,
         "Shared Widgets", ["Bubble · Input · Model Selector · Persona Card"],
         LAYERS["l1"]["border"], title_size=17, line_size=14)

    # ---- Layer 2: Domain ----
    l2_y, l2_h = 370, 128
    layer_band(canvas, l2_y, l2_h, "l2", "Domain", "Contracts & entities")
    repo_titles = ["ChatRepository", "ConversationsRepository", "AuthRepository", "StreamingSttEngine"]
    cw2 = (CARDS_W - 4 * gap) / 5
    for i, t in enumerate(repo_titles):
        x = CARDS_X + i * (cw2 + gap)
        card(canvas, int(x), l2_y + 22, int(cw2), 88, t, [], LAYERS["l2"]["border"], title_size=15)
    ex_x = CARDS_X + 4 * (cw2 + gap)
    card(canvas, int(ex_x), l2_y + 22, int(cw2), 88, "Entities",
         ["Message · Conversation", "Persona · AiModel · AuthUser"],
         LAYERS["l2"]["border"], title_size=15, line_size=13)

    # ---- Layer 3: Data ----
    l3_y, l3_h = 522, 250
    layer_band(canvas, l3_y, l3_h, "l3", "Data", "Implementations")
    cols = [
        ("Chat backends", ["Mock · DeepSeek", "OpenAI-compatible", "Claude · Gemini", "SSE streaming"]),
        ("Conversations", ["Local (SharedPrefs)", "In-memory", "Supabase Sync", "Merge / Codec · Seed"]),
        ("Auth & Voice", ["Supabase Auth · Fake", "Auto · Device STT", "Whisper · Mock engines"]),
        ("Settings stores", ["API Keys", "Locale", "Voice settings"]),
    ]
    cw3 = (CARDS_W - 3 * gap) / 4
    for i, (title, lines) in enumerate(cols):
        x = CARDS_X + i * (cw3 + gap)
        card(canvas, int(x), l3_y + 24, int(cw3), 200, title, lines,
             LAYERS["l3"]["border"], title_size=17, line_size=15)

    # ---- Layer 4: External ----
    l4_y, l4_h = 796, 168
    layer_band(canvas, l4_y, l4_h, "l4", "External", "Services & platform")
    ext = [
        ("LLM Vendors", ["DeepSeek", "OpenAI GPT-4o", "Anthropic Claude 3.5", "Google Gemini 1.5"]),
        ("Supabase", ["Email auth", "Postgres (RLS)"]),
        ("On-device", ["SharedPreferences"]),
        ("Speech-to-text", ["Device recognition", "Whisper API"]),
    ]
    for i, (title, lines) in enumerate(ext):
        x = CARDS_X + i * (cw3 + gap)
        card(canvas, int(x), l4_y + 20, int(cw3), 136, title, lines,
             LAYERS["l4"]["border"], title_size=17, line_size=15)

    # Layer arrows on the rail center
    rail_cx = M + BAR_W / 2
    for ay in (l1_y + l1_h, l2_y + l2_h, l3_y + l3_h):
        down_arrow(canvas, int(rail_cx), ay + 4)

    # Cross-cutting strip
    strip_y = 992
    d.rounded_rectangle([M, strip_y, W - M, strip_y + 56], radius=14, fill=WHITE, outline=LAYERS["l2"]["border"], width=2)
    center_text(d, W / 2, strip_y + 18,
                "Cross-cutting:  Localization EN / ZH   ·   Theme tokens   ·   Router   ·   Environment config",
                f(18), TEXT)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUT, quality=95)
    print(f"wrote {OUT} {canvas.size}")


if __name__ == "__main__":
    main()
