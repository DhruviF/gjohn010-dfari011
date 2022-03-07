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
int counter = 0;

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
std::vector <int> continueCount;

std::string gen_temp() {
  static int count = 0;
  return "__temp__" + std::to_string(count++);
}

std::string gen_label() {
  counter = 0;
    // static int count = 0;
    // return std::to_string(count++);
  return std::to_string(counter);
    // return "__label__" + std::to_string(count++);
} 

Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

std::string decl_temp_code(std::string &temp){
  return std::string(". ") + temp + std::string("\n");
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
%token <ident_val> NUMBER

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
%type <code_node> BoolExpression
%type <code_node> BoolExp
%type <code_node> ElseStatement

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
  add_function_to_symbol_table(func_name);
  node->code = "";
  node->code += std::string("func ") + func_name + std::string("\n");
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
    add_function_to_symbol_table(id);
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


Ident:  IDENT
  {
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
    std::string id = $1;
    CodeNode *node = new CodeNode;
    node->code = $3->code;
    node->code += std::string("= ") + id + std::string(", ") + $3->name + std::string("\n");
    node->name = id;
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

    std::string truee = gen_label();
    std::string falsee = gen_label();
    std::string endiff = gen_label();

    CodeNode *expr = $2;
    CodeNode *statement= $4;
    CodeNode *elsestate = $5;
    
    node->code = expr->code + std::string("\n");
    node->code += std::string("?:= ") + "if_true" + truee + std::string(", ") + expr->name + std::string("\n");

    if (elsestate->code != "") { 
      node->code += std::string(":= ") + "else" + falsee + std::string("\n");
      node->code += std::string(": ") + "if_true" + truee + std::string("\n");
      node->code += statement->code + std::string("\n");
      node->code += std::string(":= ") + "endif" + endiff + std::string("\n");
      node->code += std::string(": ") + "else" + falsee + std::string("\n");
      node->code += elsestate->code + std::string("\n");  
      node->code += std::string(": ") + "endif" + endiff + std::string("\n");
    } else {
      node->code += std::string(":= ") + "else" + falsee + std::string("\n");
      node->code += std::string(": ") + "if_true" + truee + std::string("\n");
      node->code += statement->code + std::string("\n");
      node->code += std::string(": ") + "else" + falsee + std::string("\n");
      node->code += elsestate->code + std::string("\n");
      node->code += std::string(":= ") + "endif" + endiff + std::string("\n");    
    }
    $$ = node;
  }		 
    | WHILE BoolExp BEGINLOOP Statement_Loop ENDLOOP
	{
    CodeNode *node = new CodeNode;
    std::string condition = gen_label();
    std::string start = gen_label();
    std::string end = gen_label();
    CodeNode *boolexpr = $2;
    CodeNode *statement = $4;
    
    std::string output = std::string(":= ") + condition;    
    node->code = std::string(": ") + std::string("beginloop") + condition + std::string("\n");
    node->code += boolexpr->code + std::string("\n");
    node->code += std::string("?:= ") + std::string("loopbody") + start + std::string(", ") +  boolexpr->name + std::string("\n");
    node->code += std::string(":= ") + std::string("endloop") + end + std::string("\n");
    node->code += std::string(": ") + std::string("loopbody") + start + std::string("\n");
    node->code += statement->code + std::string("\n");
    node->code += std::string(":= ") + std::string("beginloop") + condition + std::string("\n");
    node->code += std::string(": ") + std::string("endloop")s + end + std::string("\n");

    $$ = node;
  }
    | DO BEGINLOOP Statement_Loop ENDLOOP WHILE BoolExp
	{
    CodeNode *node = new CodeNode;
    std::string start = gen_temp();
    std::string condition = gen_temp();

    node->code = std::string(": ") + start + std::string("\n");
    node->code = $3->code + std::string("\n");
    node->code = std::string(": ") + condition + std::string("\n");
    node->code = $6->code + std::string("\n");
    node->code = std::string("?:= ") + start + std::string(", ") + $6->name + std::string("\n");
    $$ = node;
  }
    | READ Var
	{
    CodeNode *node = new CodeNode;
    CodeNode *var = $2;
    std::string id = var->name;
    node->code = "";
    node->code += std::string(".< ") + id + std::string("\n");
    $$ = node;
  }
    | WRITE Var
  {
      CodeNode *node = new CodeNode;
      CodeNode *var = $2;
      std::string id = var->name;
      node->code = "";
      node->code += std::string(".> ") + id + std::string("\n");
      $$ = node;
  }
    | CONTINUE
	{
    CodeNode *node = new CodeNode;
    node->code = "";
      // node->code = std::string("continue\n");
    $$ = node;
  }
    | BREAK
	{
    CodeNode *node = new CodeNode;
    // node->code = "";
    // node->code = std::string("break\n");
    node->code = std::string(":= if_true") + std::string("\n");
    node->code = std::string(":= endloop") + std::string("\n");
    node->code = std::string(":= endif") + std::string("\n");
    $$ = node;
  }
    | RETURN Expression
	{
    CodeNode *node = new CodeNode;
    CodeNode *expr = $2;
    node->code = "";
    node->code += std::string("return ") + expr->name + std::string("\n");
    $$ = node;
  }
;

ElseStatement:  %empty
  {
    CodeNode *node = new CodeNode;
    $$ = node;
  }
    | ELSE Statement_Loop
	{
    $$ = $2;
  }
;

BoolExp:  NOT BoolExpression
  {   
      CodeNode *node = new CodeNode;
      CodeNode *expr = $2;
      std::string temp = gen_temp();
      counter++;
      node->name = temp;
      node->code = expr->code + decl_temp_code(temp);
      node->code += std::string("! ") + temp + std::string(", ") + expr->name + std::string("\n");
      $$ = node; 

  }
    | BoolExpression
  {
    $$ = $1;
  }

;

BoolExpression: Expression Comp Expression
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    CodeNode *expr1 = $1;
    CodeNode *operation = $2;
    CodeNode *expr2 = $3;
    std::string temp = gen_temp();
    counter++;
    node->name = temp;
    node->code = expr1->code + expr2->code + decl_temp_code(temp);
    node->code += operation->name + temp + std::string(", ") + expr1->name + std::string(", ") + expr2->name + std::string("\n");
    $$ = node;
  }
    | L_PAREN BoolExp R_PAREN
  {
    // insert intermediate code
    CodeNode *node = new CodeNode;
    $$ = node;
  }
