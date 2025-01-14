return {
  -- {COUNTER_INCREMENT, HL_NORMAL, HL_EXTENDED}
  ["{"] = { 1, true, true },
  ["#{"] = { 1, true, true },
  ["}"] = { -1, true, true },
  ["("] = { 1, true, true },
  ["%w("] = { 1, true, true },
  ["%i("] = { 1, true, true },
  [")"] = { -1, true, true },
  ["["] = { 1, true, true },
  ["]"] = { -1, true, true },
  ["class"] = { 1, false, true },
  ["def"] = { 1, false, true },
  ["if+"] = { 1, false, true },
  ["if"] = { 0, false, true },
  ["elsif"] = { 0, false, true },
  ["else"] = { 0, false, true },
  ["then"] = { 0, false, true },
  ["case+"] = { 0, false, true },
  ["case"] = { 0, false, true },
  ["when"] = { 0, false, true },
  ["while"] = { 0, false, true },
  ["until"] = { 0, false, true },
  ["for"] = { 0, false, true },
  ["do"] = { 1, false, true },
  ["begin"] = { 1, false, true },
  ["rescue"] = { 0, false, true },
  ["rescue+"] = { -1, false, false },
  ["ensure"] = { 0, false, true },
  ["ensure+"] = { -1, false, false },
  ["end"] = { -1, false, true },
  ["method_parameters+"] = { -1, false, false },
}
