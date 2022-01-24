/* cs152-miniL phase1 */

%{ 
   /* write your C code here for definitions of variables and including headers */
int line_count = 1;
int space_count = 1;
%}

   /* some common rules */
DIGIT	 [0-9]
CHAR     [a-zA-Z]
	/* UNDER	 [_] */
	/* IDENT  CHAR(CHAR|DIGIT|UNDER)*CHAR */
IDENT	 [a-zA-Z][a-zA-Z0-9_]*
COMMENTS [#][#][\?,=<>;/:\(\)\[\].a-zA-Z0-9_\t ]*

%%
   /* specific lexer rules in regex */

"=="		     {printf("EQ\n"); space_count++;}
":="                 {printf("ASSIGN\n"); space_count++;}
"+"		     {printf("PLUS\n"); space_count++;}
"-"		     {printf("SUB\n"); space_count++;}
"*"		     {printf("MULT\n"); space_count++;}
"/"		     {printf("DIV\n"); space_count++;}
"("		     {printf("L_PAREN\n"); space_count++;}
")"		     {printf("R_PAREN\n"); space_count++;}
";"		     {printf("SEMICOLON\n"); space_count++;}
":"    	             {printf("COLON\n"); space_count++;}
"<"		     {printf("LT\n"); space_count++;}
"<="		     {printf("LTE\n"); space_count++;}
">"		     {printf("GT\n"); space_count++;} 
">="		     {printf("GTE\n"); space_count++;}
"["                  {printf("L_SQUARE_BRACKET\n"); space_count++;} 
"]"                  {printf("R_SQUARE_BRACKET\n"); space_count++;}
"#"		     
" "                  {space_count++;}
"%"		     {printf("MOD\n"); space_count++;}

"if"                {printf("IF\n"); space_count+=2;}
"endif"             {printf("ENDIF\n"); space_count+=5;}
"while"             {printf("WHILE\n"); space_count+=5;}
"then"              {printf("THEN\n"); space_count+=4;}
"function"          {printf("FUNCTION\n"); space_count+=8;}
"integer"           {printf("INTEGER\n"); space_count+=6;}
"read"              {printf("READ\n"); space_count+=4;}
"write"             {printf("WRITE\n"); space_count+=5;}
"array"             {printf("ARRAY\n"); space_count+=5;}
"of"                {printf("OF\n"); space_count+=2;}

"beginloop"         {printf("BEGINLOOP\n"); space_count+=9;}
"endloop"           {printf("ENDLOOP\n"); space_count+=7;}
"beginlocals"       {printf("BEGIN_LOCALS\n"); space_count+=11;}
"endlocals"         {printf("END_LOCALS\n"); space_count+=9;}
"beginparams"       {printf("BEGIN_PARAMS\n"); space_count+=11;}
"endparams"         {printf("END_PARAMS\n"); space_count+=9;}
"beginbody"         {printf("BEGIN_BODY\n"); space_count+=9;}
"endbody"           {printf("END_BODY\n"); space_count+=7;}

{DIGIT}+	    {printf("NUMBER %s\n", yytext); space_count = space_count + yyleng;}
{IDENT}		    {printf("IDENT %s\n", yytext); space_count = space_count +yyleng;}
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
