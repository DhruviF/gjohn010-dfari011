   /* cs152-miniL phase1 */
   
%{   
   /* write your C code here for definitions of variables and including headers */
   #include "y.tab.h"
   int line_count = 1, space_count = 0;
   extern char *identToken;
   extern int numberToken;
%}

   /* some common rules */
DIGIT	 	         [0-9]
CHAR     	      [a-zA-Z]
CHARORUNDER       [a-zA-Z_]
DIGITORCHAR 	   [0-9a-zA-Z]
WHITESPACE        [\t ]
NEWLINE           [\n]
UNDER	 	         [_]  
IDENT	 	         [a-zA-Z][a-zA-Z0-9_]*
COMMENTS 	      [#][#][\?,=<>;/:\(\)\[\].a-zA-Z0-9_\t ]*

%% 
"=="		     return EQ; space_count+=2;
":="          return ASSIGN; space_count+=2;
"+"		     return PLUS; space_count++;
"-"		     return SUB; space_count++;
"*"		     return MULT; space_count++;

"/"		     return DIV; space_count++;
"("		     return L_PAREN; space_count++;
")"		     return R_PAREN; space_count++;
";"           return SEMICOLON; space_count++; 
":"    	     return COLON; space_count++;

"<"		     return LT; space_count++;
"<="		     return LTE; space_count+=2;
">"		     return GT; space_count++; 
">="		     return GTE; space_count+=2;
"["           return L_SQUARE_BRACKET; space_count++;

"]"               return R_SQUARE_BRACKET; space_count++;
"##".*{NEWLINE}   space_count = 0; ++line_count;
{WHITESPACE}+     space_count += yyleng;
{NEWLINE}+        line_count += yyleng; space_count = 0;  
"%"		         return MOD; space_count++;
"<>"		         return NEQ; space_count+=2;

","		      return COMMA; space_count++;
"if"           return IF; space_count += yyleng;
"endif"        return ENDIF; space_count += yyleng;

"while"        return WHILE; space_count += yyleng;
"then"         return THEN; space_count += yyleng;
"function"     return FUNCTION; space_count += yyleng;
"integer"      return INTEGER; space_count += yyleng;
"read"         return READ; space_count += yyleng;

"write"        return WRITE; space_count += yyleng;
"array"        return ARRAY; space_count += yyleng;
"of"           return OF; space_count += yyleng;
"continue"     return CONTINUE; space_count += yyleng;
"break"        return BREAK; space_count += yyleng;

"not"          return NOT; space_count += yyleng;
"true"         return TRUE; space_count += yyleng;
"false"        return FALSE; space_count += yyleng;
"return"       return RETURN; space_count += yyleng;

"beginloop"    return BEGINLOOP; space_count += yyleng;
"endloop"      return ENDLOOP; space_count += yyleng;
"beginlocals"  return BEGIN_LOCALS; space_count += yyleng;
"endlocals"    return END_LOCALS; space_count += yyleng;
"beginparams"  return BEGIN_PARAMS; space_count += yyleng;
"endparams"    return END_PARAMS;  space_count += yyleng;
"beginbody"    return BEGIN_BODY; space_count += yyleng;
"endbody"      return END_BODY; space_count += yyleng;
"else"         return ELSE; space_count += yyleng;
"do"           return DO; space_count += yyleng;

{DIGIT}+ {
  space_count += yyleng; 
  char * token = new char[yyleng];
  strcpy(token, yytext);
  yylval.ident_val = token;
  numberToken = atoi(yytext); 
  return NUMBER;
}

({CHAR})|({CHAR}({CHAR}|{DIGIT}|"_")*({CHAR}|{DIGIT})) {
   space_count += yyleng;
   char * token = new char[yyleng];
   strcpy(token, yytext);
   yylval.ident_val = token;
   identToken = yytext; 
   return IDENT;
}

{DIGIT}+    { return NUMBER; space_count = space_count + yyleng; yylval.num_val = atoi(yytext);}
({UNDER}+{IDENT})	   	   {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line_count, space_count, yytext); exit(0);}
({DIGIT}+{IDENT})          {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line_count, space_count, yytext); exit(0);}
({DIGITORCHAR}*{UNDER})    {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", line_count, space_count, yytext); exit(0);}
. 		    		            {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", line_count, space_count, yytext); exit(0);}

%%
   