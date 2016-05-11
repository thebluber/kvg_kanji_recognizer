module Math
  #Add euclidean distance method to ruby Math module
  #This methods calculates the euclidean distance between 2 points
  #Params:
  #- p1, p2: [x, y]
  def self.euclidean_distance(p1, p2)
    sum_of_squares = 0
    p1.each_with_index do |p1_coord,index|
      sum_of_squares += (p1_coord - p2[index]) ** 2
    end
    Math.sqrt( sum_of_squares )
  end
end
