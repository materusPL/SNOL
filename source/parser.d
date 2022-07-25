module parser;
import lexer;
import ast;
import std.stdio;
import std.conv;
import std.string;

class ParseException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
    {
        super(msg, file, line, nextInChain);
    }
}

struct Parser
{
    Lexer lex;
    Token[] tokens = [];
    Expr[] expr = [];

    this(string textToParse)
    {
        lex = Lexer(textToParse);
    }

    Expr parse()
    {
        syntaxSanityCheck();
        buildAST();


        Expr topExpr = null;
        if(expr.length < 1)
            return null;
        foreach (Expr key; expr)
        {
            if (key.masterExpr is null)
            {
                topExpr = key;
                break;
            }
        }
        return topExpr;

    }

    private void syntaxSanityCheck()
    {
        Token currentToken = lex.getNextToken();
        tokens ~= currentToken;
        while (currentToken.type != TOKEN_TYPE.END_OF_TEXT)
        {
            //writeln(currentToken);

            if (currentToken.type == TOKEN_TYPE.PROCEDURE && currentToken.data == "BEG")
            {
                currentToken = lex.getNextToken();
                tokens ~= currentToken;
                if (currentToken.type != TOKEN_TYPE.VARIABLE)
                {
                    throw new ParseException("Unknown command! Does not match any valid command of the language.");
                }

                currentToken = lex.getNextToken();
                tokens ~= currentToken;
                if (currentToken.type != TOKEN_TYPE.END_OF_TEXT)
                {
                    throw new ParseException("Unknown command! Does not match any valid command of the language.");
                }

            }
            if (currentToken.type == TOKEN_TYPE.PROCEDURE && currentToken.data == "EXIT")
            {

                currentToken = lex.getNextToken();
                tokens ~= currentToken;
                if (currentToken.type != TOKEN_TYPE.END_OF_TEXT)
                {
                    throw new ParseException("Unknown command! Does not match any valid command of the language.");
                }

            }
            if (currentToken.type == TOKEN_TYPE.PROCEDURE && currentToken.data == "PRINT")
            {
                currentToken = lex.getNextToken();
                tokens ~= currentToken;
                if (currentToken.type != TOKEN_TYPE.VARIABLE)
                {
                    throw new ParseException("Unknown command! Does not match any valid command of the language.");
                }

                currentToken = lex.getNextToken();
                tokens ~= currentToken;
                if (currentToken.type != TOKEN_TYPE.END_OF_TEXT)
                {
                    throw new ParseException("Unknown command! Does not match any valid command of the language.");
                }

            }
            else if (currentToken.type == TOKEN_TYPE.OPERATOR)
            {

                if (currentToken.data == "=")
                {

                    if ((tokens.length > 1 || tokens.length == 0) && tokens[0].type != TOKEN_TYPE
                        .VARIABLE)
                    {
                        throw new ParseException("Unknown command! Does not match any valid command of the language.");
                    }
                    currentToken = lex.getNextToken();
                    tokens ~= currentToken;

                }
                else if (currentToken.data == "-")
                {

                    currentToken = lex.getNextToken();
                    tokens ~= currentToken;
                    if (currentToken.type != TOKEN_TYPE.VARIABLE && currentToken.type != TOKEN_TYPE.INTEGER && currentToken
                        .type != TOKEN_TYPE.FLOAT)
                        throw new ParseException("Unknown command! Does not match any valid command of the language.");
                    if (tokens.length <= 2 || (tokens[$ - 3].type != TOKEN_TYPE.VARIABLE && tokens[$ - 3].type != TOKEN_TYPE
                            .INTEGER && tokens[$ - 3].type != TOKEN_TYPE.FLOAT))
                    {
                        tokens[$ - 2].data = 'u' ~ tokens[$ - 2].data;
                    }
                }
                else if (currentToken.data == "+")
                {

                    currentToken = lex.getNextToken();
                    tokens ~= currentToken;
                    if (currentToken.type != TOKEN_TYPE.VARIABLE && currentToken.type != TOKEN_TYPE.INTEGER && currentToken
                        .type != TOKEN_TYPE.FLOAT)
                        throw new ParseException("Unknown command! Does not match any valid command of the language.");
                    if (tokens.length <= 2 || (tokens[$ - 3].type != TOKEN_TYPE.VARIABLE && tokens[$ - 3].type != TOKEN_TYPE
                            .INTEGER && tokens[$ - 3].type != TOKEN_TYPE.FLOAT))
                    {
                        tokens[$ - 2].data = 'u' ~ tokens[$ - 2].data;
                    }

                }
                else
                {
                    if (tokens[$ - 2].type != TOKEN_TYPE.VARIABLE && tokens[$ - 2].type != TOKEN_TYPE.INTEGER && tokens[$ - 2]
                        .type != TOKEN_TYPE.FLOAT)
                        throw new ParseException(
                            "Unknown command! Does not match any valid");
                    currentToken = lex.getNextToken();
                    tokens ~= currentToken;
                    /*if(currentToken.type!=TOKEN_TYPE.VARIABLE && currentToken.type!=TOKEN_TYPE.INTEGER && currentToken.type!=TOKEN_TYPE.FLOAT)
                        throw new ParseException("Wrong usage of '"~tokens[$-1].data~"' operator");*/
                }

            }

            else if (currentToken.type == TOKEN_TYPE.FLOAT || currentToken.type == TOKEN_TYPE.INTEGER || currentToken
                .type == TOKEN_TYPE.VARIABLE)
            {
                currentToken = lex.getNextToken();
                tokens ~= currentToken;
                if (currentToken.type != TOKEN_TYPE.OPERATOR && currentToken.type != TOKEN_TYPE
                    .END_OF_TEXT)
                {

                    throw new ParseException("Unknown command! Does not match any valid command of the language.");
                }

            }
            else if( currentToken.type == TOKEN_TYPE.UNKNOWN)
            {
                throw new ParseException("Unexpected token: " ~ currentToken.data);
            }
            else
            {

                currentToken = lex.getNextToken();
                tokens ~= currentToken;
            }
        }

    }

