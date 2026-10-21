import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

def create_lingoread_icon(size=512):
    # Render at 4x resolution for pristine anti-aliasing
    scale = 4
    canvas_size = size * scale
    img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background: Rich midnight blue / deep indigo squircle
    bg_gradient = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg_gradient)
    
    # Draw rounded rectangle (squircle style)
    # Corner radius approx 22% of size
    radius = int(canvas_size * 0.22)
    margin = int(canvas_size * 0.04)
    
    # Gradient background
    for y in range(canvas_size):
        t = y / canvas_size
        # Deep luxury palette: Deep navy #0A0E1A to Royal Indigo #1E1B4B to Midnight Teal #06283D
        r = int(10 + t * 20)
        g = int(14 + t * 22)
        b = int(32 + t * 50)
        bg_draw.line([(0, y), (canvas_size, y)], fill=(r, g, b, 255))

    # Mask with smooth rounded rectangle
    mask = Image.new("L", (canvas_size, canvas_size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [(margin, margin), (canvas_size - margin, canvas_size - margin)],
        radius=radius,
        fill=255
    )

    # Apply mask
    icon_base = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    icon_base.paste(bg_gradient, (0, 0), mask)

    # Draw subtle golden border
    border_draw = ImageDraw.Draw(icon_base)
    border_draw.rounded_rectangle(
        [(margin, margin), (canvas_size - margin, canvas_size - margin)],
        radius=radius,
        outline=(245, 158, 11, 70), # amber accent
        width=int(4 * scale)
    )

    # 2. Draw Book & Reading Emblem
    emblem_layer = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    emblem_draw = ImageDraw.Draw(emblem_layer)

    cx = canvas_size // 2
    cy = int(canvas_size * 0.54) # center slightly lower to balance top star

    # Book dimensions
    book_w = int(canvas_size * 0.35)
    book_h = int(canvas_size * 0.26)
    spine_x = cx
    bottom_y = cy + int(book_h * 0.55)
    top_spine_y = cy - int(book_h * 0.45)

    # Left Page (polygon with gentle curve)
    # Right Page (polygon with gentle curve)
    # Left page polygon:
    # Top left, top spine, bottom spine, bottom left
    lp_top_left = (cx - book_w, top_spine_y - int(book_h * 0.15))
    lp_top_spine = (cx - int(scale * 3), top_spine_y + int(book_h * 0.12))
    lp_bot_spine = (cx - int(scale * 3), bottom_y)
    lp_bot_left = (cx - book_w, bottom_y - int(book_h * 0.15))

    rp_top_right = (cx + book_w, top_spine_y - int(book_h * 0.15))
    rp_top_spine = (cx + int(scale * 3), top_spine_y + int(book_h * 0.12))
    rp_bot_spine = (cx + int(scale * 3), bottom_y)
    rp_bot_right = (cx + book_w, bottom_y - int(book_h * 0.15))

    # Shadow under book
    shadow_layer = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_offset = int(scale * 12)
    shadow_draw.polygon([
        (lp_bot_left[0], lp_bot_left[1] + shadow_offset),
        (lp_bot_spine[0], lp_bot_spine[1] + shadow_offset),
        (rp_bot_spine[0], rp_bot_spine[1] + shadow_offset),
        (rp_bot_right[0], rp_bot_right[1] + shadow_offset),
    ], fill=(0, 0, 0, 140))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(int(scale * 14)))
    icon_base.paste(shadow_layer, (0, 0), shadow_layer)

    # Back cover edge (warm amber gold)
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

    # Pages (Clean, bright ivory white with parchment tone)
    emblem_draw.polygon([lp_top_left, lp_top_spine, lp_bot_spine, lp_bot_left], fill=(248, 250, 252, 255))
    emblem_draw.polygon([rp_top_spine, rp_top_right, rp_bot_right, rp_bot_spine], fill=(235, 240, 245, 255))

    # Spine shadow in center
    emblem_draw.polygon([
        (cx - int(scale * 6), top_spine_y + int(book_h * 0.08)),
        (cx + int(scale * 6), top_spine_y + int(book_h * 0.08)),
        (cx + int(scale * 6), bottom_y),
        (cx - int(scale * 6), bottom_y),
    ], fill=(200, 210, 225, 255))

    # Elegant horizontal text lines on pages (minimalist editorial feel)
    line_color_left = (148, 163, 184, 180) # slate 400
    line_color_right = (148, 163, 184, 180)
    line_w = int(book_w * 0.68)
    line_thickness = int(scale * 2.8)

    for i in range(4):
        frac = 0.35 + i * 0.16
        # Left page lines
        y_left = int(lp_top_left[1] + (lp_bot_left[1] - lp_top_left[1]) * frac)
        x_left_start = lp_top_left[0] + int(book_w * 0.16)
        x_left_end = x_left_start + line_w if i < 3 else x_left_start + int(line_w * 0.6)
        emblem_draw.line([(x_left_start, y_left), (x_left_end, y_left)], fill=line_color_left, width=line_thickness)

        # Right page lines
        y_right = int(rp_top_right[1] + (rp_bot_right[1] - rp_top_right[1]) * frac)
        x_right_end = rp_top_right[0] - int(book_w * 0.16)
        x_right_start = x_right_end - line_w if i < 3 else x_right_end - int(line_w * 0.5)
        emblem_draw.line([(x_right_start, y_right), (x_right_end, y_right)], fill=line_color_right, width=line_thickness)

    # 3. Radiant Golden Bookmark Ribbon hanging from center down
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
    emblem_draw.polygon(ribbon_poly, fill=(245, 158, 11, 255)) # rich amber #F59E0B
    # Ribbon highlight
    emblem_draw.line([(cx - int(ribbon_w * 0.5), ribbon_top_y), (cx - int(ribbon_w * 0.5), ribbon_bot_y - int(scale * 6))], fill=(253, 230, 138, 200), width=int(scale * 3))

    # 4. Golden Reading Sparkle / Star of Knowledge above the book
    star_cx = cx
    star_cy = top_spine_y - int(book_h * 0.42)
    star_r_outer = int(scale * 32)
    star_r_inner = int(scale * 8)

    star_points = []
    for i in range(8):
        ang = i * math.pi / 4 - math.pi / 2
        r = star_r_outer if (i % 2 == 0) else star_r_inner
        star_points.append((star_cx + r * math.cos(ang), star_cy + r * math.sin(ang)))

    emblem_draw.polygon(star_points, fill=(251, 191, 36, 255)) # amber gold #FBBF24

    # Tiny side sparkles for balance
    def draw_tiny_star(sx, sy, sr):
        pts = []
        for i in range(8):
            ang = i * math.pi / 4 - math.pi / 2
            r = sr if (i % 2 == 0) else sr * 0.3
            pts.append((sx + r * math.cos(ang), sy + r * math.sin(ang)))
        emblem_draw.polygon(pts, fill=(251, 191, 36, 210))

    draw_tiny_star(star_cx - int(scale * 54), star_cy + int(scale * 12), int(scale * 12))
    draw_tiny_star(star_cx + int(scale * 54), star_cy + int(scale * 12), int(scale * 12))

    # Merge layers
    icon_base.paste(emblem_layer, (0, 0), emblem_layer)

    # Downsample to target size with high-quality Lanczos resampling
    final_icon = icon_base.resize((size, size), Image.Resampling.LANCZOS)
    return final_icon

if __name__ == '__main__':
    icon = create_lingoread_icon(512)
    icon.save('bin/test_icon.png')
    print('Generated test_icon.png (512x512) successfully.')
