class Recognizer
  extend Trainer
  def self.scores strokes, datastore
    strokes = preprocess(strokes)
    codes = codes(strokes)
    templates = datastore.select_templates((strokes.count - 3)..(strokes.count + 3))

    scores = templates.map do |cand|
      score = levenshtein(codes, cand[:codes])
      [score, cand]
    end

    scores.sort{ |a, b| a[0] <=> b[0] }

  end
end
