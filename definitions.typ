#import "@preview/cetz:0.4.0": *
#import "@preview/cetz-plot:0.1.2": plot
#import "colors.typ": *

// Spacing
#let thinhalf = h(math.thin.amount * 0.5, weak: false)
#let thin = h(math.thin.amount, weak: false)
#let thin2 = h(math.thin.amount * 2, weak: false)

// Symbols
#let cm = sym.checkmark


// Font sizes
#let font-size-xs = 12pt
#let font-size-s = 16pt
#let font-size-m = 20pt
#let font-size-l = 24pt
#let font-size-xl = 28pt
#let font-size-xxl = 32pt
#let font-size-xxxl = 34pt

// General math stuff
#let mb(x) = {$bold(upright(#x))$}  // math bold
#let Ab = mb("A")
#let ab = mb("a")
#let Bb = mb("B")
// #let bb = mb("b")
#let Cb = mb("C")
#let cb = mb("c")
#let Db = mb("D")
#let db = mb("d")
#let Eb = mb("E")
#let eb = mb("e")
#let Fb = mb("F")
#let fb = mb("f")
#let Gb = mb("G")
#let gb = mb("g")
#let Hb = mb("H")
#let hb = mb("h")
#let Ib = mb("I")
#let ib = mb("i")
#let Jb = mb("J")
#let jb = mb("j")
#let Kb = mb("K")
#let kb = mb("k")
#let Lb = mb("L")
#let lb = mb("l")
#let Mb = mb("M")
// #let mb = mb("m")  // overrides mb(x) (mathbold) -- let's see if we even need this
#let Nb = mb("N")
#let nb = mb("n")
#let Ob = mb("O")
#let ob = mb("o")
#let Pb = mb("P")
#let pb = mb("p")
#let Qb = mb("Q")
#let qb = mb("q")
#let Rb = mb("R")
#let rb = mb("r")
#let Sb = mb("S")
#let sb = mb("s")
#let Tb = mb("T")
#let tb = mb("t")
#let Ub = mb("U")
#let ub = mb("u")
#let Vb = mb("V")
#let vb = mb("v")
#let Wb = mb("W")
#let wb = mb("w")
#let Xb = mb("X")
#let xb = mb("x")
#let Yb = mb("Y")
#let yb = mb("y")
#let Zb = mb("Z")
#let zb = mb("z")


// Random variable stuff
#let val(x) = {$mb("val")\(#x\)$}
#let Var = math.op("Var") // Variance
#let Cov = math.op("Cov") // Covariance
#let ind = math.bb($1$) // Indicator

// Argmax/min operator
#let argmin = math.op("argmin", limits: true)
#let argmax = math.op("argmax", limits: true)


// PCs
#let cal(it) = math.class("normal", context {
  show math.equation: set text(font: "Garamond-Math", stylistic-set: 3)

  let scaling = 100% * (1em.to-absolute() / text.size)
  let wrapper = if scaling < 60% { math.sscript }
                else if scaling < 100% { math.script }
                else { it => it }

  box(text(top-edge: "bounds", $wrapper(math.cal(it))$))
})  // Hack to make cal(...) look like \mathcal{...} from LaTeX
#let gC = cal("C")
#let gG = cal("G")
#let sumcolor = deep-green-darker
#let prodcolor = deep-blue-darker
#let inpcolor = deep-orange-darker
#let gaussfn(x) = 1/calc.sqrt(2*calc.pi) * calc.exp(-1 * x * x / 2)
#let gauss = canvas({
    import draw: *
    scale(x: 40%, y: 40%)
    plot.plot(
        axis-style: none,
        size: (0.4, 0.35),
    {
        let domain = (-1.1 * calc.pi, +1.1 * calc.pi)
        plot.add(gaussfn, domain: domain, style: (stroke: 0.5pt + inpcolor))
    })

})

#let mystroke = (thickness: 0.5pt)
#let sc = 15%
#let sumunit = thin + canvas({
    import draw: *
    scale(x: sc, y: sc)
    let name = "sum"
    circle((0, 0), name: name, stroke: mystroke + (paint: sumcolor))

        line(
            (v => vector.add(v, (0, -0.2)), name + ".north"),
            (v => vector.add(v, (0, 0.2)), name + ".south"),
            stroke: mystroke + (paint: sumcolor)
        )

        line(
            (v => vector.add(v, (0.2, 0)), name + ".west"),
            (v => vector.add(v, (-0.2, 0)), name + ".east"),
            stroke: mystroke + (paint: sumcolor)
        )
}) + thin

#let produnit = thin + canvas({
    import draw: *
    scale(x: sc, y: sc)
    let name = "prod"
    circle((0, 0), name: name, stroke: mystroke + (paint: prodcolor))

        line(
            (v => vector.add(v, (-0.15, -0.15)), name + ".north-east"),
            (v => vector.add(v, (0.15, 0.15)), name + ".south-west"),
            stroke: mystroke + (paint: prodcolor)
        )

        line(
            (v => vector.add(v, (0.15, -0.15)), name + ".north-west"),
            (v => vector.add(v, (-0.15, 0.15)), name + ".south-east"),
            stroke: mystroke + (paint: prodcolor)
        )
    }) + thin

#let inpunit = thin + canvas({
    import draw: *
    scale(x: sc, y: sc)
    let name = "inp"
    circle((0, 0), name: name, stroke: mystroke + (paint: inpcolor))
    content((name + ".center"), gauss, anchor: "center")

}) + thin
