require "json"
require "./spec_helper"

LANG_A = "pol"
LANG_B = "eng"

HEBREW = "הפיתוח הראשוני בשנות ה־80 התמקד בגנו ובמערכת הגרפית"

FIXTURES = JSON.parse(File.read(File.expand_path("./data/fixtures.json", __DIR__)))
# FIXME: Find out why these examples fail
SKIP = ["gax", "bos", "srp", "uzn", "zlm", "azj", "uig", "tuk", "kng", "fuf", "est"]



describe Cadmium::LanguageDetector do
  subject = Cadmium::LanguageDetector.new

  it "should work on unique-scripts with many latin characters (1)" do
    text = <<-TEXT
    한국어 문서가 전 세계 웹에서 차지하는 비중은 2004년에 4.1%로, 이는 영어(35.8%),
    중국어(14.1%), 일본어(9.6%), 스페인어(9%), 독일어(7%)에 이어 전 세계 6위이다.
    한글 문서와 한국어 문서를 같은것으로 볼 때, 웹상에서의 한국어 사용 인구는 전 세계
    69억여 명의 인구 중 약 1%에 해당한다.
    TEXT

    subject.detect(text).should eq("kor")
  end

  it "should work on unique-scripts with many latin characters (2)" do
    text = <<-TEXT
    現行の学校文法では、英語にあるような「目的語」「補語」などの成分はないとする。
    英語文法では "I read a book." の "a book" はSVO文型の一部をなす目的語であり、
    また、"I go to the library." の "the library"
    は前置詞とともに付け加えられた修飾語と考えられる。
    TEXT

    subject.detect(text).should eq("jpn")
  end

  # it "should detect Japanese even when Han ratio > 0.5 (udhr_jpn art 3) (1)" do
  #   text = "すべての人は、生命、自由及び身体の安全に対する権利を有する。"
  #   subject.detect(text).should eq("jpn")
  # end

  # it "should detect Japanese even when Han ratio > 0.5 (udhr_jpn art 8) (2)" do
  #   text = <<-TEXT
  #   すべての人は、憲法又は法律によって与えられた基本的権利を侵害する行為に対し、
  #   権限を有する国内裁判所による効果的な救済を受ける権利を有する。
  #   TEXT

  #   subject.detect(text).should eq("jpn")
  # end

  # it "should detect Japanese even when Han ratio > 0.5 (udhr_jpn art 16) (3)" do
  #   text = <<-TEXT
  #   成年の男女は、人種、国籍又は宗教によるいかなる制限をも受けることなく、婚姻し、
  #   かつ家庭をつくる権利を有する。成年の男女は、婚姻中及びその解消に際し、
  #   婚姻に関し平等の権利を有する。婚姻は、婚姻の意思を有する両当事者の自由かつ完全な合意によってのみ成立する。
  #   家庭は、社会の自然かつ基礎的な集団単位であって、社会及び国の保護を受ける権利を有する。
  #   TEXT

  #   subject.detect(text).should eq("jpn")
  # end

  it "should detect supported languages" do
    FIXTURES.as_h.each do |_, v|
      fixture = v["fixture"].as_s
      iso6393 = v["iso6393"].as_s
      next if SKIP.includes?(iso6393)
      subject.detect(fixture).should eq(iso6393)
    end
  end
end
