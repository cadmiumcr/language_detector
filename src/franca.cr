require "cadmium"
require "json"

module Franca
  VERSION = "0.1.0"

  @@expressions : NamedTuple(Symbol, Regex)

  @@languages : Hash(Symbol, Array(String))

  @@data : Hash(String, Array(Hash(String, String))) = File.read("../data/data.json").from_json.to_h

  def detect(text : String) : String
    detect_all(text)[0][0]
  end

  def detect_all(text : String) : Array(Array(String, Int32))
    expression = get_top_expression(text, @@expressions)
    return single_language_tuples(expression[0]) if !@@data.includes?(expression[0])
    normalize(text, get_distances(Cadmium.ngrams.new.trigrams(text), data[expression[0]]))
  end

  # Create a single tuple as a list of tuples from a given
  # language code. ???????????????????????????????
  def single_language_tuples(language)
    [[language, 1]]
  end

  def normalize(text : String, distances : Array(Hash(String, Int32)))
    min = distances[0].value
    max = text.size * 300 - min

    distances.each do |distance|
      distances[distance] = 1 - (distances[distance] - min) / max || 0
    end
    distances
  end

  def get_occurence(text : String, expression : Regex) : Float
    count = expression.match(text).size
    (count ? count : 0) / text.size || 0
  end

  def get_top_expression(text : String, expressions = @@expressions) : Hash(NamedTuple(Symbol, Regex), Int32)
    top_count = -1
    top_expression = Regex.new
    expressions.each do |_, expression|
      count = get_occurrence(text, expression)
      if (count > top_count)
        top_count = count
        top_expression = {script expression}
      end
    end
    {top_expression => top_count}
  end

  def get_distances(trigrams : Array(Tuple(String, Int32)), languages = @@languages) : Array(Hash(String, Int32))
    distances : Array(Hash(String, Int32))
    languages.each do |language|
      distances << {language => get_distance(trigrams, language)}
    end
  end

  def get_distance(trigrams, model : Array(String)) : Int32
    distance = 0
    difference : Int32

    trigrams.each do |trigram|
      if model.includes?(trigram.key)
        difference = trigram.value - model[trigram.key] - 1
        if difference < 0
          difference = -difference
        end
      else
        difference = 300 # max_difference
      end
      distance += difference
    end
  end

  distance
end
