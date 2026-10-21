import os
import math
from PIL import Image, ImageDraw, ImageFilter

def create_lingoread_icon(size=512):
    scale = 4
    canvas_size = size * scale
    
    # 1. Background: Deep luxury midnight navy gradient squircle
    bg_gradient = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg_gradient)
    
    radius = int(canvas_size * 0.22)
    margin = int(canvas_size * 0.035)
    
    for y in range(canvas_size):
        t = y / canvas_size
        r = int(12 + t * 18)
        g = int(18 + t * 20)
        b = int(38 + t * 45)
        bg_draw.line([(0, y), (canvas_size, y)], fill=(r, g, b, 255))

    mask = Image.new("L", (canvas_size, canvas_size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [(margin, margin), (canvas_size - margin, canvas_size - margin)],
        radius=radius,
        fill=255
    )

    icon_base = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    icon_base.paste(bg_gradient, (0, 0), mask)

    # Subtle golden rim
    border_draw = ImageDraw.Draw(icon_base)
    border_draw.rounded_rectangle(
        [(margin, margin), (canvas_size - margin, canvas_size - margin)],
        radius=radius,
        outline=(245, 158, 11, 75),
        width=int(4 * scale)
    )

    # 2. Book & Emblem
    emblem_layer = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    emblem_draw = ImageDraw.Draw(emblem_layer)

    cx = canvas_size // 2
    cy = int(canvas_size * 0.54)

    book_w = int(canvas_size * 0.35)
    book_h = int(canvas_size * 0.26)
    bottom_y = cy + int(book_h * 0.55)
    top_spine_y = cy - int(book_h * 0.45)

    lp_top_left = (cx - book_w, top_spine_y - int(book_h * 0.15))
    lp_top_spine = (cx - int(scale * 3), top_spine_y + int(book_h * 0.12))
    lp_bot_spine = (cx - int(scale * 3), bottom_y)
    lp_bot_left = (cx - book_w, bottom_y - int(book_h * 0.15))

    rp_top_right = (cx + book_w, top_spine_y - int(book_h * 0.15))
    rp_top_spine = (cx + int(scale * 3), top_spine_y + int(book_h * 0.12))
    rp_bot_spine = (cx + int(scale * 3), bottom_y)
    rp_bot_right = (cx + book_w, bottom_y - int(book_h * 0.15))

    # Shadow
    shadow_layer = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_offset = int(scale * 12)
    shadow_draw.polygon([
        (lp_bot_left[0], lp_bot_left[1] + shadow_offset),
        (lp_bot_spine[0], lp_bot_spine[1] + shadow_offset),
        (rp_bot_spine[0], rp_bot_spine[1] + shadow_offset),
        (rp_bot_right[0], rp_bot_right[1] + shadow_offset),
    ], fill=(0, 0, 0, 150))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(int(scale * 14)))
    icon_base.paste(shadow_layer, (0, 0), shadow_layer)

    # Leather Cover Edges (warm amber/brown)
    cover_offset = int(scale * 6)
    emblem_draw.polygon([
        (lp_top_left[0] - cover_offset, lp_top_left[1] + cover_offset),
        (cx, top_spine_y + int(book_h * 0.15) + cover_offset),
        (cx, bottom_y + cover_offset * 2),
        (lp_bot_left[0] - cover_offset, lp_bot_left[1] + cover_offset * 2),
    ], fill=(180, 110, 15, 230))
    emblem_draw.polygon([
        (rp_top_right[0] + cover_offset, rp_top_right[1] + cover_offset),
        (cx, top_spine_y + int(book_h * 0.15) + cover_offset),
        (cx, bottom_y + cover_offset * 2),
        (rp_bot_right[0] + cover_offset, rp_bot_right[1] + cover_offset * 2),
    ], fill=(180, 110, 15, 230))

    # Pages (clean ivory / parchment)
    emblem_draw.polygon([lp_top_left, lp_top_spine, lp_bot_spine, lp_bot_left], fill=(248, 250, 252, 255))
    emblem_draw.polygon([rp_top_spine, rp_top_right, rp_bot_right, rp_bot_spine], fill=(236, 242, 248, 255))

    # Center spine crease
    emblem_draw.polygon([
        (cx - int(scale * 5), top_spine_y + int(book_h * 0.09)),
        (cx + int(scale * 5), top_spine_y + int(book_h * 0.09)),
        (cx + int(scale * 5), bottom_y),
        (cx - int(scale * 5), bottom_y),
    ], fill=(203, 213, 225, 255))

    # Minimalist editorial text lines on pages
    line_color = (148, 163, 184, 175)
    line_w = int(book_w * 0.68)
    line_thickness = int(scale * 2.8)

    for i in range(4):
        frac = 0.35 + i * 0.16
        y_left = int(lp_top_left[1] + (lp_bot_left[1] - lp_top_left[1]) * frac)
        x_left_start = lp_top_left[0] + int(book_w * 0.16)
        x_left_end = x_left_start + line_w if i < 3 else x_left_start + int(line_w * 0.6)
        emblem_draw.line([(x_left_start, y_left), (x_left_end, y_left)], fill=line_color, width=line_thickness)

        y_right = int(rp_top_right[1] + (rp_bot_right[1] - rp_top_right[1]) * frac)
        x_right_end = rp_top_right[0] - int(book_w * 0.16)
        x_right_start = x_right_end - line_w if i < 3 else x_right_end - int(line_w * 0.5)
        emblem_draw.line([(x_right_start, y_right), (x_right_end, y_right)], fill=line_color, width=line_thickness)

    # 3. Golden Bookmark Ribbon
    ribbon_w = int(scale * 16)
    ribbon_top_y = top_spine_y + int(book_h * 0.10)
    ribbon_bot_y = bottom_y + int(book_h * 0.28)
    ribbon_poly = [
        (cx - ribbon_w, ribbon_top_y),
        (cx + ribbon_w, ribbon_top_y),
        (cx + ribbon_w, ribbon_bot_y),
        (cx, ribbon_bot_y - int(scale * 12)),
        (cx - ribbon_w, ribbon_bot_y),
    ]
    emblem_draw.polygon(ribbon_poly, fill=(245, 158, 11, 255))
    emblem_draw.line([(cx - int(ribbon_w * 0.45), ribbon_top_y), (cx - int(ribbon_w * 0.45), ribbon_bot_y - int(scale * 6))], fill=(253, 230, 138, 200), width=int(scale * 3))

    # 4. Golden Reading Sparkles
    star_cx = cx
    star_cy = top_spine_y - int(book_h * 0.42)
    star_r_outer = int(scale * 32)
    star_r_inner = int(scale * 8)

    star_points = []
    for i in range(8):
        ang = i * math.pi / 4 - math.pi / 2
        r = star_r_outer if (i % 2 == 0) else star_r_inner
        star_points.append((star_cx + r * math.cos(ang), star_cy + r * math.sin(ang)))

    emblem_draw.polygon(star_points, fill=(251, 191, 36, 255))

    def draw_tiny_star(sx, sy, sr):
        pts = []
        for i in range(8):
            ang = i * math.pi / 4 - math.pi / 2
            r = sr if (i % 2 == 0) else sr * 0.3
            pts.append((sx + r * math.cos(ang), sy + r * math.sin(ang)))
        emblem_draw.polygon(pts, fill=(251, 191, 36, 210))

    draw_tiny_star(star_cx - int(scale * 54), star_cy + int(scale * 12), int(scale * 12))
    draw_tiny_star(star_cx + int(scale * 54), star_cy + int(scale * 12), int(scale * 12))

    icon_base.paste(emblem_layer, (0, 0), emblem_layer)
    final_icon = icon_base.resize((size, size), Image.Resampling.LANCZOS)
    return final_icon

def export_all():
    targets = [
        ('android/app/src/main/res/mipmap-mdpi/ic_launcher.png', 48),
        ('android/app/src/main/res/mipmap-hdpi/ic_launcher.png', 72),
        ('android/app/src/main/res/mipmap-xhdpi/ic_launcher.png', 96),
        ('android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png', 144),
        ('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png', 192),
        ('web/icons/Icon-192.png', 192),
        ('web/icons/Icon-512.png', 512),
        ('web/icons/Icon-maskable-192.png', 192),
        ('web/icons/Icon-maskable-512.png', 512),
        ('web/favicon.png', 64),
    ]

    for path, sz in targets:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        img = create_lingoread_icon(sz)
        img.save(path, 'PNG')
        print(f'Saved {path} ({sz}x{sz})')

    # Also save high-res 512x512
    os.makedirs('assets/images', exist_ok=True)
    img512 = create_lingoread_icon(512)
    img512.save('assets/images/app_logo.png', 'PNG')
    print('Saved assets/images/app_logo.png (512x512)')

if __name__ == '__main__':
    export_all()
