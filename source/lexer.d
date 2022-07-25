module lexer;
import std.stdio;
import core.stdc.ctype;
import std.string;

enum TOKEN_TYPE
{
    OPERATOR,
    INTEGER,
    FLOAT,
    VARIABLE,
    PROCEDURE,

    UNKNOWN,
    END_OF_TEXT
}

struct Token
{
    TOKEN_TYPE type;
    string data;

}

const string OPERATORS = "=+-*/%";

struct Lexer
{
    long position = 0;
    private string textToTokenize;
    this(string textToTokenize)
    {
        this.textToTokenize = textToTokenize;

    }

    Token getNextToken()
    {
        if (position >= textToTokenize.length)
            return Token(TOKEN_TYPE.END_OF_TEXT, null);
        string dataStr;
        char lastChar = textToTokenize[position];

        while (isspace(lastChar))
        {
            position++;
            if (position >= textToTokenize.length)
                return Token(TOKEN_TYPE.END_OF_TEXT, null);
            lastChar = textToTokenize[position];
        }
        if (isalpha(lastChar))
        {
            dataStr ~= lastChar;
            lastChar = textToTokenize[++position];
            while (isalnum(lastChar))
            {
                dataStr ~= lastChar;
                position++;
                if (position >= textToTokenize.length)
                    break;
                else

                    lastChar = textToTokenize[position];
            }

            if (dataStr == "BEG")
                return Token(TOKEN_TYPE.PROCEDURE, dataStr);

            else if (dataStr == "PRINT")
            {
                return Token(TOKEN_TYPE.PROCEDURE, dataStr);
            }

            else if (dataStr == "EXIT" && lastChar == '!')
            {
                position++;
                return Token(TOKEN_TYPE.PROCEDURE, dataStr);

            }

            else
            {

                return Token(TOKEN_TYPE.VARIABLE, dataStr);
            }

        }
        if (indexOf(OPERATORS, lastChar) > -1)
        {
            dataStr ~= lastChar;
            position++;
            return Token(TOKEN_TYPE.OPERATOR, dataStr);
        }

        if (isdigit(lastChar))
        {
            dataStr ~= lastChar;
            position++;
            if (position >= textToTokenize.length)
                return Token(TOKEN_TYPE.INTEGER, dataStr);
            lastChar = textToTokenize[position];
            while (isdigit(lastChar))
            {
                dataStr ~= lastChar;
                position++;
                if (position >= textToTokenize.length)
                    return Token(TOKEN_TYPE.INTEGER, dataStr);
                lastChar = textToTokenize[position];

            }
            
            if (lastChar == '.')
            {
                dataStr ~= lastChar;
                position++;
                if (position >= textToTokenize.length)
                {
                    position--;
                    return Token(TOKEN_TYPE.INTEGER, dataStr);
                }
                lastChar = textToTokenize[position];
                while (isdigit(lastChar))
                {

                    dataStr ~= lastChar;
                    position++;
                    if (position >= textToTokenize.length)
                        return Token(TOKEN_TYPE.FLOAT, dataStr);
                    lastChar = textToTokenize[position];
                }
                if(dataStr[$-1] == '.')
                { 
                    position--;
                    return Token(TOKEN_TYPE.INTEGER, dataStr[0..$-1]);
                }
                return Token(TOKEN_TYPE.FLOAT, dataStr);

            }
            else
            {
                return Token(TOKEN_TYPE.INTEGER, dataStr);
            }

        }

        dataStr ~= lastChar;
        position++;
        return Token(TOKEN_TYPE.UNKNOWN, dataStr);

    }

}
