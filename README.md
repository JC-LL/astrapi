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

<!-- HTML generated using hilite.me -->
<div style="background: #ffffff; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">(<span style="color: #0066BB; font-weight: bold">scene</span> <span style="color: #996633">test</span>
  (<span style="color: #0066BB; font-weight: bold">square</span> <span style="color: #996633">s1</span>
     (<span style="color: #0066BB; font-weight: bold">position</span> <span style="color: #0000DD; font-weight: bold">123</span> <span style="color: #0000DD; font-weight: bold">345</span>)
     (<span style="color: #0066BB; font-weight: bold">size</span> <span style="color: #0000DD; font-weight: bold">12</span>)
  )
  (<span style="color: #0066BB; font-weight: bold">circle</span> <span style="color: #996633">c1</span>
     (<span style="color: #0066BB; font-weight: bold">position</span> <span style="color: #0000DD; font-weight: bold">123</span> <span style="color: #0000DD; font-weight: bold">345</span>)
     (<span style="color: #0066BB; font-weight: bold">size</span> <span style="color: #0000DD; font-weight: bold">12</span> <span style="color: #0000DD; font-weight: bold">23</span>)
  )
  (<span style="color: #0066BB; font-weight: bold">rectangle</span> <span style="color: #996633">s2</span>
     (<span style="color: #0066BB; font-weight: bold">position</span> <span style="color: #0000DD; font-weight: bold">323</span> <span style="color: #0000DD; font-weight: bold">445</span>)
     (<span style="color: #0066BB; font-weight: bold">size</span> <span style="color: #0000DD; font-weight: bold">12</span> <span style="color: #0000DD; font-weight: bold">34</span>)
  )
)
</pre></div>

Now let\'s express the concepts of this model : let\'s name this a *metamodel*. I suffix this file with \'.mm\'. It ressembles *Ruby modules and class*, but it is not.

<!-- HTML generated using hilite.me --><div style="background: #f0f3f3; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #006699; font-weight: bold">module</span> <span style="color: #00CCFF; font-weight: bold">Geometry</span>

  <span style="color: #006699; font-weight: bold">class</span> <span style="color: #00AA88; font-weight: bold">Scene</span>
    <span style="color: #006699">attr</span> <span style="color: #336666">name</span> <span style="color: #555555">=&gt;</span> <span style="color: #336600">IDENT</span>
    <span style="color: #006699">attr</span> elements <span style="color: #555555">=&gt;</span> <span style="color: #336600">Shape</span><span style="color: #555555">[]</span>
  <span style="color: #006699; font-weight: bold">end</span>

  <span style="color: #006699; font-weight: bold">class</span> <span style="color: #00AA88; font-weight: bold">Shape</span>
    <span style="color: #006699">attr</span> <span style="color: #336666">id</span> <span style="color: #555555">=&gt;</span> <span style="color: #336600">IDENT</span>
    <span style="color: #006699">attr</span> position <span style="color: #555555">=&gt;</span> <span style="color: #336600">Position</span>
  <span style="color: #006699; font-weight: bold">end</span>

  <span style="color: #006699; font-weight: bold">class</span> <span style="color: #00AA88; font-weight: bold">Square</span> <span style="color: #555555">&lt;</span> <span style="color: #336600">Shape</span>
    <span style="color: #006699">attr</span> size <span style="color: #555555">=&gt;</span> <span style="color: #336600">Size</span>
  <span style="color: #006699; font-weight: bold">end</span>

  <span style="color: #006699; font-weight: bold">class</span> <span style="color: #00AA88; font-weight: bold">Circle</span> <span style="color: #555555">&lt;</span> <span style="color: #336600">Shape</span>
    <span style="color: #006699">attr</span> radius <span style="color: #555555">=&gt;</span> <span style="color: #336600">Size</span>
  <span style="color: #006699; font-weight: bold">end</span>

  <span style="color: #006699; font-weight: bold">class</span> <span style="color: #00AA88; font-weight: bold">Rectangle</span> <span style="color: #555555">&lt;</span> <span style="color: #336600">Shape</span>
    <span style="color: #006699">attr</span> size <span style="color: #555555">=&gt;</span> <span style="color: #336600">Size</span>
  <span style="color: #006699; font-weight: bold">end</span>

  <span style="color: #006699; font-weight: bold">class</span> <span style="color: #00AA88; font-weight: bold">Size</span>
    <span style="color: #006699">attr</span> dims <span style="color: #555555">=&gt;</span> <span style="color: #336600">INTEGER</span><span style="color: #555555">[]</span>
  <span style="color: #006699; font-weight: bold">end</span>

  <span style="color: #006699; font-weight: bold">class</span> <span style="color: #00AA88; font-weight: bold">Position</span>
     <span style="color: #006699">attr</span> coord <span style="color: #555555">=&gt;</span> <span style="color: #336600">INTEGER</span><span style="color: #555555">[]</span>
  <span style="color: #006699; font-weight: bold">end</span>
