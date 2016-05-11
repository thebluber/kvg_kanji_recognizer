class Preprocessor
  include Normalization
  attr_accessor :smooth_weights, :interpolate_distance, :size, :smooth, :number_of_points
  def initialize interpolate_distance, size, smooth=true, smooth_weights=[1,2,3,2,1]
    @smooth = smooth
    @smooth_weights = smooth_weights
    @interpolate_distance = interpolate_distance
    @size = size
  end

  # preprocess steps bi moment size normalization, smooth and interpolate
  def preprocess strokes, slant=false
    bi_moment_normalize(strokes, slant).map do |stroke|
      stroke = smooth(stroke) if @smooth
      smooth(interpolate(stroke))
    end
  end

  #A simple smooth method using the following formula
  #p'(i) = (w(-M)*p(i-M) + ... + w(0)*p(i) + ... + w(M)*p(i+M)) / S
  #where the smoothed point is a weighted average of its adjacent points.
  #Only the user input should be smoothed, it is not necessary for kvg data.
  #Params:
  #+stroke+:: array of points i.e [[x1, y1], [x2, y2] ...]
  def smooth stroke
    offset = @smooth_weights.length / 2
    wsum = @smooth_weights.inject{ |sum, x|  sum + x}

    return stroke if stroke.length < @smooth_weights.length

    copy = stroke.dup

    (offset..(stroke.length - offset - 1)).each do |i|
      accum = [0, 0]

      @smooth_weights.each_with_index do |w, j|
        accum[0] += w * copy[i + j - offset][0]
        accum[1] += w * copy[i + j - offset][1]
      end

      stroke[i] = accum.map{ |acc| (acc / wsum.to_f).round(2) }
    end
    stroke
  end

  #This method interpolates points into a stroke with given distance
  #The algorithm is taken from the paper preprocessing techniques for online character recognition 
  def interpolate stroke
    current = stroke.first
    new_stroke = [current]

    index = 1
    last_index = 0
    while index < stroke.length do
      point = stroke[index]

      #only consider point with greater than d distance to current point
      if Math.euclidean_distance(current, point) < @interpolate_distance
        index += 1
      else

        #calculate new point coordinate
        new_point = []
        if point[0].round(2) == current[0].round(2) # x2 == x1
          if point[1] > current[1] # y2 > y1
            new_point = [current[0], current[1] + @interpolate_distance]
          else # y2 < y1
            new_point = [current[0], current[1] - @interpolate_distance]
          end
        else # x2 != x1
          slope = (point[1] - current[1]) / (point[0] - current[0]).to_f
          if point[0] > current[0] # x2 > x1
            new_point[0] = current[0] + Math.sqrt(@interpolate_distance**2 / (slope**2 + 1))
          else # x2 < x1
            new_point[0] = current[0] - Math.sqrt(@interpolate_distance**2 / (slope**2 + 1))
          end
          new_point[1] = slope * new_point[0] + point[1] - (slope * point[0])
        end

        new_point = new_point.map{ |num| num.round(2) }
        if current != new_point
          new_stroke << new_point

          current = new_point
        end
        last_index += ((index - last_index) / 2).floor
        index = last_index + 1
      end
    end

    new_stroke
  end

end
