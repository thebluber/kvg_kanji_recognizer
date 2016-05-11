class Template
  extend Trainer
  #This method populates the datastore with parsed template patterns from the kanjivg file in xml format
  #Params:
  #+xml+:: download the latest xml release from https://github.com/KanjiVG/kanjivg/releases
  #+datastore+:: JSONDatastore or custom datastore type having methods store, persist!
  def self.parse_from_xml xml, datastore, kanji_list=[]
    file = File.open(xml) { |f| Nokogiri::XML(f) }

    file.xpath("//kanji").each do |kanji|
      #id has format: "kvg:kanji_CODEPOINT"
      codepoint = kanji.attributes["id"].value.split("_")[1]
      value = [codepoint.hex].pack("U")
      if kanji_list.empty?
        next unless codepoint.hex >= "04e00".hex && codepoint.hex <= "09faf".hex
      else
        next unless codepoint.hex >= "04e00".hex && codepoint.hex <= "09faf".hex && kanji_list.include?(value)
      end
      puts "#{codepoint} #{value}"

      # parse strokes
      strokes = kanji.xpath("g//path").map{|p| p.attributes["d"].value }.map{ |stroke| KvgParser::Stroke.new(stroke).to_a }

      strokes = preprocess(strokes)

      #Store to database
      #--------------
      character = {
        value: value,
        codepoint: codepoint.hex,
        number_of_strokes: strokes.count,
        codes: codes(strokes)
      }

      datastore.store character
    end

    datastore.persist!
  end
end
