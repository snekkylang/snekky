package code;

class OpCode {
    public static inline final Constant = 0;
    public static inline final Pop = 1;
    
    public static inline final Jump = 2;
    public static inline final JumpNot = 3;

    public static inline final Add = 4;
    public static inline final Subtract = 5;
    public static inline final Multiply = 6;
    public static inline final Divide = 7;
    public static inline final Modulo = 8;
    public static inline final ConcatString = 9;
    public static inline final Equals = 10;
    public static inline final SmallerThan = 11;
    public static inline final GreaterThan = 12;
    public static inline final Negate = 13;
    public static inline final Invert = 14;

    public static inline final SetLocal = 15;
    public static inline final GetLocal = 16;
    public static inline final GetBuiltIn = 17;

    public static inline final Call = 18;
    public static inline final Return = 19;

    public static inline final Array = 20;
    public static inline final Hash = 21;
    public static inline final Index = 22;
    public static inline final Assign = 23;
}