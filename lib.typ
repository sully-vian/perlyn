// Standard permutation table from Perlin noise reference implementation
#let perm = (
  151,
  160,
  137,
  91,
  90,
  15,
  131,
  13,
  201,
  95,
  96,
  53,
  194,
  233,
  7,
  225,
  140,
  36,
  103,
  30,
  69,
  142,
  8,
  99,
  37,
  240,
  21,
  10,
  23,
  190,
  6,
  148,
  247,
  120,
  234,
  75,
  0,
  26,
  197,
  62,
  94,
  252,
  219,
  203,
  117,
  35,
  11,
  32,
  57,
  177,
  33,
  88,
  237,
  149,
  56,
  87,
  174,
  20,
  125,
  136,
  171,
  168,
  68,
  175,
  74,
  165,
  71,
  134,
  139,
  48,
  27,
  166,
  77,
  146,
  158,
  231,
  83,
  111,
  229,
  122,
  60,
  211,
  133,
  230,
  220,
  105,
  92,
  41,
  55,
  46,
  245,
  40,
  244,
  102,
  143,
  54,
  65,
  25,
  63,
  161,
  1,
  216,
  80,
  73,
  209,
  76,
  132,
  187,
  208,
  89,
  18,
  169,
  200,
  196,
  135,
  130,
  116,
  188,
  159,
  86,
  164,
  100,
  109,
  198,
  173,
  186,
  3,
  64,
  52,
  217,
  226,
  250,
  124,
  123,
  5,
  202,
  38,
  147,
  118,
  126,
  255,
  82,
  85,
  212,
  207,
  206,
  59,
  227,
  47,
  16,
  58,
  17,
  182,
  189,
  28,
  42,
  223,
  183,
  170,
  213,
  119,
  248,
  152,
  2,
  44,
  154,
  163,
  70,
  221,
  153,
  101,
  155,
  167,
  43,
  172,
  9,
  129,
  22,
  39,
  253,
  19,
  98,
  108,
  110,
  79,
  113,
  224,
  232,
  178,
  185,
  112,
  104,
  218,
  246,
  97,
  228,
  251,
  34,
  242,
  193,
  238,
  210,
  144,
  12,
  191,
  179,
  162,
  241,
  81,
  51,
  145,
  235,
  249,
  14,
  239,
  107,
  49,
  192,
  214,
  31,
  181,
  199,
  106,
  157,
  184,
  84,
  204,
  176,
  115,
  121,
  50,
  45,
  127,
  4,
  150,
  254,
  138,
  236,
  205,
  93,
  222,
  114,
  67,
  29,
  24,
  72,
  243,
  141,
  128,
  195,
  78,
  66,
  215,
  61,
  156,
  180,
)

#let two-pi = 2 * calc.pi

// i and j are the coordinates of the vector's origin (in the old vector array system)
// hash(i,j) = perm[perm[i] + j]
#let get-hash(i, j) = perm.at(calc.rem(i + perm.at(calc.rem(j, 256)), 256))
#let get-angle(i, j) = get-hash(i, j) / 256 * two-pi

// return the angles of the cell's 4 gradients
#let get-angles(p) = {
  let (i, j) = p.map(calc.floor) // find cell coords
  let tl = get-angle(j, i)
  let tr = get-angle(j, i + 1)
  let bl = get-angle(j + 1, i)
  let br = get-angle(j + 1, i + 1)
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
  let offsets = offsets((x, y))
  let angles = get-angles((x, y))
  let inf-tl = dot(offsets.at(0).at(0), angles.at(0).at(0))
  let inf-tr = dot(offsets.at(0).at(1), angles.at(0).at(1))
  let inf-bl = dot(offsets.at(1).at(0), angles.at(1).at(0))
  let inf-br = dot(offsets.at(1).at(1), angles.at(1).at(1))

  let inf-top = lerp(inf-tl, inf-tr, fade(calc.fract(x)))
  let inf-bot = lerp(inf-bl, inf-br, fade(calc.fract(x)))
  let inf-tot = lerp(inf-top, inf-bot, fade(calc.fract(y)))
  return inf-tot
}

// returns a matrix of 2D vectors, like a 2D numpy linspace.
#let make-matrix((start-x, end-x, num-x), (start-y, end-y, num-y)) = {
  let mat = ()
  let step-x = (end-x - start-x) / (num-x - 1)
  let step-y = (end-y - start-y) / (num-y - 1)
  for j in range(num-y) {
    let line = ()
    let y = start-y + step-y * j
    for i in range(num-x) {
      let x = start-x + step-x * i
      line.push((x, y))
    }
    mat.push(line)
  }
  return mat
}

#let (img-w, img-h) = (500, 500)

#let range-x = (0, 10, 100)
#let range-y = (0, 10, 100)
#let matrix = make-matrix(range-x, range-y)

#let matrix = matrix.map(line => line.map(point => noise(..point)))

// turn the [-1,1] noise into grayscale
#let helper(noise) = {
  let norm = (noise + 1) / 2 // normalization to [0,1]
  let p = norm * 100% // conversion
  return rgb(p, p, p) // return grayscale
}

#let color-matrix = matrix.map(line => line.map(noise => helper(noise)))

#let cell(color) = rect(
  width: img-w / range-x.at(2) * 1pt,
  height: img-h / range-y.at(2) * 1pt,
  fill: color,
  stroke: none,
)
#grid(
  columns: range-x.at(2),
  rows: range-y.at(2),
  gutter: 0pt,
  ..color-matrix.flatten().map(cell)
)
