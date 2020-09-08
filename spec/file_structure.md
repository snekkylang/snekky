# File Structure
###### Last updated 2020-09-08
This document describes the structure of a Snekky bytecode file.

**Table of Contents**

- [Syntax Definition](#syntax-definition)
- [Bytecode Structure](#bytecode-structure)
    - [LinerNumberTable](#linenumbertable)
    - [LocalVariableTable](#localvariabletable)
    - [ConstantPool](#constantpool)
        - [Float](#float)
        - [String](#string)
        - [Function](#function)


### Syntax Definition
A JSON-like representation is utilized to visualize the structure of the bytecode. The symbols used for this purpose are defined as follows:
| Symbol | Definition                                                                                                                         |
|--------|------------------------------------------------------------------------------------------------------------------------------------|
| {...}  | Curly braces are used to define an autonomous structure. It usually fulfils one specific function.                                 |
| [...]  | Definitions in square brackets may be repeated as a whole. The order of the definitions within the brackets must remain unchanged. |
| (...)  | Represents exactly one of the definitions inside; depending on the context.                                                        |
| <...>  | Angle brackets represent the structure with the name they contain.                                                                 |
| i32    | A 32-bit signed integer (little endian).                                                                                           |
| f64    | A 64-bit float (little endian).                                                                                                    |
| byt    | The signed integer value of a single byte.                                                                                         |
| str    | An UTF-8 encoded string.                                                                                                           |

### Bytecode Structure
The Snekky compiler compiles the entire program, which could consist of several source files (`.snek` extension), into a single file containing the entire bytecode (`.bite` extension). Litte endian byte order is used throughout the entire bytecode. Bytecode files are structured as follows:
```
Bytecode File {
    <LineNumberTable>
    <LocalVariableTable>
    <ConstantPool>
    <Instructions>
}
```

#### LineNumberTable
The LineNumberTable maps the position of an instruction in bytecode (the index) to the position in source code of the structure responsible for it. The LineNumberTable is structured as follows:
```
LineNumberTable {
    i32 table_size
    [
        i32 byte_index
        i32 source_line
        i32 source_line_offset 
    ]
}
```
| Field name         | Data type | Description                                         |
|--------------------|-----------|-----------------------------------------------------|
| table_size         | i32       | The length of the table.                            |
| byte_index         | i32       | Position of an instruction in bytcode (its index).  |
| source_line        | i32       | Line in source code.                                |
| source_line_offset | i32       | Offset within the line in source code.              |

#### LocalVariableTable
The LocalVariableTable maps the position where a variable is declared in bytecode (the index) to its name in source code. The LocalVariableTable is structured as follows
```
LocalVariableTable {
    i32 table_size
    [
        i32 byte_index
        i32 variable_name_length
        str variable_name
    ]
}
```
| Field name           | Data type | Description                                                  |
|----------------------|-----------|--------------------------------------------------------------|
| table_size           | i32       | The length of the table.                                     |
| byte_index           | i32       | Position where the variable was set in bytecode (its index). |
| variable_name_length | i32       | Length of the variable name (in bytes)                       |
| variable_name        | str       | Name of the variable in source code.                         |

#### ConstantPool
The ConstantPool contains all constants present in the source code. A constant's value cannot change at runtime.
```
ConstantPool {
    i32 constants_size
    [
        <Constant>
    ]
}
```
| Field name     | Data type | Description              |
|----------------|-----------|--------------------------|
| constants_size | i32       | The amount of constants. |

The structure of `Constant` depends on the data type of the value it contains. The following types exist:
```
Constant {
    byt data_type
    (
        <FloatConstant>
        <StringConstant>
        <FunctionConstant>
    )
}
```
| Field name | Data type | Description                        |
|------------|-----------|------------------------------------|
| data_type  | byt       | Data type of the constant's value. |

Data types are mapped as follows:
| data_type | Represented data type |
|-----------|-----------------------|
| 0         | Float                 |
| 1         | String                |
| 2         | Function              |

##### Float
Snekky uses 64-bit floats to represent all numbers and booleans.
```
FloatConstant {
    f64 value
}
```
| Field name | Data type | Description            |
|------------|-----------|------------------------|
| value      | f64       | Value of the constant. |


##### String
Strings are encoded in UTF-8.
```
StringConstant {
    i32 string_length
    str string
}
```
| Field name    | Data type | Description                              |
|---------------|-----------|------------------------------------------|
| string_length | i32       | Length of the encoded string (in bytes). |
| string        | str       | Value of the constant.                   |

#### Function
```
FunctionConstant {
    i32 byte_index
}
```
| Field name | Data type | Description                                       |
|------------|-----------|---------------------------------------------------|
| byte_index | i32       | Position of the function in bytecode (its index). |