/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IDENT = 258,
    NUMBER = 259,
    ASSIGN = 260,
    EQ = 261,
    PLUS = 262,
    SUB = 263,
    MULT = 264,
    DIV = 265,
    L_PAREN = 266,
    R_PAREN = 267,
    SEMICOLON = 268,
    COLON = 269,
    LT = 270,
    LTE = 271,
    GT = 272,
    GTE = 273,
    L_SQUARE_BRACKET = 274,
    R_SQUARE_BRACKET = 275,
    MOD = 276,
    NEQ = 277,
    COMMA = 278,
    IF = 279,
    ENDIF = 280,
    WHILE = 281,
    THEN = 282,
    FUNCTION = 283,
    INTEGER = 284,
    READ = 285,
    WRITE = 286,
    ARRAY = 287,
    OF = 288,
    CONTINUE = 289,
    BREAK = 290,
    NOT = 291,
    TRUE = 292,
    FALSE = 293,
    RETURN = 294,
    BEGINLOOP = 295,
    ENDLOOP = 296,
    BEGIN_LOCALS = 297,
    END_LOCALS = 298,
    BEGIN_PARAMS = 299,
    END_PARAMS = 300,
    BEGIN_BODY = 301,
    END_BODY = 302,
    DO = 303,
    ELSE = 304,
    AND = 305
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 13 "calc.y" /* yacc.c:1909  */

  char* ident_val;
  int num_val;

#line 110 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
