-- Typst-only layout for cv.qmd. The HTML version lays out the page with
-- .columns/.column and .aligned-text divs styled in styles.css; Typst ignores
-- those classes, so this filter maps them onto functions in cv-style.typ.
-- Other formats pass through untouched.

if not quarto.doc.is_format("typst") then
  return {}
end

local function raw(s) return pandoc.RawBlock("typst", s) end

local function promote_headers(blocks)
  return blocks:walk({
    Header = function(h) h.level = math.max(1, h.level - 1); return h end,
  })
end

local function fr(width)
  local n = width and tonumber(width:match("([%d%.]+)%%"))
  return n and string.format("%gfr", n) or "1fr"
end

function Div(el)
  if el.classes:includes("pdf-hide") then
    return {}
  end

  if el.classes:includes("aligned-text") then
    local left, right = pandoc.Blocks{}, pandoc.Blocks{}
    for _, b in ipairs(el.content) do
      if b.t == "Div" and b.classes:includes("left") then left = b.content end
      if b.t == "Div" and b.classes:includes("right") then right = b.content end
    end
    local out = pandoc.Blocks{ raw("#cv-meta([") }
    out:extend(left); out:insert(raw("], [")); out:extend(right); out:insert(raw("])"))
    return out
  end

  if el.classes:includes("columns") then
    local cols = {}
    for _, b in ipairs(el.content) do
      if b.t == "Div" and b.classes:includes("column") and not b.classes:includes("pdf-hide") then
        local content = b.content
        -- The header row holds ### headings that act as sections in the PDF.
        if b.classes:includes("header-col") then content = promote_headers(content) end
        table.insert(cols, { width = fr(b.attributes.width), content = content })
      end
    end
    if #cols == 1 then return cols[1].content end
    local widths = {}
    for _, c in ipairs(cols) do table.insert(widths, c.width) end
    local out = pandoc.Blocks{ raw("#cv-columns((" .. table.concat(widths, ", ") .. "), [") }
    for i, c in ipairs(cols) do
      if i > 1 then out:insert(raw("], [")) end
      out:extend(c.content)
    end
    out:insert(raw("])"))
    return out
  end
end
