#import "constants.typ": inv-256, perm, two-pi

// -----------------------------------------------------------------------------
// Private functions
// -----------------------------------------------------------------------------

// i and j are the coordinates of the vector's origin (in the old vector array system)
// hash(i,j) = perm[perm[i] + j]
#let _get-hash(i, j) = perm.at(calc.rem(perm.at(calc.rem(i, 256)) + j, 256))
#let _get-angle(i, j) = _get-hash(i, j) * inv-256 * two-pi

// linear interpolation
#let _lerp(start, stop, amt) = (1 - amt) * start + amt * stop

#let _fade(t) = t * t * t * (t * (t * 6 - 15) + 10)

#let _asserts(x, y) = {
  assert(
    type(x) == int or type(x) == decimal or type(x) == float,
    message: "`x` should either be an int or a decimal or a float",
  )
  assert(
    type(y) == int or type(y) == decimal or type(y) == float,
    message: "`y` should either be an int or a decimal or a float",
  )
}

// -----------------------------------------------------------------------------
// Public function
// -----------------------------------------------------------------------------

/// Generates 2D Perlin noise at the given coordinates.
///
/// Perlin noise is a gradient noise function that produces smooth,
/// natural-looking random values. It's commonly used for procedural generatio
/// of textures, terrain and other organic-looking patterns.
///
/// - x (int, decimal, float): The x-coordinate in noise space
/// - y (int, decimal, float): The y-coordinate in noise space
/// -> float: The noise value at the given coordinates in range [-1,1]
///
/// ```typ
/// #let value = noise(2.5, 1.3) // Retuns a value between -1 and 1
/// ```
#let noise(x, y) = {
  _asserts(x, y)

  // cell coordinates
  let i = calc.floor(x)
  let j = calc.floor(y)
  // fractional part
  let xf = x - i
  let yf = y - j

  // get angles of 4 corner gradients
  let angle-tl = _get-angle(j, i) // top-left
  let angle-tr = _get-angle(j, i + 1) // top-right
  let angle-bl = _get-angle(j + 1, i) // bottom-left
  let angle-br = _get-angle(j + 1, i + 1) // bottom-right

  // dot products

  let inf-tl = xf * calc.cos(angle-tl) + yf * calc.sin(angle-tl)
  let inf-tr = (xf - 1) * calc.cos(angle-tr) + yf * calc.sin(angle-tr)
  let inf-bl = xf * calc.cos(angle-bl) + (yf - 1) * calc.sin(angle-bl)
  let inf-br = (xf - 1) * calc.cos(angle-br) + (yf - 1) * calc.sin(angle-br)

  let fade-x = _fade(calc.fract(x))
  let fade-y = _fade(calc.fract(y))

  let top = _lerp(inf-tl, inf-tr, fade-x)
  let bot = _lerp(inf-bl, inf-br, fade-x)
  return _lerp(top, bot, fade-y)
}

