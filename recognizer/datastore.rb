class JSONDatastore
  attr_accessor :data
  def initialize filename = 'characters.json'
    @data = load_file(filename)
    @filename = filename
  end

  def load_file filename
    begin
      JSON.parse(File.read(filename, encoding: 'utf-8'), symbolize_names: true)
    rescue
      puts "WARNING: Can't load file, returning empty character collection."
      []
    end
  end

  def characters_in_range point_range, stroke_range
    @data.select { |character| point_range === character[:number_of_points] && stroke_range === character[:number_of_strokes] }
  end

  def select_templates stroke_range
    @data.select { |character| stroke_range === character[:number_of_strokes] }
  end

  def store character
    @data.push character
  end

  def persist!
    dump @filename
  end

  def dump filename
    File.write(filename, @data.to_json)
  end
end
