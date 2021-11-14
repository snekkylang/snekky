# File Structure
###### Last updated 2021-11-14
This document describes the syntax of Snekky source code in EBNF as proposed in ISO/IEC 14977.

**Table of Contents**

- [EBNF Definition](#ebnf-definition)
- [General Definitions](#general-definitions)
- [Identifiers](#identifiers)
- [Literals](#literals)
    - [Number](#number-literal)
    - [String](#string-literal)
    - [Boolean](#boolean-literal)
    - [Null](#null-literal)
    - [Array](#array-literal)
    - [Hash](#hash-literal)
    - [Function](#function-literal)
- [Expressions](#expressions)
    - [Call](#call-expression)
    - [Regex](#regex-expression)
    - [Access](#access-expression)
- [Statements](#statements)
    - [Block](#block-statement)
    - [Variable](#variable-statement)
        - [Declaration](#variable-declaration)
        - [Assign](#variable-assign)
    - [If](#if-statement)
    - [While](#while-statement)
    - [For](#for-statement)
    - [When](#when-statement)
    - [Return](#return-statement)
    - [Continue](#continue-statement)
    - [Break](#break-statement)
    - [Import](#import-statement)


## EBNF Definition
In computer science, extended Backus–Naur form (EBNF) is a family of metasyntax notations, any of which can be used to express a context-free grammar. EBNF is used to make a formal description of a formal language such as a computer programming language. They are extensions of the basic Backus–Naur form (BNF) metasyntax notation. \
– [Wikipedia](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form)
| Usage           | Notation  |
|-----------------|-----------|
| definition      | =         |
| concatenation   | ,         |
| termination     | ;         |
| alternation     | \|        |
| optional        | [ ... ]   |
| repetition      | { ... }   |
| grouping        | ( ... )   |
| terminal string | " ... "   |
| terminal string | ' ... '   |
| comment         | (* ... *) |

## General definitions
```EBNF
Letter = "a" | ... | "z" | "A" | ... | "Z";
Number = "0" | "1" | "2" | "4" | "5" | "6" | "7" | "8" | "9";
Hex = "a" | ... | "f" | "A" | ... | "F" | Number;
UnicodeChar = (* any Unicode character *)
```

## Identifiers
An identifier is a name assigned to an element in a program. It has to start with either a letter or an underscore followed by an arbitrary amount of alphanumeric characrers.
```EBNF
Identifier = ( Letter | "_" ) { ( Letter | Number | "_" ) };
```
Examples of valid identifiers are `myVariable`, `TeSt123`, `_2ident`, and `x`. An example of an invalid identifier is `0test`.

## Literals
A literal produces a value which is represented as an object.
```EBNF
Literal = NumberLiteral | StringLiteral | BooleanLiteral | NullLiteral | ArrayLiteral | HashLiteral | FunctionLiteral;
```

### Number literal
A number literal may represent any unsigned floating point number expressed either in decimal or hexadecimal notation.
```EBNF
NumberLiteral = DecNumber | HexNumber;
DecNumber = Number, { Number };
HexNumber = "0x", Hex, { Hex };
```
Examples:
```js
42
3.452
0xA6C8DD
```

### String literal
A string literal represents any UTF-8-encoded string enclosed by quotation marks.
```EBNF
StringLiteral = '"', { UnicodeChar }, '"';
```
Examples:
```js
"This is a string!"
```

### Boolean literal
A boolean literal represents a truth value and may either be `true` or `false`.
```EBNF
BooleanLiteral = "true" | "false";
```
```js
true
false
```

### Null literal
Null represents the absence of a value.
```EBNF
NullLiteral = "null";
```

### Array literal
An array literal represents a collection of indexed literals.
```EBNF
ArrayLiteral = "[", ExpressionList, "]";
```
Examples:
```js
[3, "my string", true]
```

### Hash literal
A hash literal represents a key-value-collection of literals.
```EBNF
HashLiteral = "{", [ HashKeyValue, { ",", HashKeyValue } ], "}";
HashKeyValue = ( StringLiteral | Identifier ) , ":", Expression;
```
Examples:
```js
{
    "string": true,
    ident: 2.3
}

{}
```

### Function literal
A function literal represents a higher-order function. It may take a list of arguments and may return a value.
```EBNF
FunctionLiteral = "func", "(", FunctionParameterList, ")", Block;
FunctionParameterList = [ FunctionParameter, { ",", FunctionParameter } ];
FunctionParameter = [ "mut" ], Identifier;
```
Examples:
```js
func(x, mut y) {
    y += 2;
    return x + y;
}
```

### Expressions
An expression generates an object at runtime.
```EBNF
Expression = BinaryExpression | UnaryExpression | BracketedExpression | Literal | RegexExpression | ExpressionStatement | AccessExpression;
BracketedExpression = "(", Expression, ")";
BinaryExpression = Expression, BinaryOperator, Expression;
UnaryExpression = UnaryOperator, Expression;
BinaryOperator = "+", "-", "*", "/", "%", "==", "!=", "<", "<=", ">", ">=", "&&", "||", "&", "|", "<<", ">>", "^", "><";
UnaryOperator = "-", "~";
ExpressionList = [ ( Expression, { ",", Expression } ) ];
```
Examples:
```js
2 * (3 + 4)
4
true
-3.324345
```

### Call expression
A call expression calls a function which may return a value.
```EBNF
CallExpression = Expression, "(", ExpressionList, ")";
```
Examples:
```js
add(1, 2)
println("Hello, World!")
```

### Regex expression
A regex expression generates a regex object. It only serves as syntactical sugar for `Regex.compile`.
```EBNF
RegexExpression = "~/", { UnicodeChar }, "/";
```
Examples:
```js
~/a[bc]*d/
```

### Access expression
An access expression evaluates to the value stored at the given index in an array or hash.
```EBNF
AccessExpression = ArrayAccess | DotAccess;
ArrayAccess = Expression, "[", Expression, "]";
DotAccess = Expression, ".", Identifier;
```
Examples:
```js
myArray[3]
Sys.println
```

## Statements
A statement is a direct instruction telling the computer to do a certain thing. 
```EBNF
Statement = VariableDeclarationStatement | VariableAssignStatement | WhileStatement | ForStatement | ReturnStatement | ImportStatement | BreakStatement | ContinueStatement | ExpressionStatement | ExpressionableStatement;
```
Some statements may itself be used as an expression when their last statement is an expression and its semicolon is omitted.
```EBNF
ExpressionableStatement = BlockStatement | IfStatement | WhenStatement;
```
Examples:
```js
let x = if y > 5 {
    5
} else {
    y
};
```

### Block statement
A block statement (or compound statement) combines multiple statements into one creating a new lexical scope.
```EBNF
BlockStatement = "{", Statement, { Statement }, [ Expression ] "}";
```
Examples:
```js
let x = 2;
{
    let x = 2;
}
```

### Variable statement
A variable is an abstract storage location paired with an associated symbolic name. That symbolic name may either be an ident or a destructuring statement.

#### Variable declaration
```EBNF
VariableDeclarationStatement = VariableDeclaration, "=", Expression ";";
VariableDeclaration = VariableMutability, VariableName;
VariableMutability = "let" | "mut";
VariableName = Identifier | ( "[", Identifier, { ",", Identifier } "]" );
```
Examples:
```js
let myVariable = 1 * (2 + 3);
let [x, y , z] = [1, 2, 3];
mut {statusCode} = {statusCode: 200, text: "Request succeeded!"};
```

#### Variable assign
```EBNF
VariableAssignStatement = Identifier, AssignOperator, Expression;
AssignOperator = "=", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "<<=", ">>=", "^=";
```
Examples:
```js
myVariable = 42;
i += 1; 
```

### If statement
An if statement executes a corresponding piece of code depending on whether the given condition is met.
```EBNF
IfStatement = "if", Expression, BlockStatement, [ "else", BlockStatement ];
```
Examples:
```js
if x == 2 {
    Sys.println("x is 2");
}

if arr.length() == 0 {
    return false;
} else {
    return true;
}
```

### While statement
A while statement executes a piece of code as long as the given condition is met.
```EBND
WhileStatement = "while", Expression, BlockStatement;
```
Examples:
```js
mut x = 0;
while x < 5 {
    Sys.println(x);
    x += 1;
}
```

### For statement
A for statement executes a piece of code until is underlying iterator has reached its end.
```EBNF
ForStatement = "for", [ VariableDeclaration, "in" ], Expression, BlockStatement;
```
Examples:
```js
for let [v, i] in [5, 2, 6, 4] {
    Sys.println(i);
    Sys.println(v);
}

for 0...5 {
    Sys.println("executed");
}
```

### When statement
A when statement is syntactical sugar for a chain of else-if-statements.
```EBNF
WhenStatement = "when", [ Expression ], "{", { Expression, "=>", Expression }, [ "else", "=>", Expression ] "}";
```
Examples:
```js
let x = 2;
when x {
    1 => Sys.println("x == 1");
    2 => Sys.println("x == 2");
    else => {
        Sys.println("x is neither 1 nor 2");
    }
}

when {
    x >= 2 => Sys.println("x >= 2");
    else => Sys.println("x < 2");
}
```

### Return statement
A return statement immediately returns from the current function call. It may return a value.
```EBNF
ReturnStatement = "return", [ Expression ], ";";
```
Examples:
```js
return 2 * 3;
return;
```

### Continue statement
A continue statement aborts the current iteration of a loop and jumps back to the beginning of said loop's block.
```EBNF
ContinueStatement = "continue", ";";
```
Exmaples:
```js
mut i = 0;
while true {
    i += 1;
    if i < 5 {
        continue;
    }
    Sys.println("i is greater than 5: " >< i);
}
```

### Break statement
A break statement immediately aborts the execution of loop ignoring its condition.
```EBNF
BreakStatement = "break", ";";
```
Examples:
```js
mut i = 0;
while true {
    i += 1;
    if i > 5 {
        break;
    }
}
Sys.println("loop aborted because i was greater than 5: " >< i);
```

### Import statement
An import statement pastes the content of the given file into this file at the current position. The `.snek` extension has to be omitted.
```EBNF
ImportStatement = "import", StringLiteral, ";";
```
Examples:
```js
import "my_file";
```

### Expression statement
Any expression may also be a statement when followed by a semicolon.
```EBNF
ExpressionStatement = Expression, ";";
```
```js
2 * (3 - 4);
test();
```