require_relative 'ast'
require_relative 'indent'
require_relative 'code'

module Astrapi

  class Visitor

    include Indent

    def visit ast
      ast.accept(self)
    end

    def visitModule modul,args=nil
      indent "visitModule"
      name=modul.name.accept(self)
      modul.classes.each{|k| k.accept(self)}
      dedent
    end

    def visitKlass klass,args=nil
      indent "visitKlass #{klass.name.sym}"
      klass.inheritance.accept(self)
      klass.attrs.each{|attr| attr.accept(self)}
      dedent
    end

    def visitAttr attr,args=nil
      indent "visitAttr"
      attr.name.accept(self)
      attr.type.accept(self)
      dedent
    end

    def visitType type,args=nil
      indent "visitType"
    end

    def visitArrayOf arrayOf,args=nil
      indent "visitArrayOf"
      arrayOf.type.accept(self)
      dedent
    end

    def visitIdentifier id,args=nil
      indent "visitIdentifier"
      say " - #{id.sym}"
      dedent
    end

  end
end
