# kvg_kanji_recognizer
This kanji handwriting recognizer, which is dependent of the correct stroke order and stroke numbers, uses the [KanjiVG](https://github.com/KanjiVG/kanjivg) data as templates. As the first step, a kanji is translated into a code sequence as shown in the graphs.
[image](./encoder.svg?raw=true)
[image](./sample_kyo.svg?raw=true)
The code sequence of 京 is "6161B1556".

The recognizer uses levenshtein distance to calculate the difference between 2 code sequences.

## Usage

Setup and run server on port 9292
```ruby
$ git clone https://github.com/thebluber/kvg_character_recognition_api

$ bundle install

$ bundle exec rackup
```
Test the API
```ruby
$ curl -X POST -H "Content-Type: application/json" -d @strokes.json http://localhost:9292/api/v1/scores

=> {"scores":["二","匚","匸","工","冫","厂","汀","江","辶","冂"]}
```

