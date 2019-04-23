require_relative 'ast'
require_relative 'indent'
require_relative 'code'

module Astrapi

  class PrettyPrinter

    include Indent

    def print ast
      ast.accept(self)
    end

    def visitModule modul,args=nil
      indent "visitModule"
      code=Code.new
      code << "module #{name=modul.name}"
      code.newline
      code.indent=2
      modul.classes.each{|k| code << k.accept(self) ; code.newline}
      code.indent=0
      code << "end"
      dedent
      return code
    end

    def visitKlass klass,args=nil
      indent "visitKlass"
      code = Code.new
      inherit="< #{klass.inheritance}" if klass.inheritance
      code << "class #{klass.name} #{inherit}"
      code.indent=2
      klass.attrs.each{|attr| code << attr.accept(self)}
      code.indent=0
      code << "end"
      dedent
      code
    end

    def visitAttr attr,args=nil
      indent "visitAttr"
      type=attr.type.accept(self)
      str="attr #{attr.name} => #{type}"
      dedent
      str
    end

    def visitType type,args=nil
      indent "visitType"
      dedent
      return type.name.to_s
    end

    def visitArrayOf arrayOf,args=nil
      indent "visitArrayOf"
      str="#{arrayOf.type.name}[]"
      dedent
      return str
    end

    def visitIdentifier id,args=nil
      indent "visitIdentifier"
      dedent
    end

  end
end
