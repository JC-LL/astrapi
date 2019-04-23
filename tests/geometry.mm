module Geometry
 
  class Scene 
    attr name => IDENT
    attr elements => Shape[]
  end
 
  class Shape 
    attr id => IDENT
    attr position => Position
  end
 
  class Square < Shape
    attr size => Size
  end
 
  class Circle < Shape
    attr radius => Size
  end
 
  class Rectangle < Shape
    attr size => Size
  end
 
  class Size 
    attr dims => INTEGER[]
  end
 
  class Position 
    attr coord => INTEGER[]
  end
 
end
