/* cs152-miniL phase1 */

%{ 
   /* write your C code here for definitions of variables and including headers */
%}

   /* some common rules */
DIGIT	 [0-9]
CHAR     [a-zA-Z]
/*UNDER	 [_]*/
/*IDENT  CHAR(CHAR|DIGIT|UNDER)*CHAR*/
IDENT	 [a-zA-z][a-zA-Z0-9_]*


%%
   /* specific lexer rules in regex */

"="		     {printf("EQUAL\n");}
":="                 {printf("ASSIGN\n");}
"+"		     {printf("PLUS\n");}
"-"		     {printf("SUB\n");}
"*"		     {printf("MULT\n");}
"/"		     {printf("DIV\n");}
"("		     {printf("L_PAREN\n");}
")"		     {printf("R_PAREN\n");}
";"		     {printf("SEMICOLON\n");}
":"    	             {printf("COLON\n");}
"<"		     {printf("LT\n");}
"<="		     {printf("LTE\n");}
">"		     {printf("GT\n");}
">="		     {printf("GTE\n");}
"["                  {printf("L_SQUARE_BRACKET\n");}
"]"                  {printf("R_SQUARE_BRACKET\n");}

"if"                {printf("IF\n");}
"endif"             {printf("ENDIF\n");}
"while"             {printf("WHILE\n");}
"then"              {printf("THEN\n");}
"function"          {printf("FUNCTION\n");}
"integer"           {printf("INTEGER\n");}
"read"              {printf("READ\n");}
"write"             {printf("WRITE\n");}
"array"             {printf("ARRAY\n");}
"of"                {printf("OF\n");}

"beginloop"         {printf("BEGINLOOP\n");}
"endloop"           {printf("ENDLOOP\n");}
"beginlocals"       {printf("BEGIN_LOCALS\n");}
"endlocals"         {printf("END_LOCALS\n");}
"beginparams"       {printf("BEGIN_PARAMS\n");}
"endparams"         {printf("END_PARAMS\n");}
"beginbody"         {printf("BEGIN_BODY\n");}
"endbody"           {printf("END_BODY\n");}

{DIGIT}+	    {printf("NUMBER %s\n", yytext);}
{IDENT}		    {printf("IDENT %s\n", yytext);}
[ \t\n]+ 	    /* {printf("WHITESPACE");}*/
. 		    {printf("ERROR %s\n", yytext); exit(0);}

%%
        /* C functions used in lexer */

int main(int argc, char ** argv)
{
	yyin = fopen(argv[1], "r");   
	yylex();
	fclose(yyin);
}
