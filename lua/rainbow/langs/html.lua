return {
  -- {COUNTER_INCREMENT, HL_NORMAL, HL_EXTENDED}
  ["{"]               = {1,  true,  true},
  ["}"]               = {-1, true,  true},
  ["("]               = {1,  true,  true},
  [")"]               = {-1, true,  true},
  ["["]               = {1,  true,  true},
  ["]"]               = {-1, true,  true},
  ["element+"]        = {1,  false, false},
  ["script_element+"] = {1,  false, false},
  ["style_element+"]  = {1,  false, false},
  ["<"]               = {0,  true,  true},
  ["<!"]              = {0,  true,  true},
  ["</"]              = {0,  true,  true},
  ["tag_name+"]       = {0,  false, true},
  ["/>"]              = {0,  true,  true},
  [">"]               = {0,  true,  true},
}
