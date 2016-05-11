#This module contains classes which can be used to parse a svg command
#The code is copied from https://github.com/rogerbraun/KVG-Tools
#Methods for generating sexp or xml outputs are removed
module KvgParser
  #A Point
  class Point
    attr_accessor :x, :y, :color

    def initialize(x,y, color = :black)
      @x,@y, @color = x, y, color
    end

    #Basic point arithmetics
    def +(p2)
      return Point.new(@x + p2.x, @y + p2.y)
    end

    def -(p2)
      return Point.new(@x - p2.x, @y - p2.y)
    end

    def dist(p2)
      return Math.sqrt((p2.x - @x)**2 + (p2.y - @y)**2)
    end

    def *(number)
      return Point.new(@x * number, @y * number)
    end

    #to array
    def to_a
      [@x.round(2), @y.round(2)]
    end

  end

  # SVG_M represents the moveto command. 
  # SVG Syntax is:
  # m x y
  # It sets the current cursor to the point (x,y).
  # As always, capitalization denotes absolute values.
  # Takes a Point as argument.
  # If given 2 Points, the second argument is treated as the current cursor.
  class SVG_M

    def initialize(p1, p2 = Point.new(0,0))
      @p = p1 + p2
    end

    def to_points
      return []
    end

    def current_cursor
      return @p
    end

  end

  # SVG_C represents the cubic Bézier curveto command. 
  # Syntax is:
  # c x1 y1 x2 y2 x y
  # It sets the current cursor to the point (x,y).
  # As always, capitalization denotes absolute values.
  # Takes 4 Points as argument, the fourth being the current cursor
  # If constructed using SVG_C.relative, the current cursor is added to every
  # point.
  class SVG_C

    def initialize(c1,c2,p,current_cursor)
      @c1,@c2,@p,@current_cursor = c1,c2,p,current_cursor
      @@c_color = :green
    end

    def SVG_C.relative(c1,c2,p,current_cursor)
      SVG_C.new(c1 + current_cursor, c2 + current_cursor, p + current_cursor, current_cursor)
    end

    def second_point
      @c2
    end

    # This implements the algorithm found here:
    # http://www.cubic.org/docs/bezier.htm
    # Takes 2 Points and a factor between 0 and 1
    def linear_interpolation(a,b,factor)

      xr = a.x + ((b.x - a.x) * factor)
      yr = a.y + ((b.y - a.y) * factor)

      return Point.new(xr,yr);

    end

    def switch_color
      if @@c_color == :green
        @@c_color = :red
      elsif @@c_color == :red
        @@c_color = :purple
      else
        @@c_color = :green
      end
    end

    def make_curvepoint(factor)
      ab = linear_interpolation(@current_cursor,@c1,factor)
      bc = linear_interpolation(@c1,@c2,factor)
      cd = linear_interpolation(@c2,@p,factor)

      abbc = linear_interpolation(ab,bc,factor)
      bccd = linear_interpolation(bc,cd,factor)
      return linear_interpolation(abbc,bccd,factor)
    end

    def length(points)
      old_point = @current_cursor;
      length = 0.0
      factor = points.to_f

      (1..points).each {|point|
        new_point = make_curvepoint(point/(factor.to_f))
        length += old_point.dist(new_point)
        old_point = new_point
      }
      return length
    end

    # This gives back an array of points on the curve. The argument given
    # denotes how the distance between each point.
    def make_curvepoint_array(distance)
      result = Array.new

      l = length(20)
      points = l * distance
      factor = points.to_f

      (0..points).each {|point|
        result.push(make_curvepoint(point/(factor.to_f)))
      }

      return result
    end


    def to_points
      return make_curvepoint_array(0.3)
    end

    def current_cursor
      @p
    end

  end

  # SVG_S represents the smooth curveto command. 
  # Syntax is:
  # s x2 y2 x y
  # It sets the current cursor to the point (x,y).
  # As always, capitalization denotes absolute values.
  # Takes 3 Points as argument, the third being the current cursor
  # If constructed using SVG_S.relative, the current cursor is added to every
  # point.
  class SVG_S < SVG_C

    def initialize(c2, p, current_cursor,previous_point)
      super(SVG_S.reflect(previous_point,current_cursor), c2, p, current_cursor)
    end

    # The reflection in this case is rather tricky. Using SVG_C.relative, the
    # offset of current_cursor is added to all the positions (except current_cursor).
    # The reflected point, however is already calculated in absolute values.
    # Because of this, we have to subtract the current_cursor from the reflected 
    # point, as it is already added later. I think I got the classes somewhat wrong.
    # Maybe points should get a field whether they are absolute oder relative?
    # Don't know yet. It works now, though!
    def SVG_S.relative(c2, p, current_cursor, previous_point)
      SVG_C.relative(SVG_S.reflect(previous_point,current_cursor) - current_cursor, c2, p, current_cursor)
    end

    def SVG_S.reflect(p, mirror)
      return mirror + (mirror - p)
    end

  end


  # Stroke represent one stroke, which is a series of SVG commands.
  class Stroke
    COMMANDS = ["M", "C", "c", "s", "S"]

    def initialize(stroke_as_code)
      @command_list = parse(stroke_as_code) 
    end

    def to_points
      return @command_list.map{|element| element.to_points}.flatten
    end

    #to array
    #TODO: better implementation using composite pattern
    def to_a
      to_points.map{|point| point.to_a}
    end

    def split_elements(line)
      # This is magic.
      return line.gsub("-",",-").gsub("s",",s,").gsub("S",",S,").gsub("c",",c,").gsub("C",",C,").gsub("m", "M").gsub("M","M,").gsub("[","").gsub(";",",;,").gsub(",,",",").gsub(" ,", ",").gsub(", ", ",").gsub(" ", ",").split(/,/);
    end

    def parse(stroke_as_code)
      elements = split_elements(stroke_as_code).delete_if{ |e| e == "" }  
      command_list = Array.new
      current_cursor = Point.new(0,0);

      while elements != [] do

        case elements.slice!(0)
        when "M"
          x,y = elements.slice!(0..1)
          m = SVG_M.new(Point.new(x.to_f,y.to_f))
          current_cursor = m.current_cursor
          command_list.push(m)

        when "C"
          x1,y1,x2,y2,x,y = elements.slice!(0..5)
          c = SVG_C.new(Point.new(x1.to_f,y1.to_f), Point.new(x2.to_f,y2.to_f), Point.new(x.to_f,y.to_f), current_cursor)
          current_cursor = c.current_cursor
          command_list.push(c)

          #handle polybezier
          unless elements.empty? || COMMANDS.include?(elements.first)
            elements.unshift("C")
          end
        when "c"
          x1,y1,x2,y2,x,y = elements.slice!(0..5)
          c = SVG_C.relative(Point.new(x1.to_f,y1.to_f), Point.new(x2.to_f,y2.to_f), Point.new(x.to_f,y.to_f), current_cursor)
          current_cursor = c.current_cursor
          command_list.push(c)

          #handle polybezier
          unless elements.empty? || COMMANDS.include?(elements.first)
            elements.unshift("c")
          end

        when "s"
          x2,y2,x,y = elements.slice!(0..3)
          reflected_point = command_list[-1].second_point
          s = SVG_S.relative(Point.new(x2.to_f,y2.to_f), Point.new(x.to_f,y.to_f), current_cursor, reflected_point)
          current_cursor = s.current_cursor
          command_list.push(s)

        when "S"
          x2,y2,x,y = elements.slice!(0..3)
          reflected_point = command_list[-1].second_point
          s = SVG_S.new(Point.new(x2.to_f,y2.to_f), Point.new(x.to_f,y.to_f), current_cursor,reflected_point)
          current_cursor = s.current_cursor
          command_list.push(s)

        else
          #print "You should not be here\n"

        end

      end

      return command_list
    end

  end
end
