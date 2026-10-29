-- Strip manual heading numbers ("1.", "2.3", "10.") from headings so
-- Quarto's own numbering applies cleanly. Source files keep their numbers
-- for wiki replication, where nothing numbers them automatically.
--
-- A number counts as a section number only if it has a dot in it. A bare
-- number is part of the heading's text: "50 words" or "2026 accounts" must
-- keep it. The first version also accepted a bare number, and quietly
-- turned "### 50 words" into "### words" in Word and PDF.
function Header(el)
  local first = el.content[1]
  if first and first.t == "Str" and first.text:match("^%d+[%.%d]*$")
      and first.text:find(".", 1, true) then
    table.remove(el.content, 1)
    if el.content[1] and el.content[1].t == "Space" then
      table.remove(el.content, 1)
    end
  end
  return el
end
