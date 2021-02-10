package code;

class OpCode {
    public static inline final Constant = 0x00;
    public static inline final Pop = 0x01;
    
    public static inline final Jump = 0x02;
    public static inline final JumpNot = 0x03;
    public static inline final JumpPeek = 0x04;

    public static inline final Add = 0x05;
    public static inline final Subtract = 0x06;
    public static inline final Multiply = 0x07;
    public static inline final Divide = 0x08;
    public static inline final BitAnd = 0x09;
    public static inline final BitOr = 0x0a;
    public static inline final BitXor = 0x0b;
    public static inline final BitShiftLeft = 0x0c;
    public static inline final BitShiftRight = 0x0d;
    public static inline final BitNot = 0x0e;
    public static inline final Modulo = 0x0f;
    public static inline final Equals = 0x10;
    public static inline final LessThan = 0x11;
    public static inline final LessThanOrEqual = 0x12;
    public static inline final GreaterThan = 0x13;
    public static inline final GreaterThanOrEqual = 0x14;
    public static inline final Negate = 0x15;
    public static inline final Not = 0x16;
    public static inline final ConcatString = 0x17;

    public static inline final Load = 0x18;
    public static inline final Store = 0x19;
    public static inline final LoadBuiltIn = 0x1a;

    public static inline final Call = 0x1b;
    public static inline final Return = 0x1c;

    public static inline final Array = 0x1d;
    public static inline final Hash = 0x1e;
    public static inline final LoadIndex = 0x1f;
    public static inline final StoreIndex = 0x20;
}