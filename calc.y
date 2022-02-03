%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}

%union{
  int int_val;
  char* op_val;
}

%start input

%right ASSIGN

%left EQ
%left PLUS
%left SUB
%left MULT
%left DIV
%left L_PAREN R_PAREN
%left SEMICOLON
%left COLON
%left LT
%left LTE
%left GT
%left GTE
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left MOD
%left NEQ

%token COMMA
%token IF
%token ENDIF
%token WHILE
%token THEN
%token FUNCTION
%token INTEGER
%token READ
%token WRITE
%token ARRAY
%token OF
%token CONTINUE
%token BREAK
%token NOT
%token TRUE
%token FALSE
%token RETURN
%token BEGINLOOP
%token ENDLOOP
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_BODY
%token END_BODY

// %start expr 

%%

expr: L_PAREN expr R_PAREN expr 
    | %empty
;

%%

int main() {
  yyin = stdin;

  do {
    printf("Parse.\n");
    yyparse();
  } while(!feof(yyin));
  printf("Parenthesis are balanced!\n");
  return 0;
}

void yyerror(const char* s) {
  fprintf(stderr, "Parse error: %s. Parenthesis are not balanced!\n", s);
  exit(1);
}

