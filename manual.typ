#import "src/lib.typ": noise
#import "helper.typ": background-grid

#set document(
  title: [Perlyn User's Manual],
  author: "sully-vian",
  date: none,
)

#set page(background: background-grid)

#place(top + left, dx: -1in, dy: -1in, box(
  width: 100%,
  height: 40pt,
  {
    set align(horizon)
    h(2em)
    text(size: 24pt, font: "Buenard", fill: rgb("#239dad"))[*typst*]
    h(0.5em)
    text(size: 18pt, font: "Hanken Grotesk", fill: luma(30%))[Package]
  },
))

= Perlin User's Manual

== Basic Usage

The core function is `noise(x,y)` which generates Perlin noise values:

```typ
#import "@preview/perlyn:0.1.0": noise

#let value = noise(2.5, 1.3) // Returns value in [-1, 1]
```

== Visualization Examples

=== Basic grayscale Grid



