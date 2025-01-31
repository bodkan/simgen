-- TODO: Looks at these links to define a custom "Show the solution" callout
-- https://www.youtube.com/watch?v=DDQO_3R-q74
-- https://examples.quarto.pub/collapse-callout/

function Callout(el)
  if quarto.doc.isFormat("html") then
    -- Set default collapse to true if unset
    if not el.collapse then
      el.collapse = true
    end
    return el
  end
end
