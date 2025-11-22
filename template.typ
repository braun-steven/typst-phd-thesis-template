#import "definitions.typ": *
#import "pages.typ": *
#import "colors.typ": *
#import "@preview/drafting:0.2.2": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/drafting:0.2.2"
#import "@preview/muchpdf:0.1.1": muchpdf
#import "@preview/ctheorems:1.1.3": *


// The buildMainHeader, buildSecondaryHeader, isAfter, getHeader methods are taken and modified from
// Jacopo Zagoli: https://github.com/zagoli/simple-typst-thesis


#let buildMainHeader(mainHeadingContent) = {
    [
        #align(center, smallcaps(mainHeadingContent))
        #line(length: 100%, stroke: 0.5pt)
    ]
}

#let buildSecondaryHeader(mainHeadingContent, secondaryHeadingContent) = {
    context {
        let loc = here()
        if calc.even(loc.page()) {
            align(left)[
                #text(12pt, smallcaps(mainHeadingContent))  // Appears on left (even) pages
        ]
        } else {
            align(right)[
                #text(12pt, emph(secondaryHeadingContent)) // appears on right (uneven) pages
        ]
        }
    }

    line(length: 100%, stroke: 0.5pt)
}


// To know if the secondary heading appears after the main heading
#let isAfter(secondaryHeading, mainHeading) = {
    let secHeadPos = secondaryHeading.location().position()
    let mainHeadPos = mainHeading.location().position()
    if (secHeadPos.at("page") > mainHeadPos.at("page")) {
        return true
    }
    if (secHeadPos.at("page") == mainHeadPos.at("page")) {
        return secHeadPos.at("y") > mainHeadPos.at("y")
    }
    return false
}

#let getHeader() = {
        context {
            let loc = here()
            // Find if there is a level 1 heading on the current page
            let nextMainHeading = query(selector(heading).after(loc)).find(headIt => {
                headIt.location().page() == loc.page() and headIt.level == 1
            })
            if (nextMainHeading != none) {
                if nextMainHeading.numbering == none {
                    return none
                } else {
                   return buildMainHeader(nextMainHeading.body)
                }
            }

            // Find the last previous level 1 heading -- at this point surely there's one
            let lastMainHeading = query(selector(heading).before(loc)).filter(headIt => {
                headIt.level == 1
            }).last()

            // Find if the last level > 1 heading in previous pages
            let previousSecondaryHeadingArray = query(selector(heading).before(loc)).filter(headIt => {
                headIt.level > 1
            })
            let lastSecondaryHeading = if (previousSecondaryHeadingArray.len() != 0) { previousSecondaryHeadingArray.last() } else { none }

            // Find if the last secondary heading exists and if it's after the last main heading
            if (lastSecondaryHeading != none and isAfter(lastSecondaryHeading, lastMainHeading)) {
                return buildSecondaryHeader(lastMainHeading.body, lastSecondaryHeading.body)
            }
            return buildMainHeader(lastMainHeading.body)
        }
}

#let project(
    title: "", author: "",
    date-submission: "", date-defense: "", city: "", university: "",
    department: "", body,
    inside-outside-margins: true
) = {
    // Set the document's basic properties.
    set document(author: author.name, title: title)
    set text(font: "New Computer Modern", lang: "en", size: 11pt)
    show math.equation: set text(weight: 400)
    set math.equation(numbering: "(1)", number-align: bottom)
    set par(justify: true)
    set heading(numbering: "1.1")

    show link: it => {
        text(thesis-red)[#it]
    }

    // Title page.
    page-title(title, author, date-submission, university, department)

    // Set inside/outside margins after title page
    set page(paper: "a4", margin: (inside: 4.5cm, outside: 2.75cm, y: 3.50cm))
    page-title-back(author, title, date-defense, university, city)

    // Set footer number "I" style left/right

    set page(footer: {
        context {
            if calc.even(here().page()) {
                align(left, counter(page).display("I"))
            } else {
                align(right, counter(page).display("I"))
            }
        }
    })


    show heading: it => block({
        // If heading has numbering, add space between counter and it.body
        if it.numbering != none {
            counter(heading).display()
            h(1em)
        }
        it.body
        v(0.5em) // Also add space between body and heading
    })

    page-promotionsordnung(author, date-submission, city)
    page-quote()
    page-abstract()
    page-publication-list-summary()
    page-acknowledgments()
    page-outline()

    page-list-of-figures()
    page-acronyms()
    page-notation()
    set page(header: [])



    // Main body.
    // Set footer number "1" style left/right
    set page(footer: {
        context {
            if inside-outside-margins {
                if calc.even(here().page()) {
                    align(left, counter(page).display("1"))
                } else {
                    align(right, counter(page).display("1"))
                }
            } else {
                align(center, counter(page).display("1"))
            }
                
        }
    })

    // Align Figure captions to the left
    show figure.caption: set align(left)
    set figure(placement: top)

    // Add vertical space to figures
    show figure.caption: it => {
        if it.kind == table {
            it
            v(0.5em)  // Table: Caption is above content, add space after caption
        } else if it.kind == image {
            v(0.5em)  // Figure: Add above and below caption
            it
            v(0.5em)
        } else {
            it
        }
    }

    show heading.where(level: 1): it => {
        set block(below: 10pt)
        set text(weight: "regular")
        align(center)[*#smallcaps(it)*]
    }


    show cite: it => {
        // Only color the number, not the brackets.
        // show regex("\d+"): set text(fill: thesis-red)
        // or regex("[\p{L}\d+]+") when using the alpha-numerical style

        // Matches the full citation, like (Galal et al. 2024b)
        show regex("\w.*"): set text(fill: thesis-red)

        it
    }

    show ref: it => {
        if it.element == none {
            // This is a citation, which is handled above.
            return it
        }

        // Only color the number, not the supplement.
        // show regex("[\d.]+"): set text(fill: thesis-red)
        set text(fill: thesis-red)
        it
    }

    // Add some spacing before/after block equations
    show math.equation.where(block: true): it => {
        v(0.5em)
        it
        v(0.5em)
    }


    set cite(style: "apa")

    set par(first-line-indent: par-first-line-indent, spacing: 0.75em)
    set page(header: getHeader())
    counter(page).update(1)
    body
}

#let cites(key) = {
    cite(key, form: "prose")
}


#let todo(body) = [
    #margin-note(side: left, stroke: color-orange-fg, fill: color-orange-bg)[#text(size:8pt)[#body]]
]


#let publication-header-text(authors: "", title: "", venue: "", under-review: false, preprint: "") = [

    This section summarizes and contextualizes the paper

    #v(1em)

    #align(center)[
        #box(width: 80%)[
            #align(left)[
                #authors. #title. #if under-review {[Under review, preprint available at #link(preprint).]} else {[#emph[#venue].]
        }
            ]
        ]
    ]

    #v(1em)
]


// Pagebreak with empty header/footer
#let pagebreak-clean(weak: false, to: "") = {
    set page(header: "", footer: "")
    pagebreak(weak: weak, to: to)
}
