from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage


ROOT = Path(__file__).resolve().parents[1]
IMAGE_DIR = ROOT / "assets" / "images"


def border_connected_background(rgb: np.ndarray, mode: str) -> np.ndarray:
    height, width, _ = rgb.shape
    rgb16 = rgb.astype(np.int16)
    neutral = rgb16.max(axis=2) - rgb16.min(axis=2)

    if mode == "checkerboard":
        candidate = (rgb16.min(axis=2) > 178) & (neutral < 34)
    else:
        corners = np.concatenate(
            [
                rgb16[:20, :20].reshape(-1, 3),
                rgb16[:20, -20:].reshape(-1, 3),
                rgb16[-20:, :20].reshape(-1, 3),
                rgb16[-20:, -20:].reshape(-1, 3),
            ]
        )
        background_color = np.median(corners, axis=0)
        distance = np.sqrt(((rgb16 - background_color) ** 2).sum(axis=2))
        candidate = (distance < 58) | ((rgb16.min(axis=2) > 225) & (neutral < 30))

    background = np.zeros((height, width), dtype=bool)
    queue: deque[tuple[int, int]] = deque()

    def seed(y: int, x: int) -> None:
        if candidate[y, x] and not background[y, x]:
            background[y, x] = True
            queue.append((y, x))

    for x in range(width):
        seed(0, x)
        seed(height - 1, x)
    for y in range(height):
        seed(y, 0)
        seed(y, width - 1)

    while queue:
        y, x = queue.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < height and 0 <= nx < width:
                if candidate[ny, nx] and not background[ny, nx]:
                    background[ny, nx] = True
                    queue.append((ny, nx))

    return background


def refine_cutout(result: Image.Image, character: str) -> Image.Image:
    pixels = np.asarray(result).copy()
    rgb = pixels[:, :, :3].astype(np.int16)
    alpha = pixels[:, :, 3]
    height, width = alpha.shape
    neutral = rgb.max(axis=2) - rgb.min(axis=2)

    if character == "princess":
        # The character is one connected component while the floor shadow is
        # detached. Keep the character instead of guessing from similar colors.
        labels, count = ndimage.label(alpha > 32)
        if count:
            sizes = ndimage.sum(alpha > 32, labels, range(1, count + 1))
            character_label = int(np.argmax(sizes)) + 1
            alpha[labels != character_label] = 0
        y = np.arange(height)[:, None]
        neutral_floor = (
            (y > height * 0.89)
            & (neutral < 22)
            & (rgb.min(axis=2) > 80)
        )
        alpha[neutral_floor] = 0

    if character == "mickey":
        # Clear every near-white region first (including the unwanted arm gap),
        # then seal and fill only holes inside the head silhouette.
        near_white = (rgb.min(axis=2) > 170) & (neutral < 65)
        alpha[near_white] = 0
        silhouette = alpha > 80
        sealed = ndimage.binary_closing(silhouette, iterations=3)
        filled = ndimage.binary_fill_holes(sealed)
        yy, xx = np.ogrid[:height, :width]
        head_roi = (yy < height * 0.50) & (xx > width * 0.31)
        face_restore = filled & head_roi & near_white
        alpha[face_restore] = 255

        # Restore the two iconic white buttons on the shorts.
        button_mask = Image.new("L", (width, height), 0)
        draw = ImageDraw.Draw(button_mask)
        draw.ellipse(
            (width * 0.57, height * 0.55, width * 0.69, height * 0.67),
            fill=255,
        )
        draw.ellipse(
            (width * 0.72, height * 0.54, width * 0.84, height * 0.66),
            fill=255,
        )
        buttons = np.asarray(button_mask) > 0
        alpha[buttons & near_white] = 255

    if character == "pluto":
        original_alpha = alpha.copy()
        near_white = (rgb.min(axis=2) > 165) & (neutral < 70)
        alpha[near_white] = 0

        yy, xx = np.ogrid[:height, :width]
        dark_ground = (rgb.max(axis=2) < 85) & (yy > height * 0.66)
        alpha[dark_ground] = 0

        # Rebuild thin black paw outlines from a narrow ring around orange fur.
        orange = (
            (rgb[:, :, 0] > 165)
            & (rgb[:, :, 1] > 75)
            & (rgb[:, :, 1] < 195)
            & (rgb[:, :, 2] < 80)
        )
        paw_ring = ndimage.binary_dilation(orange, iterations=3)
        restore_outline = paw_ring & (original_alpha > 80) & (yy > height * 0.64)
        alpha[restore_outline] = original_alpha[restore_outline]

        # Restore enclosed white eyes and collar without bringing back the
        # checkerboard visible between legs and around the body.
        silhouette = alpha > 80
        filled = ndimage.binary_fill_holes(
            ndimage.binary_closing(silhouette, iterations=2)
        )
        detail_roi = (
            ((xx > width * 0.60) & (yy < height * 0.55))
            | (
                (xx > width * 0.47)
                & (xx < width * 0.73)
                & (yy > height * 0.27)
                & (yy < height * 0.65)
            )
        )
        restore_details = filled & detail_roi & near_white
        alpha[restore_details] = 255

        labels, count = ndimage.label(alpha > 32)
        if count:
            sizes = ndimage.sum(alpha > 32, labels, range(1, count + 1))
            character_label = int(np.argmax(sizes)) + 1
            alpha[labels != character_label] = 0

    pixels[:, :, 3] = alpha.astype(np.uint8)
    refined = Image.fromarray(pixels)
    bbox = refined.getbbox()
    if bbox is None:
        return refined
    padding = 10
    return refined.crop(
        (
            max(0, bbox[0] - padding),
            max(0, bbox[1] - padding),
            min(refined.width, bbox[2] + padding),
            min(refined.height, bbox[3] + padding),
        )
    )


def remove_background(
    source_name: str,
    output_name: str,
    mode: str,
    character: str,
) -> None:
    source = IMAGE_DIR / source_name
    output = IMAGE_DIR / output_name
    image = Image.open(source).convert("RGBA")
    rgb = np.asarray(image)[:, :, :3]
    background = border_connected_background(rgb, mode)

    alpha = np.where(background, 0, 255).astype(np.uint8)
    alpha_image = Image.fromarray(alpha).filter(ImageFilter.GaussianBlur(0.65))
    alpha_array = np.asarray(alpha_image).copy()
    alpha_array[alpha_array < 18] = 0
    alpha_array[alpha_array > 238] = 255

    result = image.copy()
    result.putalpha(Image.fromarray(alpha_array))

    bbox = result.getbbox()
    if bbox is not None:
        padding = 10
        left = max(0, bbox[0] - padding)
        top = max(0, bbox[1] - padding)
        right = min(result.width, bbox[2] + padding)
        bottom = min(result.height, bbox[3] + padding)
        result = result.crop((left, top, right, bottom))

    result = refine_cutout(result, character)
    result.save(output, "PNG", optimize=True)
    print(f"{source_name} -> {output_name}: {result.size[0]}x{result.size[1]}")


if __name__ == "__main__":
    remove_background("princess.png", "princess_cutout.png", "white", "princess")
    remove_background("mickey.png", "mickey_cutout.png", "white", "mickey")
    remove_background("pluto.png", "pluto_cutout.png", "checkerboard", "pluto")
