return {
  -- {COUNTER_INCREMENT, HL_NORMAL, HL_EXTENDED}
  ["{"] = { 1, true, true },
  ["}"] = { -1, true, true },
  ["("] = { 1, true, true },
  [")"] = { -1, true, true },
  ["["] = { 1, true, true },
  ["]"] = { -1, true, true },
  ["jsx_element+"] = { 1, false, false },
  ["jsx_opening_element+"] = { 0, false, true },
  ["jsx_closing_element+"] = { 0, false, true },
}
