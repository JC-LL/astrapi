require_relative 'ast'
require_relative 'indent'
require_relative 'code'

module Astrapi

  class ClassDiagramPrinter

    include Indent

    DECL_FOR_INSTRINSICS={
      :IDENT   => "IDENT[label=\"{IDENT|+kind\n+val\n+pos\n\}\"]",
      :FLOAT   => "FLOAT[label=\"{FLOAT|+kind\n+val\n+pos\n\}\"]",
      :INTEGER => "INTEGER[label=\"{INTEGER|+kind\n+val\n+pos\n\}\"]",
      :STRING  => "STRING[label=\"{STRING|+kind\n+val\n+pos\n\}\"]",
      :FRAC    => "FRAC[label=\"{FRAC|+kind\n+val\n+pos\n\}\"]",
      :NIL     => "NIL[label=\"{NIL|+kind\n+val\n+pos\n\}\"]"
    }

    def print ast
      ast.accept(self)
    end

    def visitModule modul,args=nil
      indent "visitModule"

      decl=Code.new # declarations of nodes
      modul.classes.collect do |k|
        attrs_str=k.attrs.collect{|attr| "+ #{attr.name}\\n"}
        decl << "#{k.name}[label = \"{#{k.name}|#{attrs_str.join()}|...}\"]"
      end
      cnx=Code.new  #connexions
      modul.classes.each{|k| cnx << k.accept(self)}
      #................................................................
      code=Code.new
      code << "digraph hierarchy {"
      code << " size=\"5,5\""
      #code << " splines=ortho"
      code << " node[shape=record,style=filled,fillcolor=gray95]"
      code << " edge[dir=back, arrowtail=empty]"
      code.newline
      code.indent=2
      code << decl
      code << cnx
      code.indent=0
      code << "}"
      dedent
      return code
    end

    def visitKlass klass,args=nil
      indent "visitKlass"
      code = Code.new
      klass.attrs.each do |attr|
        case type=attr.type
        when ArrayOf
          sink=type.type.name.to_s
          head="label=\"*\""
        when Type
          sink=type.name.to_s
          head="label=1"
          code << DECL_FOR_INSTRINSICS[sink.to_sym] if is_instrinsic(type)
        end
        code << "#{klass.name} -> #{sink}[#{head},arrowtail=diamond]"
      end
      if klass.inheritance
        code << "#{klass.inheritance} -> #{klass.name}"
      end
      dedent
      code
    end

    def is_instrinsic type
      if type.respond_to? :type
        str=type.type.name.to_s
        return str==str.upcase
      else
        str=type.name.to_s
        return str==str.upcase
      end
    end
  end
end
