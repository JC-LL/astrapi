require 'pp'
require_relative 'indent'
require_relative '<%=mm.name.to_s.downcase%>_lexer'
require_relative '<%=mm.name.to_s.downcase%>_ast'

module <%=mm.name%>

  class Parser
    include Indent #helper methods mixed in

    attr_accessor :lexer,:tokens

    def initialize
      @verbose=false
      @lexer=Lexer.new
    end

    def parse filename
      str=::IO.read(filename)
      @tokens=lexer.tokenize(str)
      last_pos = @tokens.last.pos
      @tokens << Token.new([:eos,'',last_pos])
      pp @tokens if @verbose
      parse<%=mm.classes.first.name%>
    end

    def acceptIt
      tok=tokens.shift
      say "consuming #{tok.val} (#{tok.kind})"
      tok
    end

    def showNext n=0
      tokens[n]
    end

    def expect kind
      if (actual=showNext.kind)!=kind
        abort "ERROR at #{showNext.pos}. Expecting #{kind}. Got #{actual}"
      else
        return acceptIt()
      end
    end

    def nil_maybe?
      if showNext.is_a?(:nil)
        return acceptIt
      else
        return nil
      end
    end

    def parse_comments
      ret=nil
      while showNext.is_a? :m3e_comment
        str||=""
        str << acceptIt.val
      end
      if str
        ret=Token.new([:comment,str,[0,0]])
      end
      ret
    end
<%=parsing_methods%>

  end
end
if $PROGRAM_NAME == __FILE__
  filename=ARGV[0]
  raise "need a file !" if filename.nil?
  t1 = Time.now
  <%=mm.name%>::Parser.new.parse(filename)
  t2 = Time.now
  puts "parsed in     : #{t2-t1} s"
end
