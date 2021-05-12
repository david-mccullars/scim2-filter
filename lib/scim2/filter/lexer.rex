class Scim2::Filter::Lexer

macro
  EQ                [eE][qQ]
  NE                [nN][eE]
  GT                [gG][tT]
  GE                [gG][eE]
  LT                [lL][tT]
  LE                [lL][eE]
  CO                [cC][oO]
  SW                [sS][wW]
  EW                [eE][wW]
  PR                [pP][rR]

  AND               [aA][nN][dD]
  OR                [oO][rR]
  NOT               [nN][oO][tT]

  LPAREN            \(
  RPAREN            \)
  LBRACKET          \[
  RBRACKET          \]
  COLON             :
  DOT               \.
  SPACE             \s

  DIGIT             \d
  ALPHA             [a-zA-Z]
  NAMECHAR          [a-zA-Z0-9_-]
  SCHEMACHAR        [a-zA-Z0-9:\._-]
  ESCAPEDSTR        "(?:[^"\\]|\\.)*"

rule
  # Attribute Operators
  {EQ}              { [:EQ, :eq] }
  {NE}              { [:NE, :ne] }
  {GT}              { [:GT, :gt] }
  {GE}              { [:GE, :ge] }
  {LT}              { [:LT, :lt] }
  {LE}              { [:LE, :le] }
  {CO}              { [:CO, :co] }
  {SW}              { [:SW, :sw] }
  {EW}              { [:EW, :ew] }
  {PR}              { [:PR, :pr] }

  # Logical Operators
  {AND}             { [:AND, :and] }
  {OR}              { [:OR, :or] }
  {NOT}             { [:NOT, :not] }

  # Grouping Operators
  {LPAREN}          { [:LPAREN, text] }
  {RPAREN}          { [:RPAREN, text] }
  {LBRACKET}        { [:LBRACKET, text] }
  {RBRACKET}        { [:RBRACKET, text] }

  # Other
  null                                  { [:NULL, nil] }
  (?:true|false)                        { [:BOOLEAN, text == 'true'] }
  {DIGIT}+                              { [:NUMBER, text.to_i] }
  {ESCAPEDSTR}                          { [:STRING, text.undump] }
  ({ALPHA}+{COLON}{SCHEMACHAR}+){COLON} { [:SCHEMA, @ss.captures.first] }
  {ALPHA}{NAMECHAR}*                    { [:ATTRNAME, text.to_sym] }
  {COLON}                               { [:COLON, text] }
  {DOT}                                 { [:DOT, text] }
  {SPACE}                               { [:SPACE, text] }

end
