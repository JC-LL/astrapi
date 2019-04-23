require_relative '<%=mm.name.to_s.downcase%>_parser'
require_relative '<%=mm.name.to_s.downcase%>_pp'
require_relative '<%=mm.name.to_s.downcase%>_ast_printer'
require_relative '<%=mm.name.to_s.downcase%>_visitor'

module <%=mm.name%>

  class Compiler
    attr_accessor :ast

    def initialize
      puts "<%=mm.name%> compiler"
    end

    def compile filename
      @ast=parse(filename)
      visit
      pretty_print
      dot_print
    end

    def parse filename
      @filename=filename
      name,@suffix=filename.split("/").last.split(".")
      @basename=File.basename(filename,"."+@suffix)
      puts "==> parsing #{filename}"
      <%=mm.name%>::Parser.new.parse(filename)
    end

    def visit
      puts "==> dummy visit"
      <%=mm.name%>::Visitor.new.visit(ast)
    end

    def pretty_print
      target="#{@basename}_pp.#{@suffix}"
      puts "==> pretty print to ............ #{target}"
      code_str=<%=mm.name%>::PrettyPrinter.new.print(ast)
      File.open("#{target}",'w'){|f| f.puts code_str}
    end

    def dot_print
      target="#{@basename}.dot"
      puts "==> generate dot for AST in .... #{target}"
      code=<%=mm.name%>::DotPrinter.new.print(ast)
      code.save_as(target,verbose=false)
    end

  end
end

if $PROGRAM_NAME == __FILE__
  filename=ARGV[0]
  raise "need a <%=mm.name%> file !" if filename.nil?
  t1 = Time.now
  <%=mm.name%>::Compiler.new.compile(filename)
  t2 = Time.now
  puts "compiled in     : #{t2-t1} s"
end
