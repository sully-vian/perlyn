#import "src/lib.typ": noise

// ----------------------------------------
// utils functions
// ----------------------------------------

// normalizes x in [-1,1] to [a,b]
#let normalize(x, a, b) = a + (x + 1) * (b - a) / 2

// rgb functions for which the arguments are in [0,1]
#let rgb-f(r, g, b) = rgb(r * 100%, g * 100%, b * 100%)

// number to color functions
#let gray(p) = rgb-f(p, p, p)
#let lightgray(p) = {
  let p = 1 - p / 4
  return rgb-f(p, p, p)
}
#let red-green(p) = rgb-f(1 - p, p, 0)
#let fire(p) = rgb-f(calc.min(1, 3 * p), calc.max(0, calc.min(1, 3 * p - 1)), calc.max(0, calc.min(1, 3 * p - 2)))
#let jet(p) = rgb-f(
  calc.clamp(1.5 - calc.abs(4 * p - 3), 0, 1),
  calc.clamp(1.5 - calc.abs(4 * p - 2), 0, 1),
  calc.clamp(
    1.5 - calc.abs(4 * p - 1),
    0,
    1,
  ),
)
#let earth(p) = rgb-f(0.4 + 0.6 * p, 0.8 - 0.5 * p, 0.2 * p)
#let pastel(p) = rgb-f(0.5 + 0.5 * p, 0.2 + 0.3 * p, 1.0)
#let inv-heat(p) = rgb-f(1 - 0.5 * p, 1 - 0.8 * p, 1)

#let colorscales = (gray, lightgray, red-green, fire, jet, earth, pastel, inv-heat)


// ----------------------------------------
// Noise matrix generation
// ----------------------------------------

#let (img-w, img-h) = (600, 900)
#let (start-x, end-x, num-x) = (0, 10, 100)
#let (start-y, end-y, num-y) = (0, 10, 100)

#let step-x = (end-x - start-x) / (num-x - 1)
#let step-y = (end-y - start-y) / (num-y - 1)

#let noise-matrix = ()
#for j in range(num-y) {
  let y = start-y + step-y * j
  for i in range(num-x) {
    let x = start-x + step-x * i

    let noise-val = noise(x, y) // compute noise
    noise-matrix.push(noise-val)
  }
}

// ----------------------------------------
// background grid generation
// ----------------------------------------
#let background-grid = grid(
  columns: num-x,
  rows: num-y,
  gutter: 0pt,
  ..noise-matrix.map(noise-val => {
    let norm = normalize(noise-val, 0, 1)
    let color = lightgray(norm)

    // generate cell
    return rect(
      width: img-w / num-x * 1pt,
      height: img-h / num-y * 1pt,
      fill: color,
      stroke: none,
    )
  })
)

