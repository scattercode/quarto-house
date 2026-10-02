# quarto-house

The Scattercode house style for [Quarto](https://quarto.org), packaged as a
**format extension**. It bundles the PDF preamble, the website theme, the
Word reference document and the Lua filters that every document set shares,
and exposes them as three named formats:

| Format       | What it is                                                  |
|--------------|-------------------------------------------------------------|
| `house-pdf`  | A4, XeLaTeX, KOMA `scrartcl`, teal headings and links       |
| `house-html` | Cosmo theme with the house palette, right-hand ToC          |
| `house-docx` | Word with a styled reference document                       |

One definition, used by every repository that installs it. A change to the
style is a new version of this extension, and each repository picks up the
change when it chooses to.

## Installing it in a project

```sh
quarto add scattercode/quarto-house
```

That copies `_extensions/scattercode/house/` into the project. Commit that
directory — Quarto's convention is that extensions are vendored, so a clone
of the project renders without a network call. Re-run the command to
upgrade.

Then use the formats by name:

```yaml
# a single document
format:
  house-html: default
  house-pdf: default
  house-docx: default
```

Any option can still be overridden where it is used. A book project, for
example, keeps the shared style but switches the document class:

```yaml
# _quarto.yml of a book
format:
  house-pdf:
    documentclass: scrbook
    toc-depth: 2
```

## What the filters do

- `strip-numbers.lua` removes manual numbers from headings
  (`# 4. Medallion pipelines` → `Medallion pipelines`) so Quarto's own
  numbering applies. Sources keep their numbers for wiki replication.
- `unwrap-external-links.lua` turns links whose target will not exist in
  the output into plain text. In PDF and Word output that is every relative
  link to another Markdown file; in every format it is also anything
  matching `house-unwrap-links` (default: READMEs, `whitepapers.md`,
  paths outside the repository).
- `part-refs.lua` resolves `@part-<directory>` to "Part III" in book
  projects, from the order of parts in `_quarto.yml`. It does nothing in a
  document that has no part references.
- `crossref-pages.lua` (HTML only) resolves a `@sec-`/`@fig-`/`@tbl-`
  reference whose target is a heading on a *sibling page* of a website into
  a link to that page, with the heading text as the link text. It lets one
  set of Markdown files serve both as separate web pages and as a combined
  single document. References defined on the page itself are left to
  Quarto; references found nowhere are left for Quarto to report.

## Images

Each format sets a `default-image-extension` (`svg` for HTML, `pdf` for PDF,
`png` for Word). An image reference without an extension —
`![caption](assets/diagram){#fig-diagram}` — therefore picks the right file
per format, provided all three exist. Hand-drawn SVGs can keep their `.svg`
extension; Quarto converts them. The extension-less form is for diagrams
produced by code cells, where Quarto's conversion fails when a document
renders to several formats in one run.

## Palette

The colours are the same in the SCSS, the LaTeX preamble, the Word styles
and the hand-drawn SVG diagrams: deep teal `#2A6372`, teal `#367E8D`, ink
`#14232A`, slate `#5D7079`, amber `#C98A2B` (cautions, decisions), cream
`#FAFAF7` (diagram backgrounds).

## Prerequisites in the rendering environment

- Quarto 1.5 or later.
- A TeX distribution with XeLaTeX for `house-pdf` — `quarto install tinytex`
  is enough.
- `rsvg-convert` (package `librsvg2-bin`) if documents include SVG
  diagrams, which Quarto converts for PDF and Word.

## Trying it

`example/` is a one-page document that exercises all three formats:

```sh
cd example && quarto render
```

## Versioning

Bump `version` in `_extensions/house/_extension.yml` and tag the commit.
Projects that want a particular version can pin it:

```sh
quarto add scattercode/quarto-house@v0.1.0
```
# quarto-house
