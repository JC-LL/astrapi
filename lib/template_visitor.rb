require_relative '<%=mm.name.to_s.downcase%>_ast'
require_relative 'indent'
require_relative 'code'

module <%=mm.name%>

  class Visitor

    include Indent

    def visit ast
      @verbose=true
      ast.accept(self)
    end

<%=visiting_methods%>
  end #class
end #module
