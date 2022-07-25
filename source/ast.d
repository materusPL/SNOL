module ast;
import std.stdio;
import runtimedata;
import std.string;
import std.conv;

abstract class Expr
{

    Expr masterExpr = null;

    EvalReturn evaluate(ref Variable[string] varStack);

}

class FloatExpr : Expr
{
    this(float val)
    {
        value = val;
    }

    float value;

    override EvalReturn evaluate(ref Variable[string] varStack)
    {

        return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.FLOAT, value);
    }
}

class IntExpr : Expr
{
    this(int val)
    {
        value = val;
    }

    int value;

    override EvalReturn evaluate(ref Variable[string] varStack)
    {
        return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.INTEGER, value);
    }
}

class VarExpr : Expr
{
    this(string var)
    {
        varName = var;
    }

    string varName;

    override EvalReturn evaluate(ref Variable[string] varStack)
    {
        const Variable* varPtr = (varName in varStack);
        if (varPtr is null)
        {
            return EvalReturn(EVAL_TYPE.UNDEFINED_VAR, DATA_TYPE.NONE, varName);
        }
        else
        {
            return EvalReturn(EVAL_TYPE.VAR, DATA_TYPE.VAR_POINTER, varName);
        }

    }
}

class OpExpr : Expr
{
    this(char op, bool unary = false)
    {
        this.op = op;
        this.unary = unary;

    }

    bool unary;
    char op;
    Expr RHE;
    Expr LHE;

    override EvalReturn evaluate(ref Variable[string] varStack)
    {
        EvalReturn left = void;
        if (!unary)
        {
            left = LHE.evaluate(varStack);
        }

        EvalReturn right = RHE.evaluate(varStack);
        if (op == '=') //ASSIGN
        {
            if (right.type == EVAL_TYPE.UNDEFINED_VAR)
                throw new RunException("Error! ["~right.sVar ~ "] is not defined!");
            if (left.type == EVAL_TYPE.UNDEFINED_VAR)
                varStack[left.sVar] = Variable();

            if (right.type == EVAL_TYPE.VAR)
            {
                varStack[left.sVar].dataType = varStack[right.sVar].dataType;
                if (varStack[left.sVar].dataType == DATA_TYPE.INTEGER)
                    varStack[left.sVar].iVal = varStack[right.sVar].iVal;
                else
                    varStack[left.sVar].fVal = varStack[right.sVar].fVal;
            }
            else
            {
                if (right.dataType == DATA_TYPE.INTEGER)
                {
                    varStack[left.sVar].iVal = right.iVal;
                    varStack[left.sVar].dataType = right.dataType;
                }
                else if (right.dataType == DATA_TYPE.FLOAT)
                {
                    varStack[left.sVar].fVal = right.fVal;
                    varStack[left.sVar].dataType = right.dataType;
                }
            }
            return EvalReturn(EVAL_TYPE.ASSIGN, DATA_TYPE.NONE, 0);

        }
        else if (op == '-' && unary) //UNARY -
        {
            if (right.type == EVAL_TYPE.UNDEFINED_VAR)
                throw new RunException("Error! ["~right.sVar ~ "] is not defined!");
            if (right.type == EVAL_TYPE.VAR)
            {
                if (varStack[right.sVar].dataType == DATA_TYPE.INTEGER)
                {
                    return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.INTEGER, -varStack[right.sVar]
                            .iVal);
                }
                else if (varStack[right.sVar].dataType == DATA_TYPE.FLOAT)
                {
                    return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.FLOAT, -varStack[right.sVar].fVal);
                }
            }
            else if (right.type == EVAL_TYPE.NUMBER)
            {
                if (right.dataType == DATA_TYPE.INTEGER)
                    return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.INTEGER, -right.iVal);
                else if (right.dataType == DATA_TYPE.FLOAT)
                    return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.FLOAT, -right.fVal);

            }

        }
        else if (op == '+' && unary) //UNARY +
        {
            if (right.type == EVAL_TYPE.UNDEFINED_VAR)
                throw new RunException("Error! ["~right.sVar ~ "] is not defined!");
            if (right.type == EVAL_TYPE.VAR)
            {
                if (varStack[right.sVar].dataType == DATA_TYPE.INTEGER)
                {
                    return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.INTEGER, varStack[right.sVar]
                            .iVal);
                }
                else if (varStack[right.sVar].dataType == DATA_TYPE.FLOAT)
                {
                    return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.FLOAT, varStack[right.sVar].fVal);
                }
            }
            else if (right.type == EVAL_TYPE.NUMBER)
            {
                if (right.dataType == DATA_TYPE.INTEGER)
                    return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.INTEGER, right.iVal);
                else if (right.dataType == DATA_TYPE.FLOAT)
                    return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.FLOAT, right.fVal);

            }

        }
        else if (indexOf("*/+-%", op) > -1) // rest
        {
            if (right.type == EVAL_TYPE.UNDEFINED_VAR)
                throw new RunException("Error! ["~ right.sVar ~ "] is not defined!");
            if (left.type == EVAL_TYPE.UNDEFINED_VAR)
                throw new RunException("Error! ["~right.sVar ~ "] is not defined!");

            DATA_TYPE r;
            DATA_TYPE l;



            union Data
            {
                int Int;
                float Float;
            }
            Data leftData,rightData;


            if (right.type == EVAL_TYPE.VAR)
            {
                if (varStack[right.sVar].dataType == DATA_TYPE.INTEGER)
                {
                    r = varStack[right.sVar].dataType;
                    rightData.Int = varStack[right.sVar].iVal;
                }
                else if (varStack[right.sVar].dataType == DATA_TYPE.FLOAT)
                {
                    r = varStack[right.sVar].dataType;
                    rightData.Float = varStack[right.sVar].fVal;
                }
            }
            else if (right.type == EVAL_TYPE.NUMBER)
            {
                if (right.dataType == DATA_TYPE.INTEGER)
                {
                    r = right.dataType;
                    rightData.Int = right.iVal;
                }
                else if (right.dataType == DATA_TYPE.FLOAT)
                {
                    r = right.dataType;
                    rightData.Float = right.fVal;
                }

            }

            if (left.type == EVAL_TYPE.VAR)
            {
                if (varStack[left.sVar].dataType == DATA_TYPE.INTEGER)
                {
                    l = varStack[left.sVar].dataType;
                    leftData.Int = varStack[left.sVar].iVal;
                }
                else if (varStack[left.sVar].dataType == DATA_TYPE.FLOAT)
                {
                    l = varStack[left.sVar].dataType;
                    leftData.Float = varStack[left.sVar].fVal;
                }
            }
            else if (left.type == EVAL_TYPE.NUMBER)
            {
                if (left.dataType == DATA_TYPE.INTEGER)
                {
                    l = right.dataType;
                    leftData.Int = left.iVal;
                }
                else if (left.dataType == DATA_TYPE.FLOAT)
                {
                    l = left.dataType;
                    leftData.Float = left.fVal;
                }

            }

            if (l != r)
                throw new RunException("Error! Operands must be of the same type in an arithmetic operation!");

            if (l == DATA_TYPE.INTEGER)
            {
                switch (op)
                {
                case '+':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Int + rightData.Int);
                case '-':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Int - rightData.Int);
                case '*':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Int * rightData.Int);
                case '/':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Int / rightData.Int);
                case '%':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Int % rightData.Int);
                default: break;
                }
            }
            else {
                
                switch (op)
                {
                case '+':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Float + rightData.Float);
                case '-':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Float - rightData.Float);
                case '*':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Float * rightData.Float);
                case '/':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Float / rightData.Float);
                case '%':
                    return EvalReturn(EVAL_TYPE.NUMBER, l, leftData.Float % rightData.Float);
                default: break;
                }
            }

        }

        return EvalReturn(EVAL_TYPE.NUMBER, DATA_TYPE.NONE, 0);
    }
}

