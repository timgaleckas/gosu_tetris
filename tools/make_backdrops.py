"""Makes the 1280x720 images drawn either side of the 400x600 screen (scaled to 480x720):
assets/backdrop_game.png, faint blocks on the game's blue, and assets/backdrop_splash.png,
the splash photo blurred and darkened. Needs Pillow: python3 tools/make_backdrops.py"""
import random
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
W, H = 1280, 720
SIDE = (W - 480) // 2
CELL = 36  # a square at the game's 1.2x scale
BLUE = (0, 74, 127)
COLORS = ['9999FF', 'B479F2', '8888AA', '888811', '667755', '558811', '5F3F7F']
SHAPES = [
    [(0, 0), (1, 0), (2, 0), (3, 0)], [(0, 0), (1, 0), (0, 1), (1, 1)],
    [(0, 0), (1, 0), (2, 0), (1, 1)], [(0, 0), (1, 0), (2, 0), (2, 1)],
    [(0, 0), (1, 0), (2, 0), (0, 1)], [(0, 0), (1, 0), (1, 1), (2, 1)],
    [(1, 0), (2, 0), (0, 1), (1, 1)],
]


def mix(color, amount):
    return tuple(round(b + (c - b) * amount) for b, c in zip(BLUE, color))


def rotate(cells, turns):
    for _ in range(turns):
        cells = [(-y, x) for x, y in cells]
    min_x, min_y = min(x for x, _ in cells), min(y for _, y in cells)
    return [(x - min_x, y - min_y) for x, y in cells]


def game():
    rng = random.Random(4)
    image = Image.new('RGB', (W, H), BLUE)
    draw = ImageDraw.Draw(image)
    cols, rows = SIDE // CELL + 1, H // CELL + 1
    for left in (0, W - SIDE):
        taken = set()
        for _ in range(400):
            cells = rotate(rng.choice(SHAPES), rng.randrange(4))
            ox, oy = rng.randrange(-1, cols), rng.randrange(-1, rows)
            placed = [(ox + x, oy + y) for x, y in cells]
            # Keep a gap round each piece so they read as separate pieces.
            if any((px + dx, py + dy) in taken for px, py in placed for dx in (-1, 0, 1) for dy in (-1, 0, 1)):
                continue
            if rng.random() < 0.45:
                continue
            taken.update(placed)
            hex_color = rng.choice(COLORS)
            fill = mix(tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4)), 0.14)
            edge = mix((0, 0, 0), 0.25)
            for px, py in placed:
                x, y = left + px * CELL + (SIDE % CELL if left else 0), py * CELL
                draw.rectangle([x, y, x + CELL - 1, y + CELL - 1], fill=fill)
                for nx, ny, box in ((px - 1, py, [x, y, x + 1, y + CELL - 1]),
                                    (px + 1, py, [x + CELL - 2, y, x + CELL - 1, y + CELL - 1]),
                                    (px, py - 1, [x, y, x + CELL - 1, y + 1]),
                                    (px, py + 1, [x, y + CELL - 2, x + CELL - 1, y + CELL - 1])):
                    if (nx, ny) not in placed:
                        draw.rectangle(box, fill=edge)
    image.save(ROOT / 'assets/backdrop_game.png', optimize=True)


def splash():
    photo = Image.open(ROOT / 'assets/splash_screen.png').convert('RGB')
    scale = W / photo.width
    cover = photo.resize((W, round(photo.height * scale)), Image.LANCZOS)
    top = (cover.height - H) // 2
    cover = cover.crop((0, top, W, top + H)).filter(ImageFilter.GaussianBlur(28))
    ImageEnhance.Brightness(cover).enhance(0.55).save(ROOT / 'assets/backdrop_splash.png', optimize=True)


game()
splash()
