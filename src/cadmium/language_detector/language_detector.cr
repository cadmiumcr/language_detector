require "json"
require "./language"

module Cadmium
  # `Cadmium::LanguageDetector` is a Language Identification algorithm which identifies up to 400 different languages.
  class LanguageDetector
    include Language

    @@lang_data = LanguageData.new

    @trigrams_data : Hash(String, Hash(String, String))
    @expressions : Hash(String, Regex)
    @languages = Hash(String, Array(String)).new
    @iso_hash : Hash(String, String)
    @whitelist : Array(String)
    @blacklist : Array(String)

    # A LanguageDetector object can be initiampized with a whitelist and/or blacklist of languages. Those lists have to be Tuple of String.
    def initialize(@whitelist = [] of String, @blacklist = [] of String)
      @trigrams_data = @@lang_data.trigrams
      @expressions = @@lang_data.expressions
      @iso_hash = IsoCode3To1.new.codes

      @trigrams_data.values.each do |languages|
        languages.each do |language, model|
          if whitelist.includes?(@iso_hash.fetch(language, language)) ||
             !blacklist.includes?(@iso_hash.fetch(language, language))
            @languages[language] = model.split('|')
          end
        end
      end
    end

    private def trigrams_and_value(text : String) : Hash(String, Int32)
      text_without_punctuation = text.strip.gsub(/[[:punct:][:cntrl:]]/, "")
      trigrams_array = text_without_punctuation.scan(/.{3}/).map { |trigram| trigram[0] }
      trigrams_count_hash = trigrams_array.tally
      trigrams_count_hash.to_a.sort_by { |(k, values)| -values }.to_h
    end

    # Returns a two letters string corresponding to the ISO-868-1 code of the detected language.
    def detect(text : String) : String
      result = detect_all(text).keys[0]
      # @iso_hash.fetch(result, result)
    end

    # Returns an Hash of two letters string corresponding to the ISO-868-1 code of the detected
    # language mapped to their probability.
    def detect_all(text : String) : Hash(String, Float64)
      expression = get_top_expression(text, @expressions)
      return {expression.keys[0] => 1.0} unless @trigrams_data.keys.includes?(expression.keys[0])
      distances = get_distances(trigrams_and_value(text))
      normalize(text, distances)
    end

    private def normalize(text : String, distances : Hash(String, Int32)) : Hash(String, Float64)
      min = !distances.values[0..].empty? ? distances.values[0] : 1
      max = (text.size + 1) * 300 - min
      distances.map do |string, distance|
        {string, (1 - (distance - min) / max).to_f || 0.0}
      end.to_h
    end

    private def get_occurence(text : String, expression : Regex) : Int32
      count = 0
      text.scan(expression).each { |_| count += 1 }
      count
    end

    private def get_top_expression(text : String, expressions : Hash(String, Regex)) : Hash(String, Regex)
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
    private def get_distances(text_trigrams : Hash(String, Int32)) : Hash(String, Int32)
      @languages.map do |language, language_trigrams|
        {language, get_distance(text_trigrams, language_trigrams)}
      end.sort_by { |_, v| v }.to_h
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
