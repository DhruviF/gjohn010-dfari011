    /* cs152-miniL phase2 */
%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>
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
%type <code_node> Expression
%type <code_node> Expression_Loop
%type <code_node> Mult_Expr
%type <code_node> Comp
%type <code_node> Term

%type <ident_val> Ident
// %type <ident_val> Ident_Loop

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
    | %empty 
{
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

Declaration: Ident COLON INTEGER
  {
    // printf("Declaration: %s\n", $1);
    std::string id = $1;
    CodeNode *node = new CodeNode;
    node->code = std::string(". ") + id + std::string("\n");
    $$ = node;
  }
    | Ident COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
  {
    CodeNode *node = new CodeNode;
    // insert intermediate codes
    $$ = node;
  }
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

  /* Ident_Loop: Ident
  {
    // insert intermediate code
    std::string id = $1;
    CodeNode *node = new CodeNode;
    node->name = id;
    $$ = node;

  }
    | Ident COMMA Ident_Loop
  {
    // insert intermediate code
    std::string id = $1;
    CodeNode *node = new CodeNode;
    node->name = id;
    CodeNode *identnode = $3;
    node->name += identnode->name;
    $$ = node;
    
  } */

Ident:  IDENT
  {
    // insert intermediate code
    $$ = $1;
  }

Statement_Loop: %empty 
  {
    CodeNode *node = new CodeNode;
    $$ = node; 
  }
    | Statement SEMICOLON Statement_Loop
  {
    CodeNode *code_node1 = $1;
    CodeNode *code_node2 = $3;

    CodeNode *node = new CodeNode;
    node->code = code_node1->code + code_node2->code;
    // printf("%p %p\n", $1, $3);
    $$ = node;  
  }
;

Statement: Ident ASSIGN Expression
  {
    CodeNode *node = new CodeNode;
    std::string id = $1;
    CodeNode *nodeExpr = $3;
    // printf(id.c_str());
    node->code = "";      //hard coded: expression.name
    node->code += nodeExpr->code;

    node->code = std::string("= ") + id + std::string(", 150\n");
    // printf("%s \n", node->code.c_str());
    $$ = node;
  }
    | Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET ASSIGN Expression 
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | IF BoolExp THEN Statement_Loop ElseStatement ENDIF
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }		 
    | WHILE BoolExp BEGINLOOP Statement_Loop ENDLOOP
	{
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | DO BEGINLOOP Statement_Loop ENDLOOP WHILE BoolExp
	{
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | READ Var
	{
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | WRITE Var
  {
      CodeNode *node = new CodeNode;
      CodeNode *var = $2;
      std::string id = var->name;
      // printf(id.c_str());
      node->code = "";
      node->code += std::string(".> ") + id + std::string("\n");
      $$ = node;
  }
    | CONTINUE
	{
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | BREAK
	{
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | RETURN Expression
	{
    CodeNode *node = new CodeNode;
    $$ = node;
  }
;

ElseStatement:  %empty
  {
    // insert intermediate code
    
  }
    | ELSE Statement_Loop
	{
    // insert intermediate code
  }
;

BoolExp:  NOT BoolExpression
  {
    // insert intermediate code
  }
    | BoolExpression
  {
    // insert intermediate code
  }

;

BoolExpression: Expression Comp Expression
  {
    // insert intermediate code
  }
    | TRUE
  {
    // insert intermediate code
  }
    | FALSE
  {
    // insert intermediate code
  }
    | L_PAREN BoolExp R_PAREN
  {
    // insert intermediate code
  }
;

Comp: EQ
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | NEQ
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | LT
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | GT
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | LTE
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | GTE
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
;

Expression: Mult_Expr
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | Mult_Expr PLUS Expression
  {
    CodeNode *node = new CodeNode;
    $$ = node;
      /*
    // std::string temp = gen_temp();
    // CodeNode *node = new CodeNode;
    // node->code = $1->code + $3->code + decl_temp_code(temp);
    // node->code += std::string("+ ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    // node->name = temp;
    // $$ = node;
    */
  }
    | Mult_Expr SUB Expression
	{
    // insert intermediate 
    CodeNode *node = new CodeNode;
    $$ = node;
  }
;

Expression_Loop:  %empty
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | Expression COMMA Expression_Loop
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | Expression
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
;

Mult_Expr:  Term
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | Term MULT Mult_Expr
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
  | Term DIV Mult_Expr
	{
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | Term MOD Mult_Expr
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
;

Term: Var
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | NUMBER
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | L_PAREN Expression R_PAREN
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | Ident L_PAREN Expression_Loop R_PAREN
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  } 
    /* | Ident COMMA Ident
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  } */
;

Var:  Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | Ident
  {
    std::string name = $1;
    CodeNode *node = new CodeNode;
    node->code = "";
    node->name = name;
    $$ = node;
  }
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

    yyparse();
    print_symbol_table();
    std::ofstream file("out.mil");
    file << out.str() << std::endl;
    return 0;
  }  
