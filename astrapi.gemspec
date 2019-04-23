require_relative "./lib/version"

Gem::Specification.new do |s|
  s.name        = 'astrapi'
  s.version     = Astrapi::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "meta-compiler for S-expression based Domain Specific Languages (DSL)"
  s.description = "Starting from the metamodel of a DSL (abstract classes and their relationship), Astrapi generates a compiler front end for this DSL. The model itself is expressed in S-expressions"
  s.authors     = ["Jean-Christophe Le Lann"]
  s.email       = 'lelannje@ensta-bretagne.fr'
  s.files       = ["lib/ast.rb",
                   "lib/code.rb",
                   "lib/version.rb",
                   "lib/lexer.rb",
                   "lib/ruby_generator.rb",
                   "lib/template_lexer.rb",
                   "lib/template_pretty_printer.rb",
                   "lib/template_indent.rb",
                   "lib/template_code.rb",
                   "lib/template_ast_printer.rb",
                   "lib/template_parser.rb",
                   "lib/template_code.rb",
                   "lib/template_compiler.rb",
                   "lib/template_visitor.rb",
                   "lib/checker.rb",
                   "lib/compiler.rb",
                   "lib/dot_printer.rb",
                   "lib/parser.rb",
                   "lib/visitor.rb",
                   "lib/class_diagram_printer.rb",
                   "lib/dbg.rb",
                   "lib/indent.rb",
                   "lib/pretty_printer.rb",
                   "doc/astrapi.html",
                   "tests/geometry.mm"]
  s.executables << 'astrapi'
  s.homepage    = 'http://www.jcll.fr/astrapi.html'
  s.license     = 'MIT'
  s.post_install_message = "Thanks for installing! Homepage : http://www.jcll.fr/astrapi.html"
  s.required_ruby_version = '>= 2.0.0'
end