;

Comp: EQ
  {
    CodeNode *node = new CodeNode;
    node->name = std::string("== ");
    $$ = node;
  }
    | NEQ
  {
    CodeNode *node = new CodeNode;
    node->name = std::string("!= ");
    $$ = node;
  }
    | LT
  {
    CodeNode *node = new CodeNode;
    node->name = std::string("< ");
    $$ = node;
  }
    | GT
  {
    CodeNode *node = new CodeNode;
    node->name = std::string("> ");
    $$ = node;
  }
    | LTE
  {
    CodeNode *node = new CodeNode;
    node->name = std::string("<= ");
    $$ = node;
  }
    | GTE
  {
    CodeNode *node = new CodeNode;
    node->name = std::string(">= ");
    $$ = node;
  }
;

Expression: Mult_Expr
  {
    // insert intermediate code
    CodeNode *node = $1;
    // printf("reached here", node->name.c_str(), node->code.c_str());
    $$ = node;
  }
    | Mult_Expr PLUS Expression
  {
    std::string temp = gen_temp();
    counter++;
    CodeNode *node = new CodeNode;
    node->code = $1->code + $3->code + decl_temp_code(temp);
    node->code += std::string("+ ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    node->name = temp;
    $$ = node;
    
  }
    | Mult_Expr SUB Expression
	{
    std::string temp = gen_temp();
    CodeNode *node = new CodeNode;
    node->code = $1->code + $3->code + decl_temp_code(temp);
    node->code += std::string("- ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    node->name = temp;
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
    $$ = $1;
  }
;

Mult_Expr:  Term
  {
    // insert intermediate code
    CodeNode *node = $1;
    $$ = node;
  }
    | Term MULT Mult_Expr
  {
    std::string temp = gen_temp();
    counter++;
    CodeNode *node = new CodeNode;
    node->code = $1->code + $3->code + decl_temp_code(temp);
    node->code += std::string("* ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    node->name = temp;
    $$ = node;
  }
  | Term DIV Mult_Expr
	{
    std::string temp = gen_temp();
    counter++;
    CodeNode *node = new CodeNode;
    node->code = $1->code + $3->code + decl_temp_code(temp);
    node->code += std::string("/ ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    node->name = temp;
    $$ = node;
  }
    | Term MOD Mult_Expr
  {
    std::string temp = gen_temp();
    counter++;
    CodeNode *node = new CodeNode;
    node->code = $1->code + $3->code + decl_temp_code(temp);
    node->code += std::string("% ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    node->name = temp;
    $$ = node;
  }
;

Term: Var
  {
    // insert intermediate code
    CodeNode *node = $1; // add to symbol table
    $$ = node;
  }
    | NUMBER
  {
    std::string id = $1;
    CodeNode *node = new CodeNode;
    // printf("id: %s", id.c_str()); // debug 
    node->name = id;
    node->code = "";
    // node->code += id;
    $$ = node;
  }
    | L_PAREN Expression R_PAREN
  {
    CodeNode *node = new CodeNode;
    node->name = $2->name;
    node->code = $2->code;
    $$ = node;
  }
    | Ident L_PAREN Expression_Loop R_PAREN
  {
    CodeNode *node = new CodeNode;
    node->name = yylval.ident_val;
    node->code = $3->code;
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
    node->code = $3->code;
    std::string id = yylval.ident_val;
    CodeNode *tempNode = $3;
    id += std::string(", ") + std::string(tempNode->name);
    node->name = id;
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