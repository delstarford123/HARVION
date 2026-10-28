import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_harvion_logo():
    size = (1024, 1024)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = 512, 512
    radius = 480

    # Draw circular background with gradient
    for r in range(radius, 0, -2):
        factor = r / radius
        # Interpolate between deep midnight blue and royal celestial blue
        red = int(10 + (22 - 10) * (1 - factor))
        green = int(30 + (65 - 30) * (1 - factor))
        blue = int(65 + (125 - 65) * (1 - factor))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(red, green, blue, 255))

    # Outer Gold Rings (Adventist truth & eternity)
    draw.ellipse([cx - 480, cy - 480, cx + 480, cy + 480], outline=(232, 168, 56, 180), width=6)
    draw.ellipse([cx - 468, cy - 468, cx + 468, cy + 468], outline=(244, 208, 111, 255), width=4)
    draw.ellipse([cx - 458, cy - 458, cx + 458, cy + 458], outline=(212, 143, 24, 140), width=2)

    # Decorative celestial stars/dots around perimeter
    for i in range(24):
        angle = i * (2 * math.pi / 24)
        sx = cx + int(463 * math.cos(angle))
        sy = cy + int(463 * math.sin(angle))
        draw.ellipse([sx - 3, sy - 3, sx + 3, sy + 3], fill=(255, 230, 160, 220))

    # Draw Wheat Stalks (The Harvest / Literature Evangelism Colporteurs)
    # Left Wheat Wreath
    def draw_wheat_sheaf(center_x, center_y, flip=False):
        for i in range(7):
            t = i / 6.0
            arc_angle = math.pi * 0.45 + t * math.pi * 0.45
            # arc trajectory
            cur_r = 330
            wx = center_x + (-1 if flip else 1) * int(cur_r * math.cos(arc_angle) * 0.85)
            wy = center_y + int(cur_r * math.sin(arc_angle) * 0.8) + 60
            
            # Wheat grain kernel
            grain_w = 18 - i
            grain_h = 32 - i * 2
            grain_angle = (-35 if not flip else 35) + i * 10
            
            # Draw grain oval
            draw.ellipse([wx - grain_w, wy - grain_h, wx + grain_w, wy + grain_h], 
                         fill=(245, 195, 75, 240), outline=(210, 140, 20, 255), width=2)
            # Awn / beard of wheat
            beard_dx = -35 if not flip else 35
            draw.line([wx, wy - grain_h, wx + beard_dx, wy - grain_h - 25], fill=(245, 215, 120, 220), width=3)

    draw_wheat_sheaf(cx - 80, cy - 40, flip=False)
    draw_wheat_sheaf(cx + 80, cy - 40, flip=True)

    # Golden Heavenly Rays from top center
    for a in range(-60, 65, 8):
        rad = math.radians(a + 90)
        rx = cx + int(420 * math.cos(rad))
        ry = cy - 60 + int(420 * math.sin(rad))
        draw.line([cx, cy - 100, rx, ry], fill=(244, 208, 111, 40), width=4)

    # Three Angels Flame (Holy Spirit & Gospel proclamation)
    flame_pts = [
        (cx, cy - 290),          # Peak
        (cx + 42, cy - 210),
        (cx + 65, cy - 150),
        (cx + 45, cy - 90),
        (cx, cy - 65),
        (cx - 45, cy - 90),
        (cx - 65, cy - 150),
        (cx - 42, cy - 210),
    ]
    draw.polygon(flame_pts, fill=(240, 140, 30, 230))
    # Inner bright flame
    inner_flame = [
        (cx, cy - 260),
        (cx + 25, cy - 190),
        (cx + 35, cy - 140),
        (cx + 20, cy - 95),
        (cx, cy - 75),
        (cx - 20, cy - 95),
        (cx - 35, cy - 140),
        (cx - 25, cy - 190),
    ]
    draw.polygon(inner_flame, fill=(255, 235, 130, 255))

    # Open Holy Bible
    # Book Base shadow
    draw.polygon([
        (cx - 260, cy + 180),
        (cx, cy + 225),
        (cx + 260, cy + 180),
        (cx + 260, cy + 205),
        (cx, cy + 250),
        (cx - 260, cy + 205),
    ], fill=(130, 85, 20, 255))

    # Book Pages - Left Page
    left_page = [
        (cx - 8, cy - 40),
        (cx - 245, cy - 10),
        (cx - 255, cy + 165),
        (cx - 8, cy + 145),
    ]
    draw.polygon(left_page, fill=(252, 250, 242, 255), outline=(210, 180, 120, 255))

    # Left Page Curves/Folds
    for offset in range(3, 15, 3):
        draw.line([(cx - 255 + offset, cy + 165 + offset), (cx - 8, cy + 145 + offset)], fill=(215, 195, 155, 200), width=2)

    # Book Pages - Right Page
    right_page = [
        (cx + 8, cy - 40),
        (cx + 245, cy - 10),
        (cx + 255, cy + 165),
        (cx + 8, cy + 145),
    ]
    draw.polygon(right_page, fill=(255, 253, 248, 255), outline=(210, 180, 120, 255))

    # Right Page Curves/Folds
    for offset in range(3, 15, 3):
        draw.line([(cx + 8, cy + 145 + offset), (cx + 255 - offset, cy + 165 + offset)], fill=(215, 195, 155, 200), width=2)

    # Scripture text lines on pages (Sacred Word)
    for row in range(7):
        ly = cy + 5 + row * 18
        draw.line([(cx - 220, ly), (cx - 35, ly - 8)], fill=(120, 130, 145, 180), width=3)
        draw.line([(cx + 35, ly - 8), (cx + 220, ly)], fill=(120, 130, 145, 180), width=3)

    # Center Spine Bookmark Ribbon (Royal Red)
    draw.polygon([
        (cx - 7, cy - 40),
        (cx + 7, cy - 40),
        (cx + 10, cy + 220),
        (cx, cy + 195),
        (cx - 10, cy + 220),
    ], fill=(190, 30, 45, 255))

    # Harvion Gold Banner Plaque at Bottom
    banner_rect = [cx - 280, cy + 245, cx + 280, cy + 345]
    draw.rounded_rectangle(banner_rect, radius=24, fill=(13, 30, 56, 250), outline=(244, 208, 111, 255), width=4)
    # Inner gold accent line
    draw.rounded_rectangle([cx - 272, cy + 253, cx + 272, cy + 337], radius=18, outline=(212, 143, 24, 180), width=2)

    # Text "HARVION" on the banner
    # Use default bitmap or draw custom bold letter geometry for crystal clear text
    # Let's draw crisp geometric letter strokes for H A R V I O N
    letter_color = (255, 225, 120, 255)
    shadow_color = (80, 50, 10, 200)

    def draw_harvion_text(ox, oy, color):
        # H
        draw.line([(ox, oy), (ox, oy + 46)], fill=color, width=7)
        draw.line([(ox + 30, oy), (ox + 30, oy + 46)], fill=color, width=7)
        draw.line([(ox, oy + 23), (ox + 30, oy + 23)], fill=color, width=7)

        # A
        ox += 48
        draw.line([(ox, oy + 46), (ox + 16, oy)], fill=color, width=7)
        draw.line([(ox + 16, oy), (ox + 32, oy + 46)], fill=color, width=7)
        draw.line([(ox + 7, oy + 26), (ox + 25, oy + 26)], fill=color, width=6)

        # R
        ox += 50
        draw.line([(ox, oy), (ox, oy + 46)], fill=color, width=7)
        draw.line([(ox, oy), (ox + 22, oy)], fill=color, width=6)
        draw.line([(ox + 22, oy), (ox + 30, oy + 12)], fill=color, width=6)
        draw.line([(ox + 30, oy + 12), (ox + 22, oy + 24)], fill=color, width=6)
        draw.line([(ox, oy + 24), (ox + 22, oy + 24)], fill=color, width=6)
        draw.line([(ox + 14, oy + 24), (ox + 30, oy + 46)], fill=color, width=7)

        # V
        ox += 48
        draw.line([(ox, oy), (ox + 16, oy + 46)], fill=color, width=7)
        draw.line([(ox + 16, oy + 46), (ox + 32, oy)], fill=color, width=7)

        # I
        ox += 50
        draw.line([(ox, oy), (ox + 20, oy)], fill=color, width=5)
        draw.line([(ox + 10, oy), (ox + 10, oy + 46)], fill=color, width=7)
        draw.line([(ox, oy + 46), (ox + 20, oy + 46)], fill=color, width=5)

        # O
        ox += 38
        draw.ellipse([ox, oy, ox + 36, oy + 46], outline=color, width=7)

        # N
        ox += 52
        draw.line([(ox, oy), (ox, oy + 46)], fill=color, width=7)
        draw.line([(ox, oy), (ox + 30, oy + 46)], fill=color, width=6)
        draw.line([(ox + 30, oy), (ox + 30, oy + 46)], fill=color, width=7)

    # Subtitle: SEVENTH-DAY ADVENTIST MINISTRY
    # Draw drop shadow then gold text
    text_start_x = cx - 180
    text_start_y = cy + 268
    draw_harvion_text(text_start_x + 2, text_start_y + 2, shadow_color)
    draw_harvion_text(text_start_x, text_start_y, letter_color)

    # Subtitle ribbon below
    draw.text((cx - 130, cy + 360), "LITERATURE EVANGELISM & HEALTH", fill=(210, 225, 240, 220))

    return img

if __name__ == "__main__":
    logo = create_harvion_logo()
    
    # Save to targets
    logo.save("assets/icons/Tobeused.png", "PNG")
    logo.save("assets/icons/icon1.png", "PNG")
    logo.save("assets/images/harvion_logo.png", "PNG")
    print("HARVION logo generated successfully in assets/icons/ and assets/images/!")
