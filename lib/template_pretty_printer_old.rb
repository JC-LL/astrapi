require_relative '<%=mm.name.to_s.downcase%>_ast'
require_relative 'indent'
require_relative 'code'

module <%=mm.name%>

  class PrettyPrinter

    include Indent

    def print ast
      ast.accept(self)
    end

<%=visiting_methods%>
  end #class
end #module
