# Bytecode
###### Last updated 2021-06-28
This document describes the bytecode generated by the Snekky [compiler](https://github.com/snekkylang/snekky/blob/master/src/compiler/Compiler.hx).

**Table of Contents**

- [Opcodes](#opcodes)
- [Notes](#notes)

## Opcodes
Snekky's evaluator is a stack-based virtual machine. It can execute programs which have been compiled to a custom bytecode by the Snekky compiler. Each Opcode is exactly one byte long. 32-bit signed integers are used for all operands. The following instructions are supported:
| Mnemonic           | OpCode (in Hex) | Operands | Stack (before -> after)                              | Description                                                                               |
|--------------------|-----------------|----------|------------------------------------------------------|-------------------------------------------------------------------------------------------|
| Constant           | 00              | index    | -> Any(v)                                            | Pushes constant at `index` onto the stack.                                                |
| Pop                | 01              |          | Any(v) ->                                            | Pops top object off stack and discards it.                                                |
| Jump               | 02              | position | [no change]                                          | Jumps to `position` in bytecode.                                                          |
| JumpFalse          | 03              | position | Boolean(v) ->                                        | Jumps to `position` in bytecode if object popped from stack is `Boolean(false)`.          |
| JumpTrue           | 04              | position | Boolean(v) ->                                        | Jumps to `position` in bytecode if object popped from stack is `Boolean(true)`.           |
| Add                | 05              |          | Number(v1), Number(v2) -> Number(v3)                 | Adds `v1` to `v2`.                                                                        |
| Subtract           | 06              |          | Number(v1), Number(v2) -> Number(v3)                 | Subtracts `v1` from `v2`.                                                                 |
| Multiply           | 07              |          | Number(v1), Number(v2) -> Number(v3)                 | Multiplies `v1` with `v2`.                                                                |
| Divide             | 08              |          | Number(v1), Number(v2) -> Number(v3)                 | Divides `v1` by `v2`.                                                                     |
| BitAnd             | 09              |          | Number(v1), Number(v2) -> Number(v3)                 | Applies bitwise AND operation to `v1` and `v2`.                                           | 
| BitOr              | 0a              |          | Number(v1), Number(v2) -> Number(v3)                 | Applies bitwise OR operation to `v1` and `v2`.                                            |
| BitXor             | 0b              |          | Number(v1), Number(v2) -> Number(v3)                 | Applies bitwise XOR operation to `v1` and `v2`.                                           |  
| BitShiftLeft       | 0c              |          | Number(v1), Number(v2) -> Number(v3)                 | Bitwise shifts `v1`'s bits to the left by `v2`.                                           | 
| BitShiftRight      | 0d              |          | Number(v1), Number(v2) -> Number(v3)                 | Bitwise shifts `v1`'s bits to the right by `v2`.                                          |
| BitNot             | 0e              |          | Number(v1) -> Number(v2)                             | Bitwise inverts all bits of `v1`.                                                         |
| Modulo             | 0f              |          | Number(v1), Number(v2) -> Number(v3)                 | Performs modulo operation on `v1` with `v2`.                                              |
| Equals             | 10              |          | Any(v1), Any(v2) -> Boolean(v3)                      | Pushes `Boolean(true)` onto the stack if `v1` and `v2` are equal.                         |
| NotEquals          | 11              |          | Any(v1), Any(v2) -> Boolean(v3)                      | Pushes `Boolean(false)` onto the stack if `v1` and `v2` are equal                         |
| LessThan           | 12              |          | Number(v1), Number(v2) -> Boolean(v3)                | Checks whether `v1` is smaller than `v2` (`v1` < `v2`).                                   |
| LessThanOrEqual    | 13              |          | Number(v1), Number(v2) -> Boolean(v3)                | Checks whether `v1` is smaller than or equal to `v2` (`v1` <= `v2`).                      |
| GreaterThan        | 14              |          | Number(v1), Number(v2) -> Boolean(v3)                | Checks whether `v1` is greater than `v2` (`v1` > `v2`).                                   |
| GreaterThanOrEqual | 15              |          | Number(v1), Number(v2) -> Boolean(v3)                | Checks whether `v1` is greater than or equal to `v2` (`v1` >= `v2`).                      |
| Negate             | 16              |          | Number(v1) -> Number(v2)                             | Negates `v1` (inverts its sign).                                                          |
| Not                | 17              |          | Boolean(v1) -> Boolean(v2)                           | Inverts `v1` (`Boolean(true)` -> `Boolean(false)` / `Boolean(false)` -> `Boolean(true)`). |
| ConcatString       | 18              |          | String(v1), String(v2) -> String(v3)                 | Concatenates `v1` and `v2` creating a new string.                                         |
| Load               | 19              | index    | -> Any(v)                                            | Loads value of variable at `index` onto the stack.                                        |
| Store              | 11              | index    | Any(v) ->                                            | Stores value of `v1` in variable at `index`.                                              |
| LoadBuiltIn        | 1b              | index    | -> Any(v)                                            | Loads built-in object at index `index` onto the stack.                                    |
| Call               | 1c              | p_count  | Function(v1) -> Any(v2)                              | Calls function `v1` by jumping to its byte index and pushing a new activation record.     |
| Return             | 1d              |          | [no change]                                          | Pops topmost activation record and jumps back to calling byte index.                      |
| Array              | 1e              | length   | Any(v1), Any(v2), ... Any(vlength) -> Array(a)       | Constructs array by popping `length` objects off the stack.                               |
| Hash               | 1f              | length   | String(v1), Any(v2), ... -> Hash(h)                  | Constructs hash by popping `length * 2` objects off the stack.                            |
| LoadIndex          | 20              |          | Any(index), Any(target) -> Any(v)                    | Loads `index` on `target`.                                                                |
| StoreIndex         | 21              |          | Any(v), Any(index), Any(target) ->                   | Load `index` on `target` and sets it to `v`.                                              |

## Notes
Notes must be followed to implement certain behaviors correctly.
- All bitwise operations are applied by converting `Number(n)` to a 32-bit signed integer.
- `Equals` performs a deep comparisons. Different data types are never equal (no automatic conversion).
- `Add`, `Subtract`, `Multiply`, `Divide`, `Modulo`, `GreaterThan`, and `SmallerThan` throw a runtime error if either of the two popped elements is not a number.
- `Negate` throws a runtime error if popped element is neither `1` nor `0`.
- `Not` throws a runtime error if popped element is not a boolean.
- `ConcatString` converts both operands to strings.
