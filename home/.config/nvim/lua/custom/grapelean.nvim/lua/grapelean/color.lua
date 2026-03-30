local M = {}

local function hex_to_rgb(hex)
  hex = hex:gsub('#', '')
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format('#%02X%02X%02X', r, g, b)
end

local function rgb_to_hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l
  l = (max + min) / 2
  if max == min then
    h, s = 0, 0
  else
    local d = max - min
    s = l > 0.5 and d / (2 - max - min) or d / (max + min)
    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h * 360, s, l
end

local function hsl_to_rgb(h, s, l)
  h = h / 360
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local function hue2rgb(p, q, t)
      if t < 0 then t = t + 1 end
      if t > 1 then t = t - 1 end
      if t < 1 / 6 then return p + (q - p) * 6 * t end
      if t < 1 / 2 then return q end
      if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
      return p
    end
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  end
  return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
end

function M.blend(fg, bg, alpha)
  local r1, g1, b1 = hex_to_rgb(fg)
  local r2, g2, b2 = hex_to_rgb(bg)
  local r = math.floor(alpha * r1 + (1 - alpha) * r2)
  local g = math.floor(alpha * g1 + (1 - alpha) * g2)
  local b = math.floor(alpha * b1 + (1 - alpha) * b2)
  return rgb_to_hex(r, g, b)
end

function M.lighten(hex, amount)
  amount = amount or 0.1
  local r, g, b = hex_to_rgb(hex)
  local h, s, l = rgb_to_hsl(r, g, b)
  l = math.min(1, l + amount)
  r, g, b = hsl_to_rgb(h, s, l)
  return rgb_to_hex(r, g, b)
end

function M.darken(hex, amount)
  amount = amount or 0.1
  local r, g, b = hex_to_rgb(hex)
  local h, s, l = rgb_to_hsl(r, g, b)
  l = math.max(0, l - amount)
  r, g, b = hsl_to_rgb(h, s, l)
  return rgb_to_hex(r, g, b)
end

return M
