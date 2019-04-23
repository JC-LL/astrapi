require 'pp'
require 'optparse'

require_relative 'dbg'
require_relative 'version'
require_relative 'parser'
require_relative 'checker'
require_relative 'pretty_printer'
require_relative 'dot_printer'
require_relative 'class_diagram_printer'
require_relative 'ruby_generator'

module Astrapi

  $options={
    :verbosity => 0
  }

  class Compiler

    include Dbg

    attr_accessor :mm

    def initialize
      puts "ASTRAPI meta-compiler for Sexp-based DSLs [version #{VERSION}] (c) J-C Le Lann 2016"
    end

    def analyze_options args

      args << "-h" if args.empty?

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: astrapi <file.mm> [options]"

        opts.on("-p", "--parse", "[P]arsing  only. AST generated internally") do |n|
          $options[:parse_only]=true
          $options[:verbosity]=2
        end

        opts.on("-c", "--check", "[C]hecking only. Semantic/contextual analysis ") do |n|
          $options[:check_only]=true
        end

        opts.on("--pp", "Pretty-print back the Astrapi code") do |n|
          $options[:pp_only]=true
        end

        opts.on("--version", "Prints version") do |n|
          puts VERSION
          abort
        end

        targets=[:ruby,:java,:python,:cpp]
        opts.on("--lang TARGET", "Target LANGUAGE (ruby by default,java,python,cpp)",targets) do |lang|
          case lang
          when :ruby
            $options[:target_language]=lang
          when :java,:python,:cpp
            raise "#{lang} version not implemented yet. Sorry"
            $options[:target_language]=lang
          else
            raise "illegal target language #{lang}"
          end
        end

        opts.on("-v LEVEL", "--verbose level", "allow verbose levels (0,1)") do |level|
          $options[:verbosity]=level.to_i
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          puts ">> visit Astrapi page on https://github.com/JC-LL/astrapi <<"
          exit
        end
      end

      begin
        opt_parser.parse!(args)
      rescue Exception => e
        puts e
        dbg 0,e.backtrace if $options[:verbosity]>2
        exit
      end
      # remaining ARGV (remind that parse! has removed everything else)
      filename = ARGV.pop
      unless filename
        dbg 0,"Need to specify a filename to process"
        exit
      end
      return filename
    end

    def compile mm_filename
      @mm=parse(mm_filename)
      pretty_print
      dot_print
      check
      generate_class_diagram
      generate_ruby
    end

    def parse mm_filename
      puts "==> parsing metamodel.................... #{mm_filename}"
      ast=Astrapi::Parser.new.parse(mm_filename)
      exit if $options[:parse_only]
      ast
    end

    def pretty_print
      target="#{mm.name.to_s.downcase}_pp.mm"
      puts "==> pretty print metamodel............... #{target}"
      code=PrettyPrinter.new.print(mm)
      code.save_as(target,verbose=false)
      exit if $options[:pp_only]
    end

    def check
      puts "==> checking metamodel"
      Checker.new.check(mm)
    end

    def generate_class_diagram
      target="#{mm.name.to_s.downcase}_class_diagram.dot"
      puts "==> generating class diagram............. #{target}"
      code=ClassDiagramPrinter.new.print(mm)
      code.save_as(target,verbose=false)
    end

    def dot_print
      target="#{mm.name.to_s.downcase}_ast.dot"
      puts "==> generate dot for metamodel........... #{target}"
      code=DotPrinter.new.print(mm)
      code.save_as(target,verbose=false)
    end

    def generate_ruby
      puts "==> generate software stack for DSL '#{@mm.name}'. Ruby version"
      RubyGenerator.new.generate(mm)
    end

  end
end

if $PROGRAM_NAME == __FILE__
  filename=ARGV[0]
  raise "need a file !" if filename.nil?
  t1 = Time.now
  Astrapi::Compiler.new.compile(filename)
  t2 = Time.now
  puts "compiled in     : #{t2-t1} s"
end
