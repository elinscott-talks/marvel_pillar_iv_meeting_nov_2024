#import "@preview/touying:0.4.2": *
#import "@preview/pinit:0.1.4": *
#import "@preview/xarrow:0.3.0": xarrow
#import "psi-slides.typ"

// color-scheme can be navy-red, blue-green, or pink-yellow
#let s = psi-slides.register(aspect-ratio: "16-9", color-scheme: "pink-yellow")

#let s = (s.methods.info)(
  self: s,
  title: [Koopmans spectral functionals],
  subtitle: [Electronic screening via machine learning],
  author: [Edward Linscott],
  date: datetime(year: 2024, month: 11, day: 14),
  location: [MARVEL Pillar IV Meeting],
  references: [references.bib],
)
#let blcite(reference) = {
  text(fill: white, cite(reference))
}

#set footnote.entry(clearance: 0em)
#show bibliography: set text(0.6em)


#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide, matrix-slide) = utils.slides(s)
#show: slides

== Electronic screening via machine learning

$
  alpha_i = (angle.l n_i|epsilon^(-1) f_"Hxc"|n_i angle.r) / (angle.l n_i|f_"Hxc"|n_i angle.r)
$

#pause

- must be computed #emph[ab intio] via $Delta$SCF@Nguyen2018@DeGennaro2022a or DFPT@Colonna2018@Colonna2022 #pause
- one screening parameter per (non-equivalent) orbital #pause
- corresponds to the vast majority of the computational cost #pause
- critical that they are accurate; if $psi_i (bold(r)) = sum_j U_(i j) phi_j (bold(r))$ then
  $
    Delta epsilon_(i in"occ") =
    sum_(j) alpha_j U_(i j)U_(j i)^dagger
    (-E_"Hxc" [rho - rho_j]+E_"Hxc" [rho - rho_j + n_j] - integral d bold(r) v_"Hxc" [rho - rho_j + n_j](bold(r))  n_j (bold(r)))
  $


== The machine-learning framework

#slide[
  #align(
    center,
    grid(
      columns: 5,
      align: horizon,
      gutter: 1em,
      image("figures/orbital.emp.00191_cropped.png", height: 30%),
      xarrow("power spectrum decomposition"),
      $vec(delim: "[", x_0, x_1, x_2, dots.v)$,
      xarrow("ridge regression"),
      $alpha_i$,
    ),
  )

  $
    c^i_(n l m, k) & = integral dif bold(r) g_(n l) (r) Y_(l m)(theta,phi) n_i (
      bold(r) - bold(R)_i
    )
  $


  $
    p^i_(n_1 n_2 l,k_1 k_2) = pi sqrt(8 / (2l+1)) sum_m c_(n_1 l m,k_1)^(i *) c_(n_2 l m,k_2)^i
  $

  #blcite(<Schubert2024>)
]

== Two test systems

#slide[
  #align(
    center,
    grid(
      columns: 2,
      align: horizon + center,
      gutter: 1em,
      image("figures/water.png", height: 70%),
      image("figures/CsSnI3_disordered.png", height: 70%),

      "water", "CsSnI" + sub("3"),
    ),
  )
  #blcite(<Schubert2024>)
]

== Use case

#slide[
  #grid(columns: 10, column-gutter: 1em, row-gutter: 1em,
      image("figures/water.png", width: 100%),
      image("figures/water.png", width: 100%),
      image("figures/water.png", width: 100%),
      image("figures/water.png", width: 100%),
      image("figures/water.png", width: 100%),
      image("figures/water.png", width: 100%),
      image("figures/water.png", width: 100%),
      image("figures/water.png", width: 100%),
      image("figures/water.png", width: 100%),
      grid.cell(align: center + horizon, [...]),
      grid.cell(inset: 1em, align: center, fill: s.colors.primary, colspan: 3, text(fill: white, "train")),
      grid.cell(inset: 1em, align: center, fill: s.colors.secondary, colspan: 7, [predict]),
  )

  #pause _or_ train on a small cell and deploy on a larger cell

  #pause N.B. not a general-purpose model -- trained on a case-by-case basis
]

= Results

== Accuracy

#align(center + horizon, image("figures/water.png", height: 100%))

#image("figures/water_cls_calc_vs_pred_and_hist_0.png")

#image("figures/water_cls_calc_vs_pred_and_hist_1.png")

#image("figures/water_cls_calc_vs_pred_and_hist_2.png")

#image("figures/water_cls_calc_vs_pred_and_hist_3.png")

#image("figures/water_cls_calc_vs_pred_and_hist_4.png")

#image("figures/water_cls_calc_vs_pred_and_hist_5.png")

#align(center + horizon, image("figures/CsSnI3_disordered.png", height: 100%))

#image("figures/CsSnI3_calc_vs_pred_and_hist_0.png")

#image("figures/CsSnI3_calc_vs_pred_and_hist_1.png")

#image("figures/CsSnI3_calc_vs_pred_and_hist_2.png")

#image("figures/CsSnI3_calc_vs_pred_and_hist_3.png")

#image("figures/CsSnI3_calc_vs_pred_and_hist_4.png")

#image("figures/CsSnI3_calc_vs_pred_and_hist_5.png")

#matrix-slide()[
#align(right + horizon, image("figures/water_cls_calc_vs_pred_and_hist.png"))
][
#align(left + horizon, image("figures/CsSnI3_calc_vs_pred_and_hist.png"))
]


#slide[
  #align(center, 
  image(
    "figures/convergence_analysis_Eg_only.svg",
    height: 70%,
  ) + [accurate to within $cal("O")$ (10 meV) #emph[cf.] typical band gap accuracy of $cal("O")$ (100 meV); #pause \ ridge-regression on one snapshot more accurate than oneshot]
  )
]


== Speedup
#slide[
  #align(center + horizon,
    image("figures/speedup.svg", height: 80%) +
    [speedup of $cal("O")$(10) to $cal("O")$ (100)]
  )
]

== Transferability (or lack thereof)

#align(horizon + center, image("figures/transferability_water.png"))

#align(horizon + center, image("figures/transferability_cssni3.png"))

== Integrated in `koopmans`

- new block in the input file
- simple control of training/testing/predicting
- generates the ML model as a `.pkl` file for use in subsequent calculations

#raw(block: true, lang: "json", read("scripts/cssni3_ml_block.json"))

== Conclusions
- lightweight machine-learning models can predict Koopmans screening parameters with high accuracy
- #pause does not transfer to systems with novel atomic environments and/or substantially different macroscopic screening
- #pause predicting electronic response can be done efficiently with frozen-orbital approximations and machine learning
- #pause for more details see our arXiv preprint #cite(<Schubert2024>)

== References
#bibliography("references.bib")
