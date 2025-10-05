#import "@preview/suiji:0.4.0": *

= Perlin Noise

#let seed = 42
#let rng = gen-rng-f(seed)

// gradient grid size
#let (w, h) = (10, 10)

#let (_, angles) = integers-f(rng, endpoint: true, low: 0, high: 360, size: w * h)

#let vectors = (
  angles
    .map(angle => {
      let x = calc.cos(angle * 1deg)
      let y = calc.sin(angle * 1deg)
      return (x, y)
    })
    .chunks(h)
)

#let get-cell(p) = p.map(calc.floor)

#let get-grads(p) = {
  let (i, j) = get-cell(p)
  let tl = vectors.at(j).at(i)
  let tr = vectors.at(j).at(i + 1)
  let bl = vectors.at(j + 1).at(i)
  let br = vectors.at(j + 1).at(i + 1)
  return ((tl, tr), (bl, br))
}

// returns the 4 vector offsets
// (one for each corner)
#let offsets((x, y)) = {
  let xf = calc.fract(x)
  let yf = calc.fract(y)
  return (
    ((xf, yf), (xf - 1, yf)),
    ((xf, yf - 1), (xf - 1, yf - 1)),
  )
}

#let dot((vx, vy), (ux, uy)) = vx * ux + vy * uy

// linear interpolation
#let lerp(start, stop, amt) = (1 - amt) * start + amt * stop

#let fade(t) = t * t * t * (t * (t * 6 - 15) + 10)

#let influences((x, y)) = {
  let offsets = offsets((x, y))
  let grads = get-grads((x, y))
  let inf-tl = dot(offsets.at(0).at(0), grads.at(0).at(0))
  let inf-tr = dot(offsets.at(0).at(1), grads.at(0).at(1))
  let inf-bl = dot(offsets.at(1).at(0), grads.at(1).at(0))
  let inf-br = dot(offsets.at(1).at(1), grads.at(1).at(1))

  let inf-top = lerp(inf-tl, inf-tr, fade(calc.fract(x)))
  let inf-bot = lerp(inf-bl, inf-br, fade(calc.fract(x)))
  let inf-tot = lerp(inf-top, inf-bot, fade(calc.fract(y)))
  return inf-tot
}


#let n = 100

#let matrix = range(n).map(i => range(n).map(j => {
  influences(((h - 1) * i / n, (w - 1) * j / n))
}))

#let val-min = calc.min(..matrix.map(a => calc.min(..a)))
#let val-max = calc.max(..matrix.map(a => calc.max(..a)))

#val-min
#val-max

// reduce to values between 0 and 1
#let matrix = matrix.map(line => line.map(val => (val - val-min) / (val-max - val-min)))

#calc.min(..matrix.map(a => calc.min(..a)))\
#calc.max(..matrix.map(a => calc.max(..a)))

#let data = matrix.flatten()

#let (img-w, img-h) = (500, 500)

#let cell(v) = rect(
  width: img-w / n * 1pt,
  height: img-h / n * 1pt,
  fill: rgb(v * 100%, v * 100%, v * 100%),
  stroke: none,
)
#grid(
  columns: n,
  rows: n,
  gutter: 0pt,
  ..data.map(cell)
)
