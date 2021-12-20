/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     T_VAR = 258,
     T_CONST = 259,
     T_INT = 260,
     T_FLOAT = 261,
     T_BOOL = 262,
     T_DECL = 263,
     T_IF = 264,
     T_ELSE = 265,
     T_FOR = 266,
     T_CONT = 267,
     T_BREAK = 268,
     T_ADD = 269,
     T_SUB = 270,
     T_MUL = 271,
     T_DIV = 272,
     T_MOD = 273,
     T_LT = 274,
     T_LTEQ = 275,
     T_GT = 276,
     T_GTEQ = 277,
     T_EQ = 278,
     T_EQEQ = 279,
     T_NEQ = 280,
     T_AND = 281,
     T_OR = 282,
     T_NOT = 283,
     T_LPAREN = 284,
     T_RPAREN = 285,
     T_RBRACK = 286,
     T_LBRACK = 287,
     T_LBRACE = 288,
     T_RBRACE = 289,
     T_SEMI = 290,
     T_DOT = 291,
     T_COMMA = 292,
     T_NL = 293,
     T_ID = 294,
     T_CONST_INT = 295,
     T_CONST_FLOAT = 296,
     T_STRING = 297
   };
#endif
/* Tokens.  */
#define T_VAR 258
#define T_CONST 259
#define T_INT 260
#define T_FLOAT 261
#define T_BOOL 262
#define T_DECL 263
#define T_IF 264
#define T_ELSE 265
#define T_FOR 266
#define T_CONT 267
#define T_BREAK 268
#define T_ADD 269
#define T_SUB 270
#define T_MUL 271
#define T_DIV 272
#define T_MOD 273
#define T_LT 274
#define T_LTEQ 275
#define T_GT 276
#define T_GTEQ 277
#define T_EQ 278
#define T_EQEQ 279
#define T_NEQ 280
#define T_AND 281
#define T_OR 282
#define T_NOT 283
#define T_LPAREN 284
#define T_RPAREN 285
#define T_RBRACK 286
#define T_LBRACK 287
#define T_LBRACE 288
#define T_RBRACE 289
#define T_SEMI 290
#define T_DOT 291
#define T_COMMA 292
#define T_NL 293
#define T_ID 294
#define T_CONST_INT 295
#define T_CONST_FLOAT 296
#define T_STRING 297




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

