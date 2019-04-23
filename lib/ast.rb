module Astrapi

  class Ast
    def accept(visitor, arg=nil)
      name = self.class.name.split(/::/)[1]
      visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
    end
  end

  class Module < Ast
    attr_accessor :name,:classes
    def initialize name,classes=[]
      @name,@classes=name,classes
    end
  end

  class Klass < Ast
    attr_accessor :name,:inheritance,:attrs
    def initialize name,inheritance=nil,attrs=[]
      @name,@inheritance,@attrs=name,inheritance,attrs
    end
  end

  class Attr < Ast
    attr_accessor :name,:type
    def initialize name,type
      @name,@type=name,type
    end
  end

  class Type < Ast
    attr_accessor :name
    def initialize name
      @name=name
    end

    def ==(other)
      name==other.name
    end
  end

  class ArrayOf < Type
    attr_accessor :type
    def initialize type
      @type=type
    end
  end

  #..............................
  class Identifier < Ast
    def initialize tok
      @tok=tok
    end

    def str
      @tok.val.to_s
    end

    def to_s
      str
    end

    def ==(other)
      str==other.str
    end
  end

end
