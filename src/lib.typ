#import "constants.typ": inv-256, perm, two-pi

// i and j are the coordinates of the vector's origin (in the old vector array system)
// hash(i,j) = perm[perm[i] + j]
#let get-hash(i, j) = perm.at(calc.rem(perm.at(calc.rem(i, 256)) + j, 256))
#let get-angle(i, j) = get-hash(i, j) * inv-256 * two-pi

// return the angles of the cell's 4 gradients
#let get-angles(x, y) = {
  let i = calc.floor(x) // find cell coords
  let j = calc.floor(y) // find cell coords
  let tl = get-angle(j, i)
  let tr = get-angle(j, i + 1)
  let bl = get-angle(j + 1, i)
  let br = get-angle(j + 1, i + 1)
  return ((tl, tr), (bl, br))
}

// returns the 4 vector offsets
// (one for each corner)
#let offsets(x, y) = {
  let xf = calc.fract(x)
  let yf = calc.fract(y)
  return (
    ((xf, yf), (xf - 1, yf)),
    ((xf, yf - 1), (xf - 1, yf - 1)),
  )
}

// (vx, vy): the ofset vector coordinates
// (i,j): the gradients origin coordinates
// Returns: the dot product between the offset vector and the gradient at the given position
#let dot((vx, vy), angle) = {
  let grad-x = calc.cos(angle)
  let grad-y = calc.sin(angle)
  return (vx * grad-x) + (vy * grad-y)
}

// linear interpolation
#let lerp(start, stop, amt) = (1 - amt) * start + amt * stop

#let fade(t) = t * t * t * (t * (t * 6 - 15) + 10)

#let noise(x, y) = {
  let offsets = offsets(x, y)
  let angles = get-angles(x, y)
  let inf-tl = dot(offsets.at(0).at(0), angles.at(0).at(0))
  let inf-tr = dot(offsets.at(0).at(1), angles.at(0).at(1))
  let inf-bl = dot(offsets.at(1).at(0), angles.at(1).at(0))
  let inf-br = dot(offsets.at(1).at(1), angles.at(1).at(1))

  let fade-x = fade(calc.fract(x))
  let fade-y = fade(calc.fract(y))

  let top = lerp(inf-tl, inf-tr, fade-x)
  let bot = lerp(inf-bl, inf-br, fade-x)
  return lerp(top, bot, fade-y)
}

