require 'pp'
require 'strscan'
#require 'benchmark'

class Token
  attr_accessor :kind,:val,:pos
  def initialize tab
    @kind,@val,@pos=*tab
  end

  def is_a? kind
    case kind
    when Symbol
      return @kind==kind
    when Array
      for sym in kind
        return true if @kind==sym
      end
      return false
    when Class
      return kind==Token
    else
      raise "wrong type for token test"
    end
  end

  def accept dummy,args=nil
    val
  end
end

module <%=mm.name%>

  class Lexer
    #................................................
    NEWLINE            = /[\n]/
    SPACE              = /[ \t]+/
    #.............punctuation........................
    LPAREN             = /\A\(/
    RPAREN             = /\A\)/
    COMMENT            = /\A\#(.*)/
    # .............M3E specific literals.............
    IDENT              = /\A[a-zA-Z]+[0-9a-zA-Z_]*/i
    FLOAT              = /\A[0-9]+\.[0-9]+/
    FRAC               = /\A[0-9]+\/[0-9]+/
    INTEGER            = /\A[0-9]+/
    RANGE              = /\A#{INTEGER}\.\.#{INTEGER}/
    STRING             = /\A\"(.*)\"/ # need to check!
    NIL                = /\Anil/
    TRUE               = /\A\true/
    FALSE              = /\Afalse/
    #..............DSL keywords......................
<%=keywords_regexp%>

    def initialize str=''
      init(str)
    end

    def init str
      @ss=StringScanner.new(str)
      @line=0
    end

    def tokenize str
      @tokens=[]
      init(str)
      until @ss.eos?
        @tokens << next_token()
      end
      return @tokens[0..-2]
    end

    #next token can detect spaces length
    def next_token

      if @ss.bol?
        @line+=1
        @old_pos=@ss.pos
      end

      position=[@line,@ss.pos-@old_pos+1]

      return :eos if @ss.eos?

      case
      when text = @ss.scan(NEWLINE)
        next_token()
      when text = @ss.scan(SPACE)
        next_token()
      when text = @ss.scan(LPAREN)
        return Token.new [:lparen,text,position]
      when text = @ss.scan(COMMENT)
        return Token.new [:m3e_comment,text,position]
      when text = @ss.scan(RPAREN)
        return Token.new [:rparen,text,position]
      when text = @ss.scan(FLOAT)
        return Token.new [:float_lit,text,position]
      when text = @ss.scan(FRAC)
        return Token.new [:frac_lit,text,position]
      when text = @ss.scan(RANGE)
        return Token.new [:range_lit,text,position]
      when text = @ss.scan(INTEGER)
        return Token.new [:integer_lit,text,position]
      when text = @ss.scan(STRING)
        return Token.new [:string_lit,text,position]
      when text = @ss.scan(FRAC)
        return Token.new [:frac_lit,text,position]
      when text = @ss.scan(IDENT)
        case
<%=apply_regexp%>
        when value = text.match(NIL)
          return Token.new [:nil,text,position]
        when value = text.match(TRUE)
          return Token.new [:true,text,position]
        when value = text.match(FALSE)
          return Token.new [:false,text,position]
        else
          return Token.new [:identifier,text,position]
        end
      else
        x = @ss.getch
        return Token.new [x, x,position]
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  str=IO.read(ARGV[0])
  #str.downcase!
  puts str
  t1 = Time.now
  lexer=<%=mm.name%>::Lexer.new
  tokens=lexer.tokenize(str)
  t2 = Time.now
  pp tokens
  puts "number of tokens : #{tokens.size}"
  puts "tokenized in     : #{t2-t1} s"
end
