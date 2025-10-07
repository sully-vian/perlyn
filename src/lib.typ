#import "constants.typ": inv-256, perm, two-pi

// i and j are the coordinates of the vector's origin (in the old vector array system)
// hash(i,j) = perm[perm[i] + j]
#let get-hash(i, j) = perm.at(calc.rem(perm.at(calc.rem(i, 256)) + j, 256))
#let get-angle(i, j) = get-hash(i, j) * inv-256 * two-pi

// linear interpolation
#let lerp(start, stop, amt) = (1 - amt) * start + amt * stop

#let fade(t) = t * t * t * (t * (t * 6 - 15) + 10)

#let noise(x, y) = {
  // cell coordinates
  let i = calc.floor(x)
  let j = calc.floor(y)
  // fractional part
  let xf = x - i
  let yf = y - j

  // get angles of 4 corner gradients
  let angle-tl = get-angle(j, i) // top-left
  let angle-tr = get-angle(j, i + 1) // top-right
  let angle-bl = get-angle(j + 1, i) // bottom-left
  let angle-br = get-angle(j + 1, i + 1) // bottom-right

  // dot products

  let inf-tl = xf * calc.cos(angle-tl) + yf * calc.sin(angle-tl)
  let inf-tr = (xf - 1) * calc.cos(angle-tr) + yf * calc.sin(angle-tr)
  let inf-bl = xf * calc.cos(angle-bl) + (yf - 1) * calc.sin(angle-bl)
  let inf-br = (xf - 1) * calc.cos(angle-br) + (yf - 1) * calc.sin(angle-br)

  let fade-x = fade(calc.fract(x))
  let fade-y = fade(calc.fract(y))

  let top = lerp(inf-tl, inf-tr, fade-x)
  let bot = lerp(inf-bl, inf-br, fade-x)
  return lerp(top, bot, fade-y)
}

