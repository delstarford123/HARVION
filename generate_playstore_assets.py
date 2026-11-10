import os
import shutil
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUTPUT_DIR = r"c:\Users\Delstaford\vine\assets\playstore"
ARTIFACT_DIR = r"C:\Users\Delstaford\.gemini\antigravity\brain\b93df4c7-c410-4434-83c5-714e7a48c83c"
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(ARTIFACT_DIR, exist_ok=True)

LOGO_PATH = r"c:\Users\Delstaford\vine\assets\images\harvion_logo.png"

# ==========================================
# 1. GENERATE APP ICON (512x512 PNG)
# ==========================================
def generate_app_icon():
    print("[1/2] Generating Google Play Store 512x512 Icon...")
    logo = Image.open(LOGO_PATH).convert("RGBA")
    
    # High-quality Lanczos resize to exactly 512x512
    icon_512 = logo.resize((512, 512), Image.Resampling.LANCZOS)
    
    # Save target outputs
    dest1 = os.path.join(OUTPUT_DIR, "playstore_icon_512.png")
    dest2 = os.path.join(ARTIFACT_DIR, "playstore_icon_512.png")
    icon_512.save(dest1, "PNG", optimize=True)
    icon_512.save(dest2, "PNG", optimize=True)
    print(f"✓ App Icon saved to {dest1} (Size: {icon_512.size})")
    return dest1

# ==========================================
# 2. GENERATE FEATURE GRAPHIC (1024x500 PNG)
# ==========================================
def generate_feature_graphic():
    print("[2/2] Generating Google Play Store 1024x500 Feature Graphic...")
    width, height = 1024, 500
    canvas = Image.new("RGBA", (width, height), (8, 19, 37, 255)) # Brand dark navy
    draw = ImageDraw.Draw(canvas)

    # 1. Subtle Radial / Gradient Glow in background
    # Celestial Gold Radial Glow at Center-Left (x=240, y=250)
    for r in range(400, 0, -4):
        alpha = int(35 * (1 - r / 400.0))
        draw.ellipse([240 - r, 250 - r, 240 + r, 250 + r], fill=(212, 175, 55, alpha))

    # Royal Blue gradient band on right side
    for x in range(450, width):
        factor = (x - 450) / (width - 450)
        alpha = int(25 * factor)
        draw.line([(x, 0), (x, height)], fill=(26, 54, 93, alpha), width=1)

    # Decorative top and bottom gold accent rules
    draw.line([(0, 0), (width, 0)], fill=(212, 175, 55, 200), width=3)
    draw.line([(0, height - 2), (width, height - 2)], fill=(212, 175, 55, 200), width=3)

    # 2. Place Harvion Circular Logo on the Left
    logo = Image.open(LOGO_PATH).convert("RGBA")
    logo_size = 380
    logo_resized = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
    
    # Outer Glow / Drop Shadow for the logo
    logo_x = 55
    logo_y = (height - logo_size) // 2
    
    # Gold Ring around the logo
    ring_pad = 8
    draw.ellipse(
        [logo_x - ring_pad, logo_y - ring_pad, logo_x + logo_size + ring_pad, logo_y + logo_size + ring_pad],
        outline=(212, 175, 55, 220),
        width=4
    )
    canvas.paste(logo_resized, (logo_x, logo_y), logo_resized)

    # 3. Fonts
    font_cinzel_large = ImageFont.truetype("C:/Windows/Fonts/georgiab.ttf", 52)
    font_cinzel_sub = ImageFont.truetype("C:/Windows/Fonts/georgiab.ttf", 15)
    font_feature_title = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 18)
    font_feature_sub = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 15)
    font_badge = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 13)

    # 4. Text Content on the Right
    text_x = 475

    # Badge: SEVENTH-DAY ADVENTIST ECOSYSTEM
    badge_y = 48
    draw.rounded_rectangle(
        [text_x, badge_y, text_x + 310, badge_y + 26],
        radius=13,
        fill=(212, 175, 55, 35),
        outline=(212, 175, 55, 120),
        width=1
    )
    draw.text((text_x + 14, badge_y + 5), "SEVENTH-DAY ADVENTIST ECOSYSTEM", font=font_badge, fill=(245, 215, 110, 255))

    # Main Brand Title: HARVION
    title_y = 82
    # Gold 3D Drop Shadow
    draw.text((text_x + 2, title_y + 2), "HARVION", font=font_cinzel_large, fill=(15, 25, 45, 240))
    draw.text((text_x, title_y), "HARVION", font=font_cinzel_large, fill=(255, 240, 185, 255))

    # Sub-tagline
    tag_y = 146
    draw.text((text_x, tag_y), "SPREADING THE EVERLASTING GOSPEL & TRUTH", font=font_cinzel_sub, fill=(212, 175, 55, 220))

    # Divider Line
    draw.line([(text_x, 174), (text_x + 500, 174)], fill=(255, 255, 255, 40), width=1)

    # Feature Bullet Points
    features = [
        ("• 695 SDA Hymnal", "All multi-stanza lyrics with offline piano accompaniment"),
        ("• 50 Spirit of Prophecy Books", "Genuine published pagination matching original EGW volumes"),
        ("• In-App Livestreams", "Live YouTube & TikTok worship broadcasts & missionary chat"),
        ("• KJV Bible & Literature Ministry", "Colporteur bookstore, daily devotionals & study tools"),
    ]

    bullet_y = 192
    for title, desc in features:
        # Title in gold/white
        draw.text((text_x, bullet_y), title, font=font_feature_title, fill=(245, 215, 110, 255))
        # Description
        draw.text((text_x + 18, bullet_y + 24), desc, font=font_feature_sub, fill=(205, 218, 235, 230))
        bullet_y += 56

    # Bottom Developer / Verification Badge
    dev_badge_y = 432
    draw.text((text_x, dev_badge_y), "DEVELOPED BY DELSTARFORDWORKS", font=font_badge, fill=(160, 180, 205, 200))
    draw.text((text_x + 310, dev_badge_y), "•  OFFLINE-FIRST & FREE", font=font_badge, fill=(212, 175, 55, 240))

    # Save target outputs
    dest1 = os.path.join(OUTPUT_DIR, "playstore_feature_graphic_1024x500.png")
    dest2 = os.path.join(ARTIFACT_DIR, "playstore_feature_graphic_1024x500.png")
    canvas.save(dest1, "PNG", optimize=True)
    canvas.save(dest2, "PNG", optimize=True)
    print(f"✓ Feature Graphic saved to {dest1} (Size: {canvas.size})")
    return dest1

if __name__ == "__main__":
    icon_path = generate_app_icon()
    feature_path = generate_feature_graphic()
    print("ALL PLAY STORE GRAPHICS GENERATED SUCCESSFULLY!")
