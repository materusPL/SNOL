import std.stdio;
import ast;
import parser;
import runtimedata;

void main()
{

    Parser par;
    EvalReturn ret;
    Expr expr;

    Variable[string] varStack;
    writeln("The SNOL environment is now active, you may proceed with giving your commands.");
    do
    {
        write("Command: ");
        try
        {
            par = Parser(readln());
            expr = par.parse();
            if (expr !is null)
            {

                ret = expr.evaluate(varStack);
            }
        }
        catch(ParseException e)
        {
            writeln(e.msg);
        }
        catch(RunException e)
        {
            writeln(e.msg);
        }

    }
    while (ret.type != EVAL_TYPE.EXIT);
    writeln("Interpreter is now terminated...");

}
