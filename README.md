#Astrapi meta-compiler

##What is Astrapi ?

Astrapi is meta-compiler for Sexp-based Domain Specific Languages : once you have described your DSL concepts (abstract syntax) thanks to Astrapi language, the compiler generates several files for you:

* the corresponding classes
* lexer and parser
* generic visitor
* pretty printer
* graphical AST viewer

Finally a driver for you own DSL compiler is also generated. Version 0.0.2 provides Ruby generation, but Python, Java and C++ will be available soon.

Astrapi-generated DSL parser will assume your DSL models are written in plain **s-expressions**.

##What are s-expressions ?
S-expressions, abreviated as \"sexps\", actually mean \"symbolic expressions\". They originated from the famous LISP language. Compiler designers resort to  *sexp* as the most direct mean to capture Abstract Syntax Trees (AST) in a textual format.

Sexps are convenient to serialize both data *and* code, which offers a superiority over other serialization formats like XML, YAML or JSON.  

It may be noticed that several S-expressions parsers exist around. In the Ruby ecosystems, SXP and Sexpistols can be recommanded. However, these parsers will just turn the parenthesized expressions into a Ruby native data structure : namely arrays of arrays, etc. If your intent is to consider each s-expression as an instance of a *custom* class, then Astrapi is for you !

##How to install ?
In your terminal, simply type : **gem install astrapi**

##Quick start
In this example, we invent a toy language (DSL) that aims at describing simple geometry. Let us begin with examples programs written in our expected syntax :
