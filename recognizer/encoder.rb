class Encoder
  attr_accessor :codes
  def initialize strokes, length_threshold
    @length_threshold = length_threshold
    @codes = strokes.map{ |stroke| translate(compress(stroke)) }.join
  end

  # compress stroke so that it is only represented by start, end and a direction change point
  # this dcp must have greater distance to line (start, end) than threshold
  def compress(stroke, angle_threshold=30)
    new_stroke = [stroke.first]
    #step1: take 3 points
    first = 0
    last = 2

    while last < stroke.length do
      # reference vector
      compare = [stroke[last][0] - stroke[first][0], stroke[last][1] - stroke[first][1]]

      ((first + 1)..last).each do |i|
        curr_v = [stroke[i][0] - stroke[i-1][0], stroke[i][1] - stroke[i-1][1]]
        next if angle(compare, curr_v).abs < angle_threshold || point_distance(stroke.first, stroke.last, stroke[last-1]) < @length_threshold

        new_stroke << stroke[last-1]
        first = last
        last = first + 1
        break
      end
      last += 1
    end
    new_stroke << stroke.last
    new_stroke
  end

  def translate(stroke)
    if stroke.count > 2
      translate_complex_type(stroke)
    else
      translate_simple_type(stroke)
    end
  end
  # complex type contains a simple_type direction code and a position code for the direction change points
  def translate_complex_type(stroke)
    direction_code = translate_simple_type(stroke)
    position_code =  point_position(stroke.first, stroke.last, stroke[1]) ? "A" : "B"
    [direction_code, position_code]
  end

  # translate a stroke which contains 2 points to a code
  def translate_simple_type(stroke)
    #e1 = [1, 0]
    #angle between vector v and e1
    #det = x1*y2 - x2*y1
    #dot = x1*x2 + y1*y2
    #atan2(det, dot) in range 0..180 and 0..-180
    det = stroke.last[1] - stroke.first[1]
    dot = stroke.last[0] - stroke.first[0]
    angle = (Math.atan2(det, dot) / (Math::PI / 180)).floor

    # 6 types are defined
    # 1: (20, -30)
    # 2: (-31, -90)
    # 3: (-91, -169)
    # 4: (-170, -180)/(180, 150)
    # 5: (149, 80)
    # 6: (79, 21)
    if (-30..20).cover?(angle)
      return 1
    elsif (-90..-31).cover?(angle)
      return 2
    elsif (-169..-91).cover?(angle)
      return 3
    elsif (150..180).cover?(angle) || (-180..-170).cover?(angle)
      return 4
    elsif (80..149).cover?(angle)
      return 5
    elsif (21..79).cover?(angle)
      return 6
    else
      raise "Something is wrong in translating stroke into code sequence"
    end
  end

  private
  #http://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
  # sign of determinant
  # 0: on the line
  # +1: left/above
  # -1: right/below
  def point_position(a, b, p)
    (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]) > 0
  end

  #http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html
  def point_distance(a, b, p)
    #((b[1] - a[1]) * p[0] + (b[0] - a[0]) * p[1] + b[0] * a[1] - b[1] * a[0]).abs / Math.sqrt((b[1] - a[1])**2 + (b[0] - a[0])**2)
    ((b[0] - a[0]) * (a[1] - p[1]) - (a[0] - p[0]) * (b[1] - a[1])).abs / Math.sqrt((b[1] - a[1])**2 + (b[0] - a[0])**2)
  end

  # calculate internal angle between v1 and v2 clockwise
  def angle v1, v2
    #det = x1*y2 - x2*y1
    #dot = x1*x2 + y1*y2
    #atan2(det, dot) in range 0..180 and 0..-180
    det = v1[0] * v2[1] - (v2[0] * v1[1])
    dot = v1[0] * v2[0] + (v2[1] * v1[1])
    Math.atan2(det, dot) / (Math::PI / 180)
  end
end
