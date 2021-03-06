%{
#include<stdio.h>
#include<string>
#include<vector>
#include<string.h>
#include<sstream>
#include<iostream>
#include<fstream>

extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;

char *identToken;
int numberToken;
int  count_names = 0;


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


%union {
  char *op_val;
}

%define parse.error verbose
%start prog_start
%token BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token FUNCTION 
%token INTEGER 
%token WRITE
%token SUB ADD MULT DIV MOD
%token SEMICOLON COLON COMMA ASSIGN
%token <op_val> NUMBER 
%token <op_val> IDENT
%type <op_val> symbol 

%%

prog_start: functions
{
  printf("prog_start -> functions\n");
}

functions: 
/* epsilon */
{ 
  printf("functions -> epsilon\n");
}
| function functions
{
  printf("functions -> function functions\n");
};

function: FUNCTION IDENT 
{
  // midrule:
  // add the function to the symbol table.
  std::string func_name = $2;
  add_function_to_symbol_table(func_name);
  out << "func " << func_name << std::endl;

  

}
	SEMICOLON
	BEGIN_PARAMS declarations END_PARAMS
	BEGIN_LOCALS declarations END_LOCALS
	BEGIN_BODY statements END_BODY
{
  printf("function -> FUNCTION IDENT ; BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");
  out << "endfunc" << std::endl;
};

declarations: 
/* epsilon */
{
  printf("declarations -> epsilon\n");
}
| declaration SEMICOLON declarations
{
  printf("declarations -> declaration ; declarations\n");
};

declaration: 
	IDENT COLON INTEGER
{
  printf("declaration -> IDENT : integer\n");

  // add the variable to the symbol table.
  std::string value = $1;
  Type t = Integer;
  add_variable_to_symbol_table(value, t);

  out << ". " << value << std::endl;
};

statements: 
statement SEMICOLON
{
  printf("statements -> statement ;\n");
}
| statement SEMICOLON statements
{
  printf("statements -> statement ; statements\n");
};

statement: 
IDENT ASSIGN symbol ADD symbol
{
  printf("statement -> IDENT := symbol + symbol\n");
  std:: string temp = gen_temp();
  out << ". " << temp << std::endl;
  out << "+ " << temp << ", " << $3 << ", " << $5 << std::endl;
  out << "= " << $1 << ", " << temp << std::endl;


}
| IDENT ASSIGN symbol SUB symbol
{
  printf("statement -> IDENT := symbol - symbol\n");
  std:: string temp = gen_temp();
  out << ". " << temp << std::endl;
  out << "- " << temp << ", " << $3 << ", " << $5 << std::endl;
  out << "= " << $1 << ", " << temp << std::endl;
}
| IDENT ASSIGN symbol MULT symbol
{
  printf("statement -> IDENT := symbol * symbol\n");
  std:: string temp = gen_temp();
  out << ". " << temp << std::endl;
  out << "* " << temp << ", " << $3 << ", " << $5 << std::endl;
  out << "= " << $1 << ", " << temp << std::endl;
}
| IDENT ASSIGN symbol DIV symbol
{
  printf("statement -> IDENT := symbol / symbol\n");
  std:: string temp = gen_temp();
  out << ". " << temp << std::endl;
  out << "/ " << temp << ", " << $3 << ", " << $5 << std::endl;
  out << "= " << $1 << ", " << temp << std::endl;
}
| IDENT ASSIGN symbol MOD symbol
{
  printf("statement -> IDENT := symbol %% symbol\n");
  std:: string temp = gen_temp();
  out << ". " << temp << std::endl;
  out << "% " << temp << ", " << $3 << ", " << $5 << std::endl;
  out << "= " << $1 << ", " << temp << std::endl;
}

| IDENT ASSIGN symbol
{
  printf("statement -> IDENT := symbol\n");
  // catch unidentified variables here
  std::string dest = $1;
  if (!find(dest)) {
    yyerror("Error. Cannot find variable in symbol table.");
  }
  
  out << "= " << $1 << ", " << $3 << std::endl;
}


| WRITE IDENT
{
  printf("statement -> WRITE IDENT\n");
  out << ".> " << $2 << std::endl;
}
;

symbol: 
IDENT 
{
  printf("symbol -> IDENT %s\n", $1); 
  $$ = $1; 
}
| NUMBER 
{
  printf("symbol -> NUMBER %s\n", $1);
  $$ = $1; 
}

%%

int main(int argc, char **argv)
{
   yyparse();
   print_symbol_table();
   std::ofstream file("out.mil");
   file << out.str() << std::endl;
   return 0;
}

void yyerror(const char *msg)
{
   printf("** Line %d: %s\n", currLine, msg);
   exit(1);
}
