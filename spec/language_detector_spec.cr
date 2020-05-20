require "json"
require "./spec_helper"

describe Cadmium::LanguageDetector do
  subject = Cadmium::LanguageDetector.new

  it "should detect supported languages" do
    json = File.read(File.expand_path("./data/fixtures.json", __DIR__))
    fixtures = JSON.parse(json)
    fixtures.as_h.each do |_, v|
      fixture = v["fixture"].as_s
      iso6393 = v["iso6393"].as_s
      subject.detect(fixture).should eq(iso6393)
    end
  end
end
