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
    public static inline final Equals = 9;
    public static inline final SmallerThan = 10;
    public static inline final GreaterThan = 11;
    public static inline final Negate = 12;
    public static inline final Invert = 13;
    public static inline final ConcatString = 14;

    public static inline final SetLocal = 15;
    public static inline final GetLocal = 16;
    public static inline final GetBuiltIn = 17;

    public static inline final Call = 18;
    public static inline final Return = 19;

    public static inline final Array = 20;
    public static inline final Hash = 21;
    public static inline final GetIndex = 22;
    public static inline final SetIndex = 23;
}