require 'erb'
require_relative 'ast'

module Astrapi

  class RubyGenerator

    attr_accessor :mm

    #Astrapi basic types :
    BASIC_TYPES = [:integer,:float,:range,:ident,:string]

    def generate mm
      @mm=mm
      @path=__dir__ #ruby > 2.0
      @path+="/"
      generate_misc
      generate_ast
      generate_dot_ast_printer
      generate_sexp_lexer
      generate_sexp_parser
      generate_sexp_pretty_printer
      generate_visitor
      generate_dsl_compiler
    end

    def generate_ast
      puts "----> generating #{mm.name} DSL AST classes"
      mm_name=mm.name
      code = Code.new
      code << "# code generated automatically by M3E"
      code << "module #{mm_name}"
      code.newline
      code.indent=2
      code << "class Ast"
      code.indent=4
      code << "attr_accessor :comments_"
      code << "def accept(visitor, arg=nil)"
      code << "  name = self.class.name.split(/::/)[1]"
      code << "  visitor.send(\"visit\#{name}\".to_sym, self ,arg) # Metaprograming !"
      code << "end"
      code.newline
      code.indent=2
      code << "end"
      code.newline
      code.indent=2
      code << "class Comment_ < Ast"
      code.indent=4
      code << "attr_accessor :list"
      code.indent=2
      code << "end"
      code.newline
      code.indent=2

      mm.classes.each{|k|
        code << code_for(k)
        code.newline
      }
      code.indent=0
      code << "end"
      code.save_as("#{mm_name.to_s.downcase}_ast.rb",false)
    end

    def code_for klass
      code=Code.new
      mother = klass.inheritance
      inheritance="< #{klass.inheritance}" if mother
      inheritance ||= "< Ast"
      code << "class #{klass.name} #{inheritance}"
      code.indent=2
      code << "attr_accessor #{klass.attrs.collect{|atr| ':'+atr.name.to_s}.join(',')}"
      code << "def initialize"
      code.indent=4
      klass.attrs.each do |atr|
        init=(atr.type.is_a? ArrayOf) ? "[]" : "nil"
        code << "@#{atr.name} = #{init}"
      end
      code.indent=2
      code << "end"
      code.indent=0
      code << "end"
      code
    end

    def generate_sexp_lexer
      puts "----> generating #{mm.name} DSL lexer"
      keywords=mm.classes.collect{|k| k.name.to_s}.map{|k| k.downcase.to_sym}
      regexp_code=Code.new #to be inserted in ERB template
      regexp_code.indent=4
      keywords.each do |kw|
        regexp_code << "#{kw.upcase.to_s.ljust(30)} = /\\A#{kw}/"
      end
      keywords_regexp=regexp_code.finalize
      #.......
      regexp_code=Code.new
      regexp_code.indent=8
      keywords.each do |kw|
        regexp_code << "when value = text.match(#{kw.upcase})"
        regexp_code << "  return Token.new [:#{kw},text,position]"
      end
      apply_regexp=regexp_code.finalize
      #...... call templating engine
      engine = ERB.new(IO.read(@path+"template_lexer.rb"))
      lexer_rb_code=engine.result(binding)
      File.open("#{mm.name.to_s.downcase}_lexer.rb",'w'){|f| f.puts lexer_rb_code}
    end

    def generate_sexp_parser
      puts "----> generating #{mm.name} DSL parser"
      code=Code.new
      code.indent=4
      mm.classes.each do |klass|
        kname=klass.name.to_s
        v=kname.downcase
        code.newline
        code << "def parse#{kname}"
        code.indent=6
        code << "indent \"#{klass.name}\""
        code << "if n=nil_maybe?"
        code << "  return n"
        code << "end"
        code << "#{v}_ = #{mm.name}::#{kname}.new"
        code << "#{v}_.comments_=parse_comments()"
        code << "expect :lparen"
        code << "expect :#{v}"
        code << core_parsing_for(klass)
        code << "expect :rparen"
        code << "dedent"
        code << "return #{v}_"
        code.indent=4
        code << "end"
      end
      parsing_methods=code.finalize
      #...... call templating engine
      engine = ERB.new(IO.read(@path+"template_parser.rb"))
      parser_rb_code=engine.result(binding)
      File.open("#{mm.name.to_s.downcase}_parser.rb",'w'){|f| f.puts parser_rb_code}
    end

    def generate_sexp_pretty_printer
      puts "----> generating #{mm.name} DSL pretty printer"
      code=Code.new
      code.indent=4
      mm.classes.each do |klass|
        kname=klass.name.to_s
        v=kname.downcase
        code.newline
        code << "def visit#{kname}(#{v}_,args=nil)"
        code.indent=6
        code << "indent \"#{klass.name}\""
        code << "ary=[]"
        code << "ary << #{v}_.comments_.val if #{v}_.comments_"
        code << "ary << #{v}_.class.to_s.downcase.split('::')[1].to_sym"
        attrs = hierarchical_attrs(klass) + klass.attrs #note the order!
        code_for_attrs=attrs.collect{|atr|
          if atr.type.is_a? ArrayOf
            e=((name=atr.name.to_s).end_with?('s')) ? name[0..-2] : "e"
            code << "#{v}_.#{atr.name}.each do |#{e}|"
            code.indent=8
            code << "ary << #{e}.accept(self,args)"
            code.indent=6
            code << "end"
          else
            code << "ary << #{v}_.#{atr.name}.accept(self)"
          end
        }
        code << "dedent"
        code << "return ary"
        code.indent=4
        code << "end"
      end
      visiting_methods=code.finalize
      #...... call templating engine
      engine = ERB.new(IO.read(@path+"template_pretty_printer.rb"))
      parser_rb_code=engine.result(binding)
      File.open("#{mm.name.to_s.downcase}_pp.rb",'w'){|f|
        f.puts parser_rb_code
      }
    end

    def generate_visitor
      puts "----> generating #{mm.name} DSL visitor"
      code=Code.new
      code.indent=4
      mm.classes.each do |klass|
        kname=klass.name.to_s
        v=kname.downcase
        code.newline
        code << "def visit#{kname}(#{v}_,args=nil)"
        code.indent=6
        code << "indent \"#{klass.name}\""
        attrs = hierarchical_attrs(klass) + klass.attrs #note the order!
        code_for_attrs=attrs.collect{|atr|
          if atr.type.is_a? ArrayOf
            e=((name=atr.name.to_s).end_with?('s')) ? name[0..-2] : "e"
            code << "#{v}_.#{atr.name}.each do |#{e}|"
            code.indent=8
            code << "#{e}.accept(self,args)"
            code.indent=6
            code << "end"
          else
            code << "#{v}_.#{atr.name}.accept(self)"
          end
        }
        code << "dedent"
        code.indent=4
        code << "end"
      end
      visiting_methods=code.finalize
      #...... call templating engine
      engine = ERB.new(IO.read(@path+"template_visitor.rb"))
      parser_rb_code=engine.result(binding)
      File.open("#{mm.name.to_s.downcase}_visitor.rb",'w'){|f|
        f.puts parser_rb_code
      }
    end

    def generate_dot_ast_printer
      puts "----> generating #{mm.name} DSL AST printer"
      #...... call templating engine
      engine = ERB.new(IO.read(@path+"template_ast_printer.rb"))
      printer_rb_code=engine.result(binding)
      File.open("#{mm.name.to_s.downcase}_ast_printer.rb",'w'){|f| f.puts printer_rb_code}
    end

    def generate_dsl_compiler
      puts "----> generating #{mm.name} DSL compiler"
      #...... call templating engine
      engine = ERB.new(IO.read(@path+"template_compiler.rb"))
      code=engine.result(binding)
      File.open("#{mm.name.to_s.downcase}_compiler.rb",'w'){|f| f.puts code}
    end

    def generate_misc
      engine = ERB.new(IO.read(@path+"template_indent.rb"))
      code=engine.result(binding)
      File.open("indent.rb",'w'){|f| f.puts code}
      engine = ERB.new(IO.read(@path+"template_code.rb"))
      code=engine.result(binding)
      File.open("code.rb",'w'){|f| f.puts code}
    end

    def core_parsing_for klass
      kname=klass.name.to_s
      #puts "#{kname}".center(80,'=')
      v=kname.downcase
      attrs = hierarchical_attrs(klass) + klass.attrs #note the order!
      code=Code.new
      attrs.each{|attr| code << parsing_code_for(attr,v)}
      return code
    end

    def hierarchical_attrs klass
      inherited_attrs=[]
      if mother=find_mother_of(klass)
        inherited_attrs << mother.attrs
        inherited_attrs << hierarchical_attrs(mother)
      end
      return inherited_attrs.flatten
    end

    def find_mother_of klass
      if id=klass.inheritance #identifier
        return mother=mm.classes.find{|k| k.name==id}
      end
      nil
    end

    def find_sons_of klass
      ret=mm.classes.select{|k| k.inheritance==klass.name}
      ret
    end

    def parsing_code_for attr,ast_node_var
      code=Code.new
      case type=attr.type
      when ArrayOf #note the position, before 'when Type' !
        possible_starters=compute_possible_starters(type.type)
        code << "comments=parse_comments()"
        lookahead=possible_starters.first.to_s.end_with?("_lit") ? 0 : 1
        starters=possible_starters.collect{|sym| ":#{sym}"}.join(',')
        code << "while showNext(#{lookahead}) && showNext(#{lookahead}).is_a?([#{starters}])"
        code.indent=2
        code << "case showNext(#{lookahead}).kind"
        possible_starters.each do |starter|
          code << "when :#{starter}"
          code.indent=4
          if starter.to_s.end_with?("_lit") #base types
            code << "#{ast_node_var}_.#{attr.name} << acceptIt"
          else
            code << "#{ast_node_var}_.#{attr.name} << parse#{starter.capitalize}()"
          end
          #code << "#{ast_node_var}_.#{attr.name} << parse#{starter.capitalize}()"
          code.indent=2
        end
        code << "else "
        code << "  abort \"ERROR when parsing attribute #{attr.name} : expecting one of [#{starters}].\n Got \#{showNext(1).kind}\""
        code << "end"
        code << "if #{ast_node_var}_.#{attr.name}.last.respond_to? :comments_"
        code.indent=4
        code << "#{ast_node_var}_.#{attr.name}.last.comments_=comments"
        code.indent=2
        code << "end"
        code << "comments=parse_comments()"
        code.indent=0
        code << "end"
      when Type
        if is_basic_type(type) #base types
          code << "#{ast_node_var}_.#{attr.name} = acceptIt"
        else
          code << "#{ast_node_var}_.#{attr.name} = parse#{type.name}()"
        end
      end
      return code
    end

    def is_basic_type type
      type.name.to_s.upcase==type.name.to_s
    end

    def compute_possible_starters type
      ret=[]
      sons=find_sons_of(type)
      starters= (sons << type).flatten
      ret=starters.collect{|starter| starter.name.to_s.downcase.to_sym}
      ret=ret.collect{|sym| (BASIC_TYPES.include? sym) ? (sym.to_s+"_lit").to_sym : sym}
    end
  end
end