class BEGExpr : Expr
{

    VarExpr RHE;

    override EvalReturn evaluate(ref Variable[string] varStack)
    {

        EvalReturn r = RHE.evaluate(varStack);

        write("Input: ");
        string input = strip(readln());

        if (isNumeric(input))
        {
            if (r.type == EVAL_TYPE.UNDEFINED_VAR)
                varStack[r.sVar] = Variable();
            try
            {
                varStack[r.sVar].iVal = to!int(input);
                varStack[r.sVar].dataType = DATA_TYPE.INTEGER;

            }
            catch (ConvException e)
            {
                varStack[r.sVar].fVal = to!float(input);
                varStack[r.sVar].dataType = DATA_TYPE.FLOAT;
            }
        }
        else
        {
            throw new RunException("Error! Cannot convert input");
        }

        return EvalReturn(EVAL_TYPE.BEG, DATA_TYPE.NONE, 0);
    }
}

class PRINTExpr : Expr
{

    VarExpr RHE;
    override EvalReturn evaluate(ref Variable[string] varStack)
    {
        EvalReturn r = RHE.evaluate(varStack);
        if (r.type == EVAL_TYPE.UNDEFINED_VAR)
        {
            writeln("SNOL> Error! [" ~ r.sVar ~ "] is not defined!");
        }
        else if (r.type == EVAL_TYPE.VAR)
        {
            Variable* v = (r.sVar in varStack);
            if (v.dataType == DATA_TYPE.INTEGER)
                writeln("SNOL> [" ~ r.sVar ~ "] = ", v.iVal);
            else
                writeln("SNOL> [" ~ r.sVar ~ "] = ", v.fVal);

        }

        return EvalReturn(EVAL_TYPE.PRINT, DATA_TYPE.NONE, 0);
    }
}

class EXITExpr : Expr
{
    override EvalReturn evaluate(ref Variable[string] varStack)
    {
        return EvalReturn(EVAL_TYPE.EXIT, DATA_TYPE.NONE, 0);
    }
}
