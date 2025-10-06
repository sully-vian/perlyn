#import "src/lib.typ": noise

#let (img-w, img-h) = (600, 900)
#let (start-x, end-x, num-x) = (0, 10, 100)
#let (start-y, end-y, num-y) = (0, 10, 100)

#let step-x = (end-x - start-x) / (num-x - 1)
#let step-y = (end-y - start-y) / (num-y - 1)
#let matrix = ()

#for j in range(num-y) {
  let y = start-y + step-y * j
  for i in range(num-x) {
    let x = start-x + step-x * i

    let noise-val = noise(x, y) // compute noise
    let norm = (noise-val + 1) * 0.25 // normalization to [0,1]
    let p = (1 - norm) * 100% // convert to percentages
    let color = rgb(p, p, p) // grayscale

    // generate cell
    let cell = rect(
      width: img-w / num-x * 1pt,
      height: img-h / num-y * 1pt,
      fill: color,
      stroke: none,
    )
    matrix.push(cell)
  }
}

#let background-grid = grid(
  columns: num-x,
  rows: num-y,
  gutter: 0pt,
  ..matrix
)

#page(background: background-grid, [
  = Perlin Noise

  #lorem(34)
])