    private void opMaker(int id)
    {
        OpExpr opExpr = cast(OpExpr) expr[id];
        if (!opExpr.unary)
        {
            Expr leftExpr = expr[id - 1];
            while (leftExpr.masterExpr !is null)
            {
                leftExpr = leftExpr.masterExpr;
            }
            leftExpr.masterExpr = opExpr;
            opExpr.LHE = leftExpr;
        }

        Expr rightExpr = expr[id + 1];
        while (rightExpr.masterExpr !is null)
        {
            rightExpr = rightExpr.masterExpr;
        }
        rightExpr.masterExpr = opExpr;
        opExpr.RHE = rightExpr;
    }

    private void buildAST()
    {
        for (int i = 0; i < tokens.length; i++)
        {
            if (tokens[i].type == TOKEN_TYPE.END_OF_TEXT)
                break;
            else if (tokens[i].type == TOKEN_TYPE.FLOAT)
                expr ~= new FloatExpr(to!float(tokens[i].data));
            else if (tokens[i].type == TOKEN_TYPE.INTEGER)
                expr ~= new IntExpr(to!int(tokens[i].data));
            else if (tokens[i].type == TOKEN_TYPE.OPERATOR && tokens[i].data[0] == 'u')
                expr ~= new OpExpr(to!char(tokens[i].data[1]), true);
            else if (tokens[i].type == TOKEN_TYPE.OPERATOR)
                expr ~= new OpExpr(to!char(tokens[i].data));
            else if (tokens[i].type == TOKEN_TYPE.VARIABLE)
                expr ~= new VarExpr(to!string(tokens[i].data));
            else if (tokens[i].type == TOKEN_TYPE.PROCEDURE && tokens[i].data == "BEG")
                expr ~= new BEGExpr();
            else if (tokens[i].type == TOKEN_TYPE.PROCEDURE && tokens[i].data == "PRINT")
                expr ~= new PRINTExpr();
            else if (tokens[i].type == TOKEN_TYPE.PROCEDURE && tokens[i].data == "EXIT")
                expr ~= new EXITExpr();

        }
        if(expr.length < 1)
            return;

        for (int i = 0; i < expr.length; i++) // unary
        {
            if (typeid(expr[i]) == typeid(OpExpr) && (cast(OpExpr) expr[i]).unary)
            {
                opMaker(i);
            }

        }

        for (int i = 0; i < expr.length; i++) // * / %
        {
            if (typeid(expr[i]) == typeid(OpExpr) && indexOf("*/%", (cast(OpExpr) expr[i]).op) > -1 && !(
                    cast(OpExpr) expr[i]).unary)
            {
                opMaker(i);
            }

        }
        for (int i = 0; i < expr.length; i++) // + -
        {
            if (typeid(expr[i]) == typeid(OpExpr) && indexOf("+-", (cast(OpExpr) expr[i]).op) > -1 && !(
                    cast(OpExpr) expr[i]).unary)
            {
                opMaker(i);
            }

        }
        for (int i = 0; i < expr.length; i++) // =
        {
            if (typeid(expr[i]) == typeid(OpExpr) && indexOf("=", (cast(OpExpr) expr[i]).op) > -1 && !(
                    cast(OpExpr) expr[i]).unary)
            {
                opMaker(i);
            }

        }

        //PROCEDURES expr
        if (typeid(expr[0]) == typeid(BEGExpr))
        {
            BEGExpr begExpr = (cast(BEGExpr) expr[0]);
            VarExpr rightExpr = cast(VarExpr) expr[1];
            rightExpr.masterExpr = begExpr;
            begExpr.RHE = rightExpr;
        }
        else if (typeid(expr[0]) == typeid(PRINTExpr))
        {
            PRINTExpr printExpr = (cast(PRINTExpr) expr[0]);
            VarExpr rightExpr = cast(VarExpr) expr[1];
            rightExpr.masterExpr = printExpr;
            printExpr.RHE = rightExpr;
        }

    }

}
