return {
  -- {COUNTER_INCREMENT, NAMED, HL_NORMAL, HL_EXTENDED}
  ["{"]  = {1,  true,  true},
  ["}"]  = {-1, true,  true},
  ["["]  = {1,  true,  true},
  ["]"]  = {-1, true,  true},
  ["[["] = {1,  true,  true},
  ["]]"] = {-1,  true,  true},
}