<span style="color: #006699; font-weight: bold">end</span>
</pre></div>



Then compile this metamodel using Astrapi :

<!-- HTML generated using hilite.me -->
<div style="background: #f0f3f3; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">
jcll$ > astrapi geometry.mm
ASTRAPI meta-compiler for Sexp-based DSLs (c) J-C Le Lann 2016
==&gt; parsing metamodel.................... geometry.mm
==&gt; pretty print metamodel............... geometry_pp.mm
==&gt; generate dot for metamodel........... geometry_ast.dot
==&gt; checking metamodel
==&gt; generating class diagram............. geometry_class_diagram.dot
==&gt; generate software stack for DSL &#39;Geometry&#39;. Ruby version
----&gt; generating Geometry DSL AST classes
----&gt; generating Geometry DSL AST printer
----&gt; generating Geometry DSL lexer
----&gt; generating Geometry DSL parser
----&gt; generating Geometry DSL pretty printer
----&gt; generating Geometry DSL compiler
</pre></div>

Now we can play with our brand new Geometry compiler !

<!-- HTML generated using hilite.me -->
<div style="background: #f8f8f8; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">$&gt; ruby geometry_compiler.rb ex1.geo
Geometry compiler
==&gt; parsing ex1.geo
==&gt; pretty print to ........ ex1.geo_pp.geometry
==&gt; generate dot for AST in ex1.geo.dot
compiled in     : 0.001463371 s
</pre></div>

In particular, we can have a look at the graphical AST (plain graphiz dot format). If you have xdot installed, simply type **xdot ex1.geo.dot** and the AST of our example will show up like this.

![Image of AST model](/doc/ex1.geo.png)

##About the Metamodel

###Basic syntax
Astrapi metamodel syntax remains very basic. A concept is captured as a **class**, followed by the list of its attributes **attr**. The type of the attributes appears after **=>**. Attributes can be simple or multiple. The order of declaration of classes has no importance, but the **order of *attr* declarations is fundamental**, as it drives the generated DSL parser. This may be enhanced in a future version.

###Basic data types
There also exist some basic types understood by Astrapi and parsed as *terminals* :

* **IDENT** will make the lexer recognize tokens matching the regexp /[a-zA-Z]+[a-zA-Z_0-9]*/i.
* **INTEGER** : regexp is /[0-9]+/
* **FLOAT** : regexp is /[0-9]+\.[0-9]+/
* **RANGE** : regexp is /[0-9]+..[0-9+/
* **STRING** : regexp is /\"(.*)\"/
* **NIL** : regexp is /nil/

Note that you can use **nil** in your DSL model, either for expected concepts or terminals.

###Graphical view of the Metamodel
A graphical view of the metamodel structure is also generated by Astrapi. This is a basic *class-diagram* of the AST classes. The name of the dot file appears during the metamodel compilation. It is suffix a ** xxx_ast.dot **.
To view it, type **xdot xxx_ast.dot**. For our Geometry example :

![Image of the metamodel](./img/geometry_class_diagram.png)

## Comments in Astrapi s-expressions
Comments are accepted in Astrapi s-expressions. Comments starts with **#** symbol and ends at the end of line. A comment will be attached (attribute **.comments_**) to the AST node following this comment. As such, comments can be reused (code generation etc).

## Credits
Please <a href="mailto:lelannje@ensta-bretagne.fr">drop me an email</a> if you use Astrapi, or want some additional features or bug fixes.
