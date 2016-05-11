# This module contains various normalization methods
module Normalization

  #This methods normalizes the strokes using bi moment
  #Params:
  #+strokes+:: [[[x1, y1], [x2, y2], ...], [[x1, y1], ...]]
  #+slant_correction+:: boolean whether a slant correction should be performed
  #returns normed_strokes, normed_strokes_with_slant_correction
  def bi_moment_normalize strokes, slant=false
    means, diffs, slant_angle = means_and_diffs strokes

    #calculating delta values
    delta = Proc.new do |diff, operator|
      #d_x or d_y
      #operator: >= or <
      accum = 0
      counter = 0

      diff.each do |d|
        if d.send operator, 0
          accum += d ** 2
          counter += 1
        end
      end
      accum / counter
    end

    new_strokes = []

    strokes.each do |stroke|
      new_stroke = []
      stroke.each do |point|
        x = point[0]
        y = point[1]
        x = x + (y - means[1]) * slant_angle if slant

        if x - means[0] >= 0
          new_x = ( @size * (x - means[0]) / (4 * Math.sqrt(delta.call(diffs[0], :>=))).round(2) ) + @size/2
        else
          new_x = ( @size * (x - means[0]) / (4 * Math.sqrt(delta.call(diffs[0], :<))).round(2) ) + @size/2
        end

        if y - means[1] >= 0
          new_y = ( @size * (y - means[1]) / (4 * Math.sqrt(delta.call(diffs[1], :>=))).round(2) ) + @size/2
        else
          new_y = ( @size * (y - means[1]) / (4 * Math.sqrt(delta.call(diffs[1], :<))).round(2) ) + @size/2
        end

        if new_x >= 0 && new_x <= @size && new_y >= 0 && new_y <= @size
          new_stroke << [new_x.round(3), new_y.round(3)]
        end
      end
      new_strokes << new_stroke unless new_stroke.empty?
    end
    new_strokes
  end

  private

  #This method calculates means and diffs of x and y coordinates in the strokes
  #The return values are used in the normalization step
  #means, diffs = means_and_diffs strokes
  #Return values:
  #+means+:: [mean_of_x, mean_of_y]
  #+diffs+:: differences of the x and y coordinates to their means i.e. [[d_x1, d_x2 ...], [d_y1, d_y2 ...]]
  def means_and_diffs strokes
    points = strokes.flatten(1)
    sums = points.inject([0, 0]){ |acc, point| acc = [acc[0] + point[0], acc[1] + point[1]] }
    #means = [x_c, y_c]
    means = sums.map{ |sum| (sum / points.length.to_f).round(2) }

    #for slant correction
    diff_x = []
    diff_y = []
    u11 = 0
    u02 = 0
    points.each do |point|
      diff_x << point[0] - means[0]
      diff_y << point[1] - means[1]

      u11 += (point[0] - means[0]) * (point[1] - means[1])
      u02 += (point[1] - means[1])**2
    end
    [means, [diff_x, diff_y], -1 * u11 / u02]
  end

end
