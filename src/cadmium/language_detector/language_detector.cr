require "json"
require "./language"

module Cadmium
  class LanguageDetector
    include Language
    @@lang_data = LanguageData.new
    @@trigrams_data : Hash(String, Hash(String, String)) = @@lang_data.trigrams
    @@expressions : Hash(String, Regex) = @@lang_data.expressions
    @@languages = Hash(String, Array(String)).new
    @@iso_hash : Hash(String, String) = IsoCode3To1.new.codes

    def initialize
      @@trigrams_data.values.each do |languages|
        languages.each do |language, model|
          @@languages[language] = model.split('|')
        end
      end
    end

    private def trigrams_and_value(text : String) : Hash(String, Int32)
      text_without_punctuation = text.downcase.delete('\n').gsub(/[\x{0021}-\x{0040}]/, "")
      trigrams_array = Array(String).new
      text_without_punctuation.scan(/.{3}/).each { |trigram| trigrams_array << trigram[0] }
      trigrams_count_hash = trigrams_array.tally
      sorted_trigrams_hash = Hash(String, Int32).new # All of this could be replaced by a one liner if Crystal supported sort_by for Hash...
      trigrams_count_hash.values.sort_by { |values| -values }.each do |value|
        sorted_trigrams_hash[trigrams_count_hash.key_for(value)] = value
      end
      sorted_trigrams_hash
    end

    def detect(text : String) : String
      result = detect_all(text).keys[0]
      @@iso_hash.fetch(result, result)
    end

    def detect_all(text : String) : Hash(String, Float64)
      expression = get_top_expression(text, @@expressions)
      return {expression.keys[0] => 1.0} unless @@trigrams_data.keys.includes?(expression.keys[0])
      normalize(text, get_distances(trigrams_and_value(text), @@languages))
    end

    private def normalize(text : String, distances : Hash(String, Int32)) : Hash(String, Float64)
      min = distances.values[1]
      max = text.size * 300 - min
      distances_float = Hash(String, Float64).new
      distances.each do |string, distance|
        distances_float[string] = (1 - (distance - min) / max).to_f || 0.0
      end
      distances_float
    end

    private def get_occurence(text : String, expression : Regex) : Int32
      count = 0
      text.scan(expression).each { |_| count += 1 }
      count
    end

    def get_top_expression(text : String, expressions : Hash(String, Regex)) : Hash(String, Regex)
      top_count = -1
      top_expression = Hash(String, Regex).new
      expressions.each do |script, expression|
        count = get_occurence(text, expression)
        if (count > top_count)
          top_count = count
          top_expression = {script => expression}
        end
      end
      top_expression
    end

    # Calculate the distances between an array of trigrams and multiple trigrams dictionaries (languages from data.json)
    private def get_distances(text_trigrams : Hash(String, Int32), languages : Hash(String, Array(String)) = @@languages) : Hash(String, Int32)
      distances = Hash(String, Int32).new
      languages.each do |language, language_trigrams|
        distances[language] = get_distance(text_trigrams, language_trigrams)
      end

      sorted_distances = Hash(String, Int32).new # All of this could be replaced by a one liner if Crystal supported sort_by for Hash...
      distances.values.sort_by { |values| values }.each do |value|
        sorted_distances[distances.key_for(value)] = value
      end
      sorted_distances
    end

    private def get_distance(trigrams : Hash(String, Int32), model : Array(String)) : Int32
      distance = 0
      difference : Int32

      trigrams.keys.each do |trigram|
        if model.includes?(trigram)
          difference = trigrams.fetch(trigram, 1) - model.index(trigram).not_nil! - 1
          difference = -difference if difference < 0
        else
          difference = 300
        end
        distance += difference
      end
      distance
    end
  end
end
