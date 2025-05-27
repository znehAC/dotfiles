# VERBS:
  d    delete
  c    change
  y    yank (copy)
  v    visual mode
  >/<  indent/outdent
  g~   swap case
  =    auto-indent

# MODIFIERS / TEXT OBJECTS:
  w    word
  e    end of word
  b    back (start of word)
  i    inner (inside object)
  a    around (object incl. delimiters)
  t    till (up to char)
  f    find (to char)
  %    match pair (jump to bracket/paren)
  $    end of line
  ^    first nonblank
  0    start of line

# EXAMPLES:
  ci"    change inside quotes
  da'    delete around single quotes
  yiw    yank inner word
  diw    delete inner word
  vi(    visual inner parens
  va[    visual around brackets
  d$     delete to end of line
  ct,    change till comma

# MOTIONS:
  h/j/k/l  left/down/up/right
  gg/G     top/bottom
  { }      paragraph up/down
  /TEXT    search forward
  n/N      next/prev search result
