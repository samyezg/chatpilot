"""Generate a looping Mock streaming demo GIF for README."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parents[1] / "docs" / "screenshots" / "stream_demo.gif"

W, H = 390, 720
BG = (249, 250, 251)
SURFACE = (255, 255, 255)
BORDER = (229, 231, 235)
TEXT = (17, 24, 39)
SECONDARY = (107, 114, 128)
ORANGE = (234, 88, 12)
ORANGE_SOFT = (255, 247, 237)
ASSIST = (243, 244, 246)


def wrap(s: str, width: int = 28) -> list[str]:
    words = s.split(" ")
    lines: list[str] = []
    cur = ""
    for word in words:
        trial = (cur + " " + word).strip()
        if len(trial) > width:
            if cur:
                lines.append(cur)
            cur = word
        else:
            cur = trial
    if cur:
        lines.append(cur)
    return lines or [""]


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    try:
        font_title = ImageFont.truetype("arial.ttf", 22)
        font_sm = ImageFont.truetype("arial.ttf", 14)
    except OSError:
        font_title = ImageFont.load_default()
        font_sm = font_title

    full = "Streaming works offline with Mock — typewriter style, no API key."
    steps = [full[:i] for i in range(0, len(full) + 1, 3)]
    if steps[-1] != full:
        steps.append(full)
    steps += [full] * 8

    frames: list[Image.Image] = []
    for idx, text in enumerate(steps):
        im = Image.new("RGB", (W, H), BG)
        d = ImageDraw.Draw(im)

        d.rectangle([0, 0, W, 64], fill=SURFACE)
        d.line([0, 64, W, 64], fill=BORDER)
        d.text((16, 18), "ChatPilot", fill=ORANGE, font=font_title)
        d.text((W - 110, 22), "Mock", fill=SECONDARY, font=font_sm)

        d.rounded_rectangle([120, 96, W - 16, 160], radius=16, fill=ORANGE)
        d.text((136, 116), "Show a streaming reply.", fill=(255, 255, 255), font=font_sm)

        show_cursor = idx < len(steps) - 4
        lines = wrap(text + ("|" if show_cursor else ""))
        bubble_h = 28 + 22 * max(len(lines), 1)
        d.rounded_rectangle(
            [16, 180, W - 48, 180 + bubble_h],
            radius=16,
            fill=ASSIST,
            outline=BORDER,
        )
        y = 192
        for line in lines:
            d.text((32, y), line, fill=TEXT, font=font_sm)
            y += 22

        d.rounded_rectangle([16, H - 72, W - 72, H - 24], radius=20, fill=SURFACE, outline=BORDER)
        d.text((32, H - 58), "Message", fill=SECONDARY, font=font_sm)
        d.ellipse([W - 60, H - 68, W - 20, H - 28], fill=ORANGE)
        d.text((W - 48, H - 56), "Stop", fill=(255, 255, 255), font=font_sm)

        d.rounded_rectangle([16, H - 110, 150, H - 82], radius=8, fill=ORANGE_SOFT)
        d.text((28, H - 106), "coral #EA580C", fill=ORANGE, font=font_sm)

        frames.append(im)

    frames[0].save(
        OUT,
        save_all=True,
        append_images=frames[1:],
        duration=90,
        loop=0,
        optimize=True,
    )
    print(f"wrote {OUT} frames={len(frames)} bytes={OUT.stat().st_size}")


if __name__ == "__main__":
    main()
