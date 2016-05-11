# kvg_kanji_recognizer
This kanji handwriting recognizer, which is dependent of the correct stroke order and stroke numbers, uses the [KanjiVG](https://github.com/KanjiVG/kanjivg) data as templates. As the first step, a kanji is translated into a code sequence as shown in the graphs.

![image](https://raw.githubusercontent.com/thebluber/kvg_kanji_recognizer/master/encoder.png?raw=true)
![image](https://raw.githubusercontent.com/thebluber/kvg_kanji_recognizer/master/sample_kyo.png)

The code sequence of 京 is "6161B1556".

The recognizer uses levenshtein distance to calculate the difference between 2 code sequences.

## Usage
Install the levenshtein method, which is a Ruby native extension
```ruby
$ git clone https://github.com/thebluber/kvg_kanji_recognizer

$ cd levenshtein

$ make install
```
Setup and run server on port 9292
```ruby
$ bundle install

$ bundle exec rackup
```
Test the API
```ruby
$ curl -X POST -H "Content-Type: application/json" -d @strokes.json http://localhost:9292/api/v1/scores

=> {"scores":["二","冫","于","土","士","工","干","七","下","丶"]}
```

