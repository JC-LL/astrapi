require_relative 'ast'
require_relative 'visitor'
require_relative 'code'

module Astrapi

  class Checker < Visitor

    # the checker checks  :
    # - that classes are uniquely defined
    # - that attrs are uniquely defined withing a given class
    # - that attrs types are defined in the metamodel
    attr_accessor :mm

    def check ast
      @verbose=false
      @mm=ast
      ast.accept(self)
    end

    def visitModule modul,args=nil
      indent "visitModule"
      name=modul.name.accept(self)
      modul.classes.each{|k| k.accept(self)}
      dedent
    end

    def visitKlass klass,args=nil
      indent "visitKlass #{klass.name}"
      if klass.inheritance

      end
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
      dedent
    end

    def visitArrayOf arrayOf,args=nil
      indent "visitArrayOf"
      arrayOf.type.accept(self)
      dedent
    end

    def visitIdentifier id,args=nil
      indent "visitIdentifier"
      say " - #{id}"
      dedent
    end
  end
end
