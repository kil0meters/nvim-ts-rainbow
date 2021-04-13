return {
  -- {COUNTER_INCREMENT, HL_NORMAL, HL_EXTENDED}
  ["{"] = {1,  true, true},
  ["}"] = {-1, true, true},
  ["("] = {1,  true, true},
  [")"] = {-1, true, true},
  ["["] = {1,  true, true},
  ["]"] = {-1, true, true},
}
