module runtimedata;


enum DEBUG = true;

class RunException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, file, line, nextInChain);
    }
}


enum DATA_TYPE
{
    FLOAT,
    INTEGER,
    VAR_POINTER,
    NONE
}
enum EVAL_TYPE
{
    NUMBER,
    UNDEFINED_VAR,
    VAR,
    PRINT,
    BEG,
    ASSIGN,
    EXIT
}

struct EvalReturn
{
    this(EVAL_TYPE type,DATA_TYPE dataType, float fVal )
    {
        this.type=type;
        this.dataType = dataType;
        this.fVal = fVal;
    }
    this(EVAL_TYPE type,DATA_TYPE dataType, int iVal)
    {
        this.type=type;
        this.dataType = dataType;
        this.iVal = iVal;
  
    }
    this(EVAL_TYPE type,DATA_TYPE dataType, string sVar)
    {
        this.type=type;
        this.dataType = dataType;
        this.sVar = sVar;
  
    }
    
    EVAL_TYPE type;
    DATA_TYPE dataType;
    union
    {
        float fVal;
        int iVal;
        string sVar;
    }

}

struct Variable
{
    DATA_TYPE dataType;
    union
    {
        float fVal;
        int iVal;
    }
    
}