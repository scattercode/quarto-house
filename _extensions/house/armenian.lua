--[[
armenian.lua -- Armenian script in PDF output.

The house PDF fonts (Latin Modern) have no Armenian glyphs, and a TeX engine
drops a character it cannot find with nothing more than a line in the log,
so Armenian text simply vanishes from the page. This filter gives each Latin
Modern face a font fallback, so any character Latin Modern lacks is taken
from the Noto Armenian fonts vendored in fonts/: Noto Serif Armenian for the
roman face, Noto Sans Armenian for the sans (the KOMA headings, the title)
and the mono, each in regular and bold.

Why a fallback, and why LuaLaTeX. A fallback is resolved per glyph inside
the font, so it is indifferent to emphasis, bold, headings and table cells.
XeLaTeX has no fallback; the usual substitute there (ucharclasses) switches
font at script boundaries inside TeX groups, and a boundary that falls at the
edge of *emphasis* or **bold** leaves the Armenian font switched on for the
Latin text that follows. That is why house-pdf uses LuaLaTeX.

The fonts are loaded by absolute path, resolved from this extension's own
directory. A relative path would depend on where Quarto compiles the .tex,
which differs between a single document, a website page and a book.

PDF only. HTML and Word leave font fallback to the browser and to Word,
which both find an Armenian font on their own.

Set `house-armenian: false` in a document's metadata to leave it out.
]]

local function font(dir, name)
  -- luaotfload's [path] lookup takes an absolute path (file: would search
  -- its font database by name); forward slashes on every platform.
  return "[" .. (dir:gsub("\\", "/")) .. "/" .. name .. ".ttf]"
end

function Meta(meta)
  if not quarto.doc.is_format("latex") then
    return nil
  end
  if meta["house-armenian"] ~= nil and pandoc.utils.stringify(meta["house-armenian"]) == "false" then
    return nil
  end

  local dir = quarto.utils.resolve_path("fonts")
  -- An ordered list, so the generated LaTeX is the same on every run.
  local chains = {
    { "houseserif", font(dir, "NotoSerifArmenian-Regular") },
    { "houseserifbold", font(dir, "NotoSerifArmenian-Bold") },
    { "housesans", font(dir, "NotoSansArmenian-Regular") },
    { "housesansbold", font(dir, "NotoSansArmenian-Bold") },
  }

  local lines = {
    "% Armenian fallback for Latin Modern (house extension, armenian.lua).",
    "\\ifdefined\\directlua",
  }
  for _, chain in ipairs(chains) do
    table.insert(lines, string.format(
      '\\directlua{luaotfload.add_fallback("%s", {"%s"})}', chain[1], chain[2]))
  end
  table.insert(lines, [[
\setmainfont{Latin Modern Roman}[
  RawFeature = {fallback=houseserif},
  BoldFeatures = {RawFeature = {fallback=houseserifbold}},
  BoldItalicFeatures = {RawFeature = {fallback=houseserifbold}},
]
\setsansfont{Latin Modern Sans}[
  RawFeature = {fallback=housesans},
  BoldFeatures = {RawFeature = {fallback=housesansbold}},
  BoldItalicFeatures = {RawFeature = {fallback=housesansbold}},
]
\setmonofont{Latin Modern Mono}[
  RawFeature = {fallback=housesans},
  BoldFeatures = {RawFeature = {fallback=housesansbold}},
]
\fi]])

  quarto.doc.include_text("in-header", table.concat(lines, "\n"))
  return nil
end
