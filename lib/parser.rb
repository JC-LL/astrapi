require 'pp'
require_relative 'lexer'
require_relative 'indent'
require_relative 'ast'

module Astrapi

  class Parser
    include Indent #helper methods mixed in

    attr_accessor :lexer,:tokens

    def initialize
      @verbose=true
      @lexer=Lexer.new
    end

    def parse filename
      str=IO.read(filename)
      @tokens=lexer.tokenize(str)
      @tokens=@tokens.select{|tok| tok.kind!=:comment}
      pp @tokens if @verbose
      parseModule
    end

    def acceptIt
      tok=tokens.shift
      say "consuming #{tok.val} (#{tok.kind})"
      tok
    end

    def showNext
      tokens.first
    end

    def expect kind
      if (actual=showNext.kind)!=kind
        abort "ERROR at #{showNext.pos}. Expecting #{kind}. Got #{actual}"
      else
        return acceptIt()
      end
    end

    def parseModule
      indent "parseModule"
      expect :module
      name=Identifier.new(expect :identifier)
      classes=[]
      while showNext.is_a? :class
        classes << parseClass
      end
      expect :end
      dedent
      return Astrapi::Module.new(name,classes)
    end

    def parseClass
      indent "parseClass"
      expect :class
      name=Identifier.new(expect :identifier)
      if showNext.is_a? :lt
        acceptIt
        inheritance= Identifier.new(expect :identifier)
      end
      attrs=[]
      while showNext.is_a? :attr
        attrs << parseAttr
      end
      expect :end
      dedent
      return Astrapi::Klass.new(name,inheritance,attrs)
    end

    def parseAttr
      indent "parseAttr"
      expect :attr
      name=Identifier.new(expect :identifier)
      expect :arrow
      type=parseAttrType
      dedent
      Attr.new(name,type)
    end

    def parseAttrType
      indent "parseAttrType"
      if showNext.is_a? [:IDENT,:FLOAT,:INT,:STRING]
        type=Type.new(Identifier.new(acceptIt))
      else
        type=Type.new(Identifier.new(expect :identifier))
      end
      if showNext.is_a? :lbrack
        acceptIt
        expect :rbrack
        type=ArrayOf.new(type)
      end
      dedent
      return type
    end

  end
end

if $PROGRAM_NAME == __FILE__
  filename=ARGV[0]
  raise "need a file !" if filename.nil?
  t1 = Time.now
  Astrapi::Parser.new.parse(filename)
  t2 = Time.now
  puts "parsed in     : #{t2-t1} s"
end
