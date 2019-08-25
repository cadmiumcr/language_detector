require "cadmium"
require "json"

module Franca
  class LanguageDetector
    VERSION = "0.1.0"
    # "Reference ": "htt =>":/ =>www.unicode.org/Public/UNIDATA/Blocks.txt
    # Removed utf-16 characters because crystal pcre regex implementation doesn't support them
    @@expressions : Hash(String, Regex) = {
      "cmn"                 => /[\x{2E80}-\x{2E99}\x{2E9B}-\x{2EF3}\x{2F00}-\x{2FD5}\x{3005}\x{3007}\x{3021}-\x{3029}\x{3038}-\x{303B}\x{3400}-\x{4DB5}\x{4E00}-\x{9FCC}\x{F900}-\x{FA6D}\x{FA70}-\x{FAD9}]/im,
      "Latin"               => /[A-Za-z\xAA\xBA\xC0-\xD6\xD8-\xF6\xF8-\x{02B8}\x{02E0}-\x{02E4}\x{1D00}-\x{1D25}\x{1D2C}-\x{1D5C}\x{1D62}-\x{1D65}\x{1D6B}-\x{1D77}\x{1D79}-\x{1DBE}\x{1E00}-\x{1EFF}\x{2071}\x{207F}\x{2090}-\x{209C}\x{212A}\x{212B}\x{2132}\x{214E}\x{2160}-\x{2188}\x{2C60}-\x{2C7F}\x{A722}-\x{A787}\x{A78B}-\x{A78E}\x{A790}-\x{A7AD}\x{A7B0}\x{A7B1}\x{A7F7}-\x{A7FF}\x{AB30}-\x{AB5A}\x{AB5C}-\x{AB5F}\x{AB64}\x{FB00}-\x{FB06}\x{FF21}-\x{FF3A}\x{FF41}-\x{FF5A}]/,
      "Cyrillic"            => /[\x{0400}-\x{0484}\x{0487}-\x{052F}\x{1D2B}\x{1D78}\x{2DE0}-\x{2DFF}\x{A640}-\x{A69D}\x{A69F}]/,
      "Arabic"              => /[\x{0600}-\x{0604}\x{0606}-\x{060B}\x{060D}-\x{061A}\x{061E}\x{0620}-\x{063F}\x{0641}-\x{064A}\x{0656}-\x{065F}\x{066A}-\x{066F}\x{0671}-\x{06DC}\x{06DE}-\x{06FF}\x{0750}-\x{077F}\x{08A0}-\x{08B2}\x{08E4}-\x{08FF}\x{FB50}-\x{FBC1}\x{FBD3}-\x{FD3D}\x{FD50}-\x{FD8F}\x{FD92}-\x{FDC7}\x{FDF0}-\x{FDFD}\x{FE70}-\x{FE74}\x{FE76}-\x{FEFC}]/,
      "ben"                 => /[\x{0980}-\x{0983}\x{0985}-\x{098C}\x{098F}\x{0990}\x{0993}-\x{09A8}\x{09AA}-\x{09B0}\x{09B2}\x{09B6}-\x{09B9}\x{09BC}-\x{09C4}\x{09C7}\x{09C8}\x{09CB}-\x{09CE}\x{09D7}\x{09DC}\x{09DD}\x{09DF}-\x{09E3}\x{09E6}-\x{09FB}]/,
      "Devanagari"          => /[\x{0900}-\x{0950}\x{0953}-\x{0963}\x{0966}-\x{097F}\x{A8E0}-\x{A8FB}]/,
      "jpn"                 => /[\x{3041}-\x{3096}\x{309D}-\x{309F}]|[\x{30A1}-\x{30FA}\x{30FD}-\x{30FF}\x{31F0}-\x{31FF}\x{32D0}-\x{32FE}\x{3300}-\x{3357}\x{FF66}-\x{FF6F}\x{FF71}-\x{FF9D}]/,
      "kor"                 => /[\x{1100}-\x{11FF}\x{302E}\x{302F}\x{3131}-\x{318E}\x{3200}-\x{321E}\x{3260}-\x{327E}\x{A960}-\x{A97C}\x{AC00}-\x{D7A3}\x{D7B0}-\x{D7C6}\x{D7CB}-\x{D7FB}\x{FFA0}-\x{FFBE}\x{FFC2}-\x{FFC7}\x{FFCA}-\x{FFCF}\x{FFD2}-\x{FFD7}\x{FFDA}-\x{FFDC}]/,
      "tel"                 => /[\x{0C00}-\x{0C03}\x{0C05}-\x{0C0C}\x{0C0E}-\x{0C10}\x{0C12}-\x{0C28}\x{0C2A}-\x{0C39}\x{0C3D}-\x{0C44}\x{0C46}-\x{0C48}\x{0C4A}-\x{0C4D}\x{0C55}\x{0C56}\x{0C58}\x{0C59}\x{0C60}-\x{0C63}\x{0C66}-\x{0C6F}\x{0C78}-\x{0C7F}]/,
      "tam"                 => /[\x{0B82}\x{0B83}\x{0B85}-\x{0B8A}\x{0B8E}-\x{0B90}\x{0B92}-\x{0B95}\x{0B99}\x{0B9A}\x{0B9C}\x{0B9E}\x{0B9F}\x{0BA3}\x{0BA4}\x{0BA8}-\x{0BAA}\x{0BAE}-\x{0BB9}\x{0BBE}-\x{0BC2}\x{0BC6}-\x{0BC8}\x{0BCA}-\x{0BCD}\x{0BD0}\x{0BD7}\x{0BE6}-\x{0BFA}]/,
      "guj"                 => /[\x{0A81}-\x{0A83}\x{0A85}-\x{0A8D}\x{0A8F}-\x{0A91}\x{0A93}-\x{0AA8}\x{0AAA}-\x{0AB0}\x{0AB2}\x{0AB3}\x{0AB5}-\x{0AB9}\x{0ABC}-\x{0AC5}\x{0AC7}-\x{0AC9}\x{0ACB}-\x{0ACD}\x{0AD0}\x{0AE0}-\x{0AE3}\x{0AE6}-\x{0AF1}]/,
      "kan"                 => /[\x{0C81}-\x{0C83}\x{0C85}-\x{0C8C}\x{0C8E}-\x{0C90}\x{0C92}-\x{0CA8}\x{0CAA}-\x{0CB3}\x{0CB5}-\x{0CB9}\x{0CBC}-\x{0CC4}\x{0CC6}-\x{0CC8}\x{0CCA}-\x{0CCD}\x{0CD5}\x{0CD6}\x{0CDE}\x{0CE0}-\x{0CE3}\x{0CE6}-\x{0CEF}\x{0CF1}\x{0CF2}]/,
      "mal"                 => /[\x{0D01}-\x{0D03}\x{0D05}-\x{0D0C}\x{0D0E}-\x{0D10}\x{0D12}-\x{0D3A}\x{0D3D}-\x{0D44}\x{0D46}-\x{0D48}\x{0D4A}-\x{0D4E}\x{0D57}\x{0D60}-\x{0D63}\x{0D66}-\x{0D75}\x{0D79}-\x{0D7F}]/,
      "Myanmar"             => /[\x{1000}-\x{109F}\x{A9E0}-\x{A9FE}\x{AA60}-\x{AA7F}]/,
      "ori"                 => /[\x{0B01}-\x{0B03}\x{0B05}-\x{0B0C}\x{0B0F}\x{0B10}\x{0B13}-\x{0B28}\x{0B2A}-\x{0B30}\x{0B32}\x{0B33}\x{0B35}-\x{0B39}\x{0B3C}-\x{0B44}\x{0B47}\x{0B48}\x{0B4B}-\x{0B4D}\x{0B56}\x{0B57}\x{0B5C}\x{0B5D}\x{0B5F}-\x{0B63}\x{0B66}-\x{0B77}]/,
      "pan"                 => /[\x{0A01}-\x{0A03}\x{0A05}-\x{0A0A}\x{0A0F}\x{0A10}\x{0A13}-\x{0A28}\x{0A2A}-\x{0A30}\x{0A32}\x{0A33}\x{0A35}\x{0A36}\x{0A38}\x{0A39}\x{0A3C}\x{0A3E}-\x{0A42}\x{0A47}\x{0A48}\x{0A4B}-\x{0A4D}\x{0A51}\x{0A59}-\x{0A5C}\x{0A5E}\x{0A66}-\x{0A75}]/,
      "Ethiopic"            => /[\x{1200}-\x{1248}\x{124A}-\x{124D}\x{1250}-\x{1256}\x{1258}\x{125A}-\x{125D}\x{1260}-\x{1288}\x{128A}-\x{128D}\x{1290}-\x{12B0}\x{12B2}-\x{12B5}\x{12B8}-\x{12BE}\x{12C0}\x{12C2}-\x{12C5}\x{12C8}-\x{12D6}\x{12D8}-\x{1310}\x{1312}-\x{1315}\x{1318}-\x{135A}\x{135D}-\x{137C}\x{1380}-\x{1399}\x{2D80}-\x{2D96}\x{2DA0}-\x{2DA6}\x{2DA8}-\x{2DAE}\x{2DB0}-\x{2DB6}\x{2DB8}-\x{2DBE}\x{2DC0}-\x{2DC6}\x{2DC8}-\x{2DCE}\x{2DD0}-\x{2DD6}\x{2DD8}-\x{2DDE}\x{AB01}-\x{AB06}\x{AB09}-\x{AB0E}\x{AB11}-\x{AB16}\x{AB20}-\x{AB26}\x{AB28}-\x{AB2E}]/,
      "tha"                 => /[\x{0E01}-\x{0E3A}\x{0E40}-\x{0E5B}]/,
      "sin"                 => /[\x{0D82}\x{0D83}\x{0D85}-\x{0D96}\x{0D9A}-\x{0DB1}\x{0DB3}-\x{0DBB}\x{0DBD}\x{0DC0}-\x{0DC6}\x{0DCA}\x{0DCF}-\x{0DD4}\x{0DD6}\x{0DD8}-\x{0DDF}\x{0DE6}-\x{0DEF}\x{0DF2}-\x{0DF4}]/,
      "ell"                 => /[\x{0370}-\x{0373}\x{0375}-\x{0377}\x{037A}-\x{037D}\x{037F}\x{0384}\x{0386}\x{0388}-\x{038A}\x{038C}\x{038E}-\x{03A1}\x{03A3}-\x{03E1}\x{03F0}-\x{03FF}\x{1D26}-\x{1D2A}\x{1D5D}-\x{1D61}\x{1D66}-\x{1D6A}\x{1DBF}\x{1F00}-\x{1F15}\x{1F18}-\x{1F1D}\x{1F20}-\x{1F45}\x{1F48}-\x{1F4D}\x{1F50}-\x{1F57}\x{1F59}\x{1F5B}\x{1F5D}\x{1F5F}-\x{1F7D}\x{1F80}-\x{1FB4}\x{1FB6}-\x{1FC4}\x{1FC6}-\x{1FD3}\x{1FD6}-\x{1FDB}\x{1FDD}-\x{1FEF}\x{1FF2}-\x{1FF4}\x{1FF6}-\x{1FFE}\x{2126}\x{AB65}]/,
      "khm"                 => /[\x{1780}-\x{17DD}\x{17E0}-\x{17E9}\x{17F0}-\x{17F9}\x{19E0}-\x{19FF}]/,
      "hye"                 => /[\x{0531}-\x{0556}\x{0559}-\x{055F}\x{0561}-\x{0587}\x{058A}\x{058D}-\x{058F}\x{FB13}-\x{FB17}]/,
      "sat"                 => /[\x{1C50}-\x{1C7F}]/,
      "Tibetan"             => /[\x{0F00}-\x{0F47}\x{0F49}-\x{0F6C}\x{0F71}-\x{0F97}\x{0F99}-\x{0FBC}\x{0FBE}-\x{0FCC}\x{0FCE}-\x{0FD4}\x{0FD9}\x{0FDA}]/,
      "Hebrew"              => /[\x{0591}-\x{05C7}\x{05D0}-\x{05EA}\x{05F0}-\x{05F4}\x{FB1D}-\x{FB36}\x{FB38}-\x{FB3C}\x{FB3E}\x{FB40}\x{FB41}\x{FB43}\x{FB44}\x{FB46}-\x{FB4F}]/,
      "kat"                 => /[\x{10A0}-\x{10C5}\x{10C7}\x{10CD}\x{10D0}-\x{10FA}\x{10FC}-\x{10FF}\x{2D00}-\x{2D25}\x{2D27}\x{2D2D}]/,
      "lao"                 => /[\x{0E81}\x{0E82}\x{0E84}\x{0E87}\x{0E88}\x{0E8A}\x{0E8D}\x{0E94}-\x{0E97}\x{0E99}-\x{0E9F}\x{0EA1}-\x{0EA3}\x{0EA5}\x{0EA7}\x{0EAA}\x{0EAB}\x{0EAD}-\x{0EB9}\x{0EBB}-\x{0EBD}\x{0EC0}-\x{0EC4}\x{0EC6}\x{0EC8}-\x{0ECD}\x{0ED0}-\x{0ED9}\x{0EDC}-\x{0EDF}]/,
      "zgh"                 => /[\x{2D30}-\x{2D67}\x{2D6F}\x{2D70}\x{2D7F}]/,
      "iii"                 => /[\x{A000}-\x{A48C}\x{A490}-\x{A4C6}]/,
      "aii"                 => /[\x{0700}-\x{070D}\x{070F}-\x{074A}\x{074D}-\x{074F}]/,
      "div"                 => /[\x{0780}-\x{07B1}]/,
      "vai"                 => /[\x{A500}-\x{A62B}]/,
      "Canadian_Aboriginal" => /[\x{1400}-\x{167F}\x{18B0}-\x{18F5}]/,
      # "chr" =>                 undefined,
      "kkh" => /[\x{1A20}-\x{1A5E}\x{1A60}-\x{1A7C}\x{1A7F}-\x{1A89}\x{1A90}-\x{1A99}\x{1AA0}-\x{1AAD}]/,
      "blt" => /[\x{AA80}-\x{AAC2}\x{AADB}-\x{AADF}]/,
    }
    DATA_FILE = "#{__DIR__}/../data/data.json"
    @@data = Hash(String, Hash(String, String)).from_json({{ read_file(DATA_FILE) }}) # Should be namedtuple

    @@languages = Hash(String, Hash(Array(String), Int32)).new # Should be namedtuple
    # I should modify the json file instead of building the data model each time !
    def initialize
      # @@languages = Hash(String, Array(String)).new
      @@data.values.each do |languages|
        languages.each do |language, model|
          # @@model = model.split('|')
          # @@weight = model.split('|').size
          # @@trigrams << { model.split('|') => model.split('|').size }
          @@languages[language] = {model.split('|') => model.split('|').size}
        end
      end
    end

    def trigrams_and_value(text : String) : Hash(String, Int32)
      text_without_punctuation = text.gsub(/[\x{0021}-\x{0040}]+/, ' ').downcase
      trigrams_array = Cadmium.ngrams.new(Cadmium::RegexTokenizer.new(/.{3}/)).trigrams(text_without_punctuation).compact!.map { |array| array.join } # .map! { |trigram| trigram.join if trigram.is_a?(Array) } # returns array of three characters set (excluding whitespace so needs to implement better/specific tokenizer)
      trigrams_array.tally
    end

    def detect(text : String) : String
      detect_all(text).keys[0]
    end

    def detect_all(text : String) : Hash(String, Float64)
      expression = get_top_expression(text, @@expressions)
      return {expression.keys[0] => 1.0} unless @@data.keys.includes?(expression.keys[0])
      normalize(text, get_distances(trigrams_and_value(text), @@languages))
    end

    # # Create a single tuple as a list of tuples from a given
    # # language code. ???????????????????????????????
    # def single_language_tuples(language) :
    #   [[language, 1]]
    # end

    def normalize(text : String, distances : Hash(String, Int32)) : Hash(String, Float64)
      min = 0 # distances.values[1]
      max = text.size * 300 - min
      distances_float = Hash(String, Float64).new
      distances.each do |string, distance|
        distances_float[string] = (1 - (distance - min) / max).to_f || 0.0
      end
      distances_float
    end

    def get_occurence(text : String, expression : Regex) : Int32
      count = 0
      text.scan(expression).each { |_| count += 1 }
      # count = expression.match(text).not_nil!.group_size unless expression.match(text).nil?
      # (count ? count : 0) / text.size || 0
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
    def get_distances(trigrams : Hash(String, Int32), languages : Hash(String, Hash(Array(String), Int32)) = @@languages) : Hash(String, Int32)
      distances = Hash(String, Int32).new
      languages.each do |language, model_and_value|
        distances[language] = get_distance(trigrams, model_and_value)
      end

      sorted_distances = Hash(String, Int32).new # All of this could be replaced by a one liner if Crystal supported sort_by for Hash...
      distances.values.sort_by { |values| -values }.each do |value|
        sorted_distances[distances.key_for(value)] = value
      end
      sorted_distances
    end

    def get_distance(trigrams : Hash(String, Int32), model : Hash(Array(String), Int32)) : Int32
      distance = 0
      difference : Int32

      trigrams.each do |trigram|
        if model.keys.includes?(trigram[0])
          difference = trigram[1] - model.keys.index(trigram[0]).not_nil! - 1 # I have no idea what this means
          if difference < 0
            difference = -difference
          end
        else
          difference = 300 # max_difference
        end
        distance += difference
      end
      distance
    end
  end
end
