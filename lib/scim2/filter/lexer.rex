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

  DIGIT             \d
  ALPHA             [a-zA-Z]
  NAMECHAR          [a-zA-Z0-9_-]
  SCHEMACHAR        [a-zA-Z0-9:\._-]
  ESCAPEDSTR        "(?:[^"\\]|\\.)*"

rule
  # Attribute Operators
  \s{EQ}\s          { [:EQ, :eq] }
  \s{NE}\s          { [:NE, :ne] }
  \s{GT}\s          { [:GT, :gt] }
  \s{GE}\s          { [:GE, :ge] }
  \s{LT}\s          { [:LT, :lt] }
  \s{LE}\s          { [:LE, :le] }
  \s{CO}\s          { [:CO, :co] }
  \s{SW}\s          { [:SW, :sw] }
  \s{EW}\s          { [:EW, :ew] }
  \s{PR}            { [:PR, :pr] }

  # Logical Operators
  \s{AND}\s         { [:AND, :and] }
  \s{OR}\s          { [:OR, :or] }
  {NOT}\s*          { [:NOT, :not] }  # NOTE: RFC7644 (Section 3.4.2) seems to specify no space, but the example contradicts it

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
  {DOT}                                 { [:DOT, text] }

end
