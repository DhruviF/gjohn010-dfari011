    /* cs152-miniL phase2 */
%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>

 // new includes below
#include <string>
#include <vector>
#include <string.h>
#include <sstream>
#include <iostream>
#include <fstream>
#include "CodeNode.h"

void yyerror(const char *s);
extern int line_count;
extern char* yytext;
extern FILE * yyin;

// the code added below is from lab 3

extern int yylex(void);
char *identToken;
int numberToken;
int count_names = 0;

enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;
std::stringstream out;

std::string gen_temp() {
  static int count = 0;
  return "__temp__" + std ::to_string(count++);
}

Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");

} 

%}

%union{
  /* put your types here */
  char* ident_val;
  int num_val;
  struct CodeNode *code_node;
}

%error-verbose
  /* %locations */
%start Program

%token <ident_val> IDENT
%token <num_val> NUMBER

%left EQ
%left ASSIGN
%left PLUS
%left SUB
%left MULT
%left DIV

%token L_PAREN
%token R_PAREN
%token SEMICOLON 
%token COLON
%left LT
%left LTE
%left GT
%left GTE
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET

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
%right NOT
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
%token ELSE
%token DO

%type <code_node> Function
%type <code_node> Functions
%type <code_node> Declaration
%type <code_node> Declaration_Loop
%type <code_node> Statement
%type <code_node> Statement_Loop
%type <code_node> Var
// %type <ident_val> Var

%type <ident_val> Ident
%type <ident_val> Ident_Loop

/* %start program */

%% 

  /* write your rules here */
  Program: Functions 
		{
      CodeNode *node = $1;
      printf("%s\n", node->code.c_str());
    };

Functions: Function Functions {
  CodeNode *code_node1 = $1;
  CodeNode *code_node2 = $2;

  CodeNode *node = new CodeNode;
  node->code = code_node1->code + code_node2->code;
  $$ = node;
}
    | %empty {
      CodeNode *node = new CodeNode;
      $$ = node;
}

Function: FUNCTION Ident SEMICOLON BEGIN_PARAMS Declaration_Loop END_PARAMS BEGIN_LOCALS Declaration_Loop END_LOCALS BEGIN_BODY Statement_Loop END_BODY
{
  CodeNode *node = new CodeNode;
  std::string func_name = $2;
  node->code = "";
  node->code += std::string("func") + func_name + std::string("\n");
  // declare the declarations
  CodeNode *params = $5;
  node->code += params->code;

  // declare the local variables
  CodeNode *locals = $8;
  node->code += locals->code;

  // add the statements
  CodeNode *statements =  $11;
  node->code += statements->code;

  node->code += std::string("endfunc\n");

  $$ = node;
}
;

Declaration: Ident_Loop COLON INTEGER
  {
    // printf("Declaration: %s\n", $1);
    std::string id = $1;
    CodeNode *node = new CodeNode;
    node->code = std::string(". ") + id + std::string("\n");
    $$ = node;


  }
    | Ident_Loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
  {printf("Declaration -> Ident_Loop COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER;\n");}
;

Declaration_Loop: %empty
  {
    CodeNode *node = new CodeNode;
    $$ = node;  // empty
  }
    | Declaration SEMICOLON Declaration_Loop
  {
    CodeNode *code_node1 = $1;
    CodeNode *code_node2 = $3;

    CodeNode *node = new CodeNode;
    node->code = code_node1->code + code_node2->code;
    $$ = node;
    }
;

Ident_Loop: Ident
  {printf("Ident_Loop -> Ident \n");}
    | Ident COMMA Ident_Loop
  {printf("Ident_Loop -> Ident COMMA Ident_Loop\n");}

Ident:  IDENT
  {
    printf("Ident -> IDENT %s \n", $1);
    $$ = $1;
  }

Statement_Loop: Statement SEMICOLON Statement_Loop
  {
  CodeNode *code_node1 = $1;
  CodeNode *code_node2 = $3;

  CodeNode *node = new CodeNode;
  node->code = code_node1->code + code_node2->code;
  $$ = node;  
  }
          | %empty {
            CodeNode *node = new CodeNode;
            $$ = node; 
          }
    | Statement SEMICOLON
  {printf("Statement_Loop -> Statement SEMICOLON\n");}
;

