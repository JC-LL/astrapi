module Astrapi
  module Dbg
  	def dbg level,str
  		puts str if $options[:verbosity]>=level
  	end
  end
end
