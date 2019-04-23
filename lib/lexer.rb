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
    else
      raise "wrong type during lookahead"
    end
  end
end

module Astrapi

  class Lexer

    # I like explicit things :

    #................................................
    IDENT             = /\AIDENT/
    INT               = /\AINT/
    FLOAT             = /\AFLOAT/
    STRING            = /\ASTRING/
    #................................................
    MODULE            = /\Amodule$/
    CLASS             = /\Aclass$/
    END_              = /\Aend$/
    ATTR              = /\Aattr$/
    #................................................
    NEWLINE            = /[\n]/
    SPACE              = /[ \t]+/
    #.............punctuation........................
    LPAREN             = /\A\(/
    RPAREN             = /\A\)/
    COMMENT            = /\A\#(.*)/
    #.............operators..........................

    ARROW              = /\A\=\>/
    LBRACK             = /\A\[/
    RBRACK             = /\A\]/
    LT                 = /\A</
    # .............literals.........................
    IDENTIFIER         = /\A[a-zA-Z]+[a-zA-Z_0-9]*/i


    attr_accessor :suppress_comment

    def initialize str=''
      init(str)
      @suppress_space=true
      @suppress_comment=false
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
      when text = @ss.scan(COMMENT)
        next_token()
      when text = @ss.scan(ARROW)
        return Token.new [:arrow,text,position]
      when text = @ss.scan(LT)
        return Token.new [:lt,text,position]
      when text = @ss.scan(LBRACK)
        return Token.new [:lbrack,text,position]
      when text = @ss.scan(RBRACK)
        return Token.new [:rbrack,text,position]
      when text = @ss.scan(IDENTIFIER)
        case
        when value = text.match(IDENT)
          return Token.new [:IDENT,text,position]
        when value = text.match(FLOAT)
          return Token.new [:FLOAT,text,position]
        when value = text.match(INT)
          return Token.new [:INT,text,position]
        when value = text.match(STRING)
          return Token.new [:STRING,text,position]
        when value = text.match(MODULE)
          return Token.new [:module,text,position]
        when value = text.match(CLASS)
          return Token.new [:class,text,position]
        when value = text.match(END_)
          return Token.new [:end,text,position]
        when value = text.match(ATTR)
          return Token.new [:attr,text,position]
        when value = text.match(LPAREN)
          return Token.new [:lparen,text,position]
        when value = text.match(RPAREN)
          return Token.new [:rparen,text,position]
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
  lexer=Astrapi::Lexer.new
  tokens=lexer.tokenize(str)
  t2 = Time.now
  pp tokens
  puts "number of tokens : #{tokens.size}"
  puts "tokenized in     : #{t2-t1} s"
end
