%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex(void)

#include "calc.tab.h"

/* write your C code here for definitions of variables and including headers */
int line_count = 1;
int space_count = 1;
%}

/* some common rules */
DIGIT	 	[0-9]
CHAR     	[a-zA-Z]
DIGITORCHAR [a-zA-Z0-9]
UNDER	 	[_]
IDENT	 	[a-zA-Z][a-zA-Z0-9_]*
COMMENTS 	[#][#][\?,=<>;/:\(\)\[\].a-zA-Z0-9_\t ]*

%%

"=="		 {space_count++; return EQ; }
":="         {space_count++; return ASSIGN; }
"+"		     {space_count++; return PLUS; }
"-"		     {space_count++; return SUB; }
"*"		     {space_count++; return MULT; }
"/"		     {space_count++; return DIV; }
"("		     {space_count++; return L_PAREN; }
")"		     { space_count++; return R_PAREN; }
";"		     {space_count++; return SEMICOLON; }
":"    	     {space_count++; return COLON; }
"<"		     {space_count++; return LT; }
"<="		 {space_count++; return LTE; }
">"		     {space_count++; return GT; } 
">="		 {space_count++; return GTE; }
"["          {space_count++; return L_SQUARE_BRACKET; } 
"]"          {space_count++; return R_SQUARE_BRACKET; }
"#"		     
" "          {space_count++;}
"%"		     {space_count++; return MOD; }
"<>"		 {space_count++; return NEQ; }
","		     {space_count++; return COMMA; }
"\t"		 {space_count = space_count + yyleng;}
"\n"		 {line_count++; space_count = 1;}

"if"                {space_count+=2; return IF; }
"endif"             {space_count+=5; return ENDIF; }
"while"             {space_count+=5; return WHILE; }
"then"              {space_count+=4; return THEN; }
"function"          {space_count+=8; return FUNCTION; }
"integer"           {space_count+=6; return INTEGER; }
"read"              {space_count+=4; return READ; }
"write"             {space_count+=5; return WRITE; }
"array"             {space_count+=5; return ARRAY; }
"of"                {space_count+=2; return OF; }
"continue"          {space_count+=8; return CONTINUE; }
"break"		        {space_count+=5; return BREAK; }
"not"		        {space_count+=3; return NOT; }
"true"		        {space_count+=4; return TRUE; }
"false"		        {space_count+=5; return FALSE; }
"return"            {space_count+=6; return RETURN; }
"do"                {space_count+=2; return DO; }
"else"              {space_count+=4; return ELSE; }
"and"               {space_count+=3; return AND; }

"beginloop"         {space_count+=9; return BEGINLOOP; }
"endloop"           {space_count+=7; return ENDLOOP; }
"beginlocals"       {space_count+=11; return BEGIN_LOCALS; }
"endlocals"         {space_count+=9; return END_LOCALS; }
"beginparams"       {space_count+=11; return BEGIN_PARAMS; }
"endparams"         {space_count+=9; return END_PARAMS; }
"beginbody"         {space_count+=9; return BEGIN_BODY; }
"endbody"           {space_count+=7; return END_BODY; }

({DIGITORCHAR}*{UNDER})             {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", line_count, space_count, yytext); exit(0);}


{DIGIT}+	                        {space_count = space_count + yyleng;} /* removed return yytext; */
{IDENT}		                        {space_count = space_count + yyleng; }  
{COMMENTS}                          {line_count++; space_count = 1; }


({UNDER}+{IDENT})	            	{printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line_count, space_count, yytext); exit(0);}
({DIGIT}+{IDENT})                   {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line_count, space_count, yytext); exit(0);}
. 		    		                {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", line_count, space_count, yytext); exit(0);}

%%
