module Trainer
  @@config = { downsample_rate: 9,
               interpolate_distance: 0.8,
               size: 109,
               smooth: true,
               smooth_weights: [1,2,3,2,1],
               encoder_length_thr: 10
  }
  @@preprocessor = Preprocessor.new(@@config[:interpolate_distance],
                                    @@config[:size],
                                    @@config[:smooth],
                                    @@config[:smooth_weights])

  # preprocess strokes and set the number_of_points variable
  # !the preprocessed strokes are not downsampled
  def preprocess strokes, slant=false
    strokes = @@preprocessor.preprocess(strokes, slant)
    strokes
  end

  # This method returns code sequence
  def codes strokes
    s = strokes.map{ |stroke| downsample(stroke, @@config[:downsample_rate]) }
    Encoder.new(s, @@config[:encoder_length_thr]).codes
  end
  private
  #This methods downsamples a stroke in given interval
  #The number of points in the stroke will be reduced
  def downsample stroke, interval
    stroke.each_slice(interval).map(&:first)
  end
end