Statement: Ident ASSIGN Expression
  {
    CodeNode *node = new CodeNode;
    std::string id = $1;
    node->code = "";      //hard coded: expression.name
    node->code = std::string("= ") + id + std::string(", 150\n");
    $$ = node;
  }
    | Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET ASSIGN Expression 
  {

  }
    | IF BoolExp THEN Statement_Loop ElseStatement ENDIF
  {
    printf("Statement -> IF BoolExp THEN Statement_Loop ElseStatement ENDIF\n");
  }		 
    | WHILE BoolExp BEGINLOOP Statement_Loop ENDLOOP
	{
    printf("Statement -> WHILE BoolExp BEGINLOOP Statement_Loop ENDLOOP\n");
  }
    | DO BEGINLOOP Statement_Loop ENDLOOP WHILE BoolExp
	{
    printf("Statement -> DO BEGINLOOP Statement_Loop ENDLOOP WHILE BoolExp\n");
  }
    | READ Var
	{
    printf("Statement -> READ Var\n");
  }
    | WRITE Var
  {
      // CodeNode *node = new CodeNode;
      // std::string var = "n";  //var.name
      // node->code = ".> n\n";
      // $$ = node;

      CodeNode *node = new CodeNode;
      CodeNode *var = $2;
      std::string id = var->name;
      node->code = "";
      node->code += std::string(".> ") + id + std::string("\n");
      $$ = node;
  }
    | CONTINUE
	{
    printf("Statement -> CONTINUE\n");
  }
    | BREAK
	{
    printf("Statement -> BREAK\n");
  }
    | RETURN Expression
	{
    printf("Statement -> RETURN Expression\n");
  }
;

ElseStatement:  %empty
  {printf("ElseStatement -> epsilon\n");}
    | ELSE Statement_Loop
	{printf("ElseStatement -> ELSE Statement_Loop\n");}
;

BoolExp:  NOT BoolExpression
  {printf("bool_exp -> NOT bool_exp\n");}
    | BoolExpression
  {printf("bool_exp -> bool_exp1\n");}

;
BoolExpression: Expression Comp Expression
  {printf("bool_exp -> Expression Comp Expression\n");}
    | TRUE
  {printf("bool_exp  -> TRUE\n");}
    | FALSE
  {printf("bool_exp  -> FALSE\n");}
    | L_PAREN BoolExp R_PAREN
  {printf("bool_exp  -> L_PAREN BoolExp R_PAREN\n");}
;

Comp: EQ
  {printf("comp -> EQ\n");}
    | NEQ
  {printf("comp -> NEQ\n");}
    | LT
  {printf("comp -> LT\n");}
    | GT
  {printf("comp -> GT\n");}
    | LTE
  {printf("comp -> LTE\n");}
    | GTE
  {printf("comp -> GTE\n");}
;

Expression: Mult_Expr
  {printf("Expression -> Mult_Expr\n");}
    | Mult_Expr PLUS Expression
  {printf("Expression -> Mult_Expr PLUS Expression\n");}
    | Mult_Expr SUB Expression
	{printf("Expression -> Mult_Expr SUB Expression\n");}
;

Expression_Loop:  %empty
  {printf("Expression_Loop -> epsilon\n");}
    | Expression COMMA Expression_Loop
  {printf("Expression_Loop -> Expression COMMA Expression_Loop\n");}
    | Expression
  {printf("Expression_Loop -> Expression\n");}
;

Mult_Expr:  Term
  {printf("Mult_Expr -> Term\n");}
    | Term MULT Mult_Expr
  {printf("Mult_Expr -> Term MULT Mult_Expr\n");}
  | Term DIV Mult_Expr
	{printf("Mult_Expr -> Term DIV Mult_Expr\n");}
    | Term MOD Mult_Expr
  {printf("Mult_Expr -> Term MOD Mult_Expr\n");}
;

Term: Var
  {printf("Term -> Var\n");}
    | NUMBER
  {printf("Term -> NUMBER\n");}
    | L_PAREN Expression R_PAREN
  {printf("Term -> L_PAREN Expression R_PAREN\n");}
    | Ident L_PAREN Expression_Loop R_PAREN
  {printf("Term -> Ident L_PAREN Expression_Loop R_PAREN\n");}
;

Var:  Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
  {printf("Var -> Ident  L_SQUARE_BRACKET Expression R_SQUARE_BRACKET\n");}
    | Ident
  {printf("Var -> Ident \n");}
;

%% 

/* int main(int argc, char **argv) {
   yyparse();
   return 0;
}  */

void yyerror(const char *s) {
    /* implement your error handling */
    printf("ERROR: %s at symbol \"%s\" on line %d\n", s, yytext, line_count);
    exit(1);
}

  int main(int argc, char* argv[]) {
    if (argc == 2) {
      yyin = fopen(argv[1], "r");
      if (yyin == 0) {
          printf("Error opening file: %s\n", argv[1]);
          exit(1);
      }
    } else {
      yyin = stdin;
    }

    // yyparse();
    yyparse();
    print_symbol_table();
    std::ofstream file("out.mil");
    file << out.str() << std::endl;
    return 0;
    
  
    return 0;
  }  
