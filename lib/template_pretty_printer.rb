require 'pp'
require_relative '<%=mm.name.to_s.downcase%>_ast'
require_relative 'indent'
require_relative 'code'

module <%=mm.name%>

  class PrettyPrinter

    include Indent

    def print ast
      ary=ast.accept(self)
      str=prpr(ary)
    end

    def prpr ary
      print_rec(ary).lstrip
    end

    def print_rec ary,indent=0
      str=""
      case e=ary
      when Array
        str << "\n"
        if e.first.to_s.start_with? "#"
          str << " "*indent+ary.shift+"\n"
        end
        str << " "*indent+"("
        ary.each do |e|
          str << print_rec(e,indent+2)
        end
        if ary.last.is_a? Array
          str << "\n"+" "*indent+")"
        else
          str<< "\b)"
        end
      else
        str << e.to_s+ " "
      end
      return str
    end

<%=visiting_methods%>
  end #class
end #module
