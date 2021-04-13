return {
  -- {COUNTER_INCREMENT, HL_NORMAL, HL_EXTENDED}
  ["{"]                    = {1,  true,  true},
  ["}"]                    = {-1, true,  true},
  ["("]                    = {1,  true,  true},
  [")"]                    = {-1, true,  true},
  ["["]                    = {1,  true,  true},
  ["]"]                    = {-1, true,  true},
  ["function_definition+"] = {1,  false, false},
  ["parameters+"]          = {-1, false, false},
  ["if_statement+"]        = {1,  false, false},
  ["while_statement+"]     = {1,  false, false},
  ["for_statement+"]       = {1,  false, false},
}
