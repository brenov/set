{
module Lexer where

import System.IO
import System.IO.Unsafe
}

%wrapper "posn"

$digit = 0-9        -- digits
$alpha = [a-zA-Z]   -- alphabetic characters

@natural = $digit+
@integer = [\-]$digit+
@real = [\-]?$digit+.$digit+
@boolean = (True) | (False)
@string = \" [^\" \\]* \"

tokens :-

  $white+                         ;
  "#".*                           ; -- Comment
  program                         { \p s -> Program (getLC p) }
  end                             { \p s -> End (getLC p) }
  :                               { \p s -> Colon (getLC p) }
  ";"                             { \p s -> SemiColon (getLC p) }
  ","                             { \p s -> Comma (getLC p) }
  "."                             { \p s -> Dot (getLC p) }
  Nat                             { \p s -> Type s (getLC p) }
  Int                             { \p s -> Type s (getLC p) }
  Real                            { \p s -> Type s (getLC p) }
  Bool                            { \p s -> Type s (getLC p) }
  Text                            { \p s -> Type s (getLC p) }
  "Array"                         { \p s -> Type s (getLC p) }
  if                              { \p s -> If (getLC p) }
  else                            { \p s -> Else (getLC p) }
  elseif                          { \p s -> Else_If (getLC p) }
  endif                           { \p s -> End_If (getLC p) }
  while                           { \p s -> While (getLC p) }
  endwhile                        { \p s -> End_While (getLC p) }
  print                           { \p s -> Print (getLC p) }
  input                           { \p s -> Input (getLC p) }
  @natural                        { \p s -> Nat (read s) (getLC p) }
  @integer                        { \p s -> Int (read s) (getLC p) }
  @real                           { \p s -> Real (read s) (getLC p) }
  @boolean                        { \p s -> Bool (read s) (getLC p) }
  @string                         { \p s -> Text s (getLC p) }
  $alpha [$alpha $digit \_ \']*   { \p s -> Id s (getLC p) }
  true                            { \p s -> Bool True (getLC p) }
  false                           { \p s -> Bool False (getLC p) }
  :=                              { \p s -> Assign (getLC p) }
  "+"                             { \p s -> Addition (getLC p) }
  "-"                             { \p s -> Subtraction (getLC p) }
  "*"                             { \p s -> Multiplication (getLC p) }
  "/"                             { \p s -> Division (getLC p) }
  >                               { \p s -> Greater (getLC p) }
  >=                              { \p s -> GreaterOrEqual (getLC p) }
  "<"                             { \p s -> Smaller (getLC p) }
  "<="                            { \p s -> SmallerOrEqual (getLC p) }
  "!="                            { \p s -> Denial (getLC p) }
  ==                              { \p s -> Equality (getLC p) }
  "&&"                            { \p s -> And (getLC p) }
  "||"                            { \p s -> Or (getLC p) }
  "["                             { \p s -> Open_Bracket (getLC p) }
  "]"                             { \p s -> Close_Bracket (getLC p) }
  "("                             { \p s -> Open_Parentheses (getLC p) }
  ")"                             { \p s -> Close_Parentheses (getLC p) }
{

-- Token Position
getLC (AlexPn _ l c) = (l, c)

-- Each action has type :: String -> Token
-- The token type:
data Token =
  Program                                        (Int, Int)   |
  End                                            (Int, Int)   |
  Colon                                          (Int, Int)   |
  SemiColon                                      (Int, Int)   |
  Comma                                          (Int, Int)   |
  Dot                                            (Int, Int)   |
  Id            String                           (Int, Int)   |
  Type          String                           (Int, Int)   |
  Nat           Int                              (Int, Int)   |
  Int           Int                              (Int, Int)   |
  Real          Float                            (Int, Int)   |
  Bool          Bool                             (Int, Int)   |
  Text          String                           (Int, Int)   |
  Pointer       (Token, Token)                   (Int, Int)   |
  Set           [Token]                          (Int, Int)   |
  Array         (Token, Token, [Token])          (Int, Int)   |
  If                                             (Int, Int)   |
  Else                                           (Int, Int)   |
  Else_If                                        (Int, Int)   |
  End_If                                         (Int, Int)   |
  While                                          (Int, Int)   |
  End_While                                      (Int, Int)   |
  Print                                          (Int, Int)   |
  Input                                          (Int, Int)   |
  Assign                                         (Int, Int)   |
  Addition                                       (Int, Int)   |
  Subtraction                                    (Int, Int)   |
  Multiplication                                 (Int, Int)   |
  Division                                       (Int, Int)   |
  Greater                                        (Int, Int)   |
  GreaterOrEqual                                 (Int, Int)   |
  Smaller                                        (Int, Int)   |
  SmallerOrEqual                                 (Int, Int)   |
  Denial                                         (Int, Int)   |
  Equality                                       (Int, Int)   |
  And                                            (Int, Int)   |
  Or                                             (Int, Int)   |
  Open_Bracket                                   (Int, Int)   |
  Close_Bracket                                  (Int, Int)   |
  Open_Parentheses                               (Int, Int)   |
  Close_Parentheses                              (Int, Int)   |
  String        String                           (Int, Int)
  deriving (Eq,Show)

getTokens fn = unsafePerformIO (getTokensAux fn)

getTokensAux fn = do {fh <- openFile fn ReadMode;
                   s <- hGetContents fh;
                   return (alexScanTokens s)}
}
