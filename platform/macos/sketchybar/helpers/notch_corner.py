#!/usr/bin/env python3
"""Generate the inverted (concave) corner that joins a notch-extension chip to
the screen's top edge, as a retina PNG. Stdlib only.

  python3 helpers/notch_corner.py <square> <radius> <pad_top> <lead> <side> <out.png>

All sizes in points. Drawn for side=right (chip right of the notch, corner at
its top-right), top-left origin:

  width = square + radius, height = pad_top + radius
  y < pad_top: solid black (meant to sit off-screen; lets an odd radius still
               land on whole-point offsets)
  x < square:  solid black (overlaps the chip's background edge)
  x >= square: black, minus a quarter circle centered at (square + radius,
               pad_top + radius), so the edge sweeps from the chip's side out
               along the screen top.

side=left mirrors it horizontally (corner at the chip's top-left).
lead adds that many points of transparency on the image's left edge (images
are placed on whole points; this nudges the shape by half a point).
"""

import struct
import sys
import zlib

SCALE = 2  # retina
SS = 4  # supersampling per pixel axis, for antialiasing


def coverage(px, py, square, radius, pad):
    inside = 0
    for sy in range(SS):
        for sx in range(SS):
            x = (px + (sx + 0.5) / SS) / SCALE
            y = (py + (sy + 0.5) / SS) / SCALE - pad
            if x < square or y < 0:
                inside += 1
                continue
            dx, dy = x - (square + radius), y - radius
            if dx * dx + dy * dy >= radius * radius:
                inside += 1
    return inside / (SS * SS)


def png(width, height, rows):
    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    raw = b"".join(b"\x00" + row for row in rows)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def main():
    square, radius, pad, lead = (float(a) for a in sys.argv[1:5])
    side, out = sys.argv[5], sys.argv[6]
    w, h = round((square + radius) * SCALE), round((pad + radius) * SCALE)
    rows = []
    for py in range(h):
        alphas = [round(255 * coverage(px, py, square, radius, pad)) for px in range(w)]
        if side == "left":
            alphas.reverse()
        alphas = [0] * round(lead * SCALE) + alphas
        rows.append(b"".join(bytes((0, 0, 0, a)) for a in alphas))
    with open(out, "wb") as f:
        f.write(png(w + round(lead * SCALE), h, rows))


if __name__ == "__main__":
    main()
