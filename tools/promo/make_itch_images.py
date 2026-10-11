"""Makes the itch.io page images in tmp/itch from bin/dr promo's shots: cover.png (630x500)
and screenshot_1..5.png (1280x720), in the order the page shows them.
Needs Pillow; bin/dr promo runs it."""
import shutil
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent.parent
PROMO = ROOT / 'tmp/promo'
SHOTS = ROOT / 'tmp/screenshots'
OUT = ROOT / 'tmp/itch'

SCREENSHOTS = [PROMO / 'classic_fall.png', PROMO / 'classic_clear.png', PROMO / 'next_stage.png',
               SHOTS / 'dr_levels.png', SHOTS / 'dr_menu.png']
W, H = 630, 500
SCREEN = (400, 0, 880, 720)  # the 400x600 screen within the 1280x720 window


def cover():
    image = Image.open(ROOT / 'assets/backdrop_game.png').convert('RGBA').crop((0, 0, W, H))
    game_h = H - 40
    game_w = round(480 * game_h / 720)
    game = Image.open(PROMO / 'classic_clear.png').convert('RGB').crop(SCREEN).resize((game_w, game_h), Image.LANCZOS)
    x, y = W - game_w - 24, 20

    shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rectangle([x + 6, y + 8, x + game_w + 6, y + game_h + 8], fill=(0, 0, 0, 140))
    image = Image.alpha_composite(image, shadow.filter(ImageFilter.GaussianBlur(8)))
    image.paste(game, (x, y))

    draw = ImageDraw.Draw(image)
    title = ImageFont.truetype(str(ROOT / 'assets/fonts/pacifico/pacifico-regular.ttf'), 84)
    tagline = ImageFont.truetype(str(ROOT / 'assets/fonts/courgette/courgette-regular.ttf'), 26)
    for text, font, top, fill in [('Timtris', title, 150, (255, 255, 255)),
                                  ('A falling-block', tagline, 285, (200, 225, 245)),
                                  ('puzzle game', tagline, 320, (200, 225, 245))]:
        box = draw.textbbox((0, 0), text, font=font)
        draw.text(((x - (box[2] - box[0])) / 2 - box[0], top - box[1]), text, font=font, fill=fill)
    image.convert('RGB').save(OUT / 'cover.png')


OUT.mkdir(parents=True, exist_ok=True)
for number, path in enumerate(SCREENSHOTS, 1):
    shutil.copy(path, OUT / f'screenshot_{number}.png')
cover()
print('\n'.join(str(p) for p in sorted(OUT.glob('*.png'))))
