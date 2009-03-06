#!/usr/bin/env ruby
require 'yaml'

MARKS = File.expand_path("~/.jumprc")

class Jumpr
  class << self
    def load(file)
      @rc = file
      @marks = YAML.load(File.read(file)) || {}
    end

    def add(mark, target)
      @marks[mark] = File.expand_path(target)
      dump
    end

    def jump(expr)
      expr = Regexp.new(expr, Regexp::IGNORECASE)
      matches = @marks.select {|k,v| k =~ expr }
      if matches.size.zero?
        puts "No matches."
      elsif matches.size == 1
        puts matches.first.last
      else
        puts "Multiple matches:"
        list_matches(matches)
      end
    end

    def list
      list_matches(@marks)
    end
    
    private
    def dump
      File.open(@rc, "w+") {|f| f.write YAML.dump(@marks) }
    end

    def list_matches(matches)
      matches.each do |mark,target|
        puts "#{mark}: #{target}"
      end
    end
  end
end
File.open(MARKS, "w+") {|f| f.write "--- {}"} unless File.exist? MARKS
begin
  Jumpr.load(MARKS)

  if mark = ARGV[0]
    case mark
      when /^@/
        if target = ARGV[1]
          Jumpr.add(mark[1..-1], target)
        else 
          raise ArgumentError, "Target missing." 
        end

      when /\A--list\Z/
        Jumpr.list

      else
        Jumpr.jump(mark)
    end
  else
    raise ArgumentError, "j mark | @mark target | --list"  
  end
rescue => e
  puts e.message
  exit 1
end
