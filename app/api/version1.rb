module API
  class Version1 < Grape::API
    include API::Defaults
    version 'v1'

    desc 'Return scores calculated for given input strokes'
    params do
      requires :strokes, type: String
      requires :n_best, type: Integer
    end
    post 'scores' do
      strokes = JSON.parse(params[:strokes])

      start = Time.now
      scores = Recognizer.scores(strokes, DATASTORE).take params[:n_best]

      { scores: scores.map{ |score| score.last[:value] }, time: Time.now - start }
    end

  end
end
