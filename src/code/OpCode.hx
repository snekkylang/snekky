package code;

class OpCode {
    public static inline final Constant = 0;
    public static inline final Pop = 1;
    
    public static inline final Jump = 2;
    public static inline final JumpNot = 3;
    public static inline final JumpNotPeek = 4;

    public static inline final Add = 5;
    public static inline final Subtract = 6;
    public static inline final Multiply = 7;
    public static inline final Divide = 8;
    public static inline final Modulo = 9;
    public static inline final Equals = 10;
    public static inline final LessThan = 11;
    public static inline final GreaterThan = 12;
    public static inline final Negate = 13;
    public static inline final Not = 14;
    public static inline final ConcatString = 15;

    public static inline final Load = 16;
    public static inline final Store = 17;
    public static inline final LoadBuiltIn = 18;

    public static inline final Call = 19;
    public static inline final Return = 20;

    public static inline final Array = 21;
    public static inline final Hash = 22;
    public static inline final LoadIndex = 23;
    public static inline final StoreIndex = 24;
}