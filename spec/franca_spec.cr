require "./spec_helper"
include Franca
describe Franca do
  subject = LanguageDetector.new
  test = "제 26 조
  1) 모든 사람은 교육을 받을 권리를 가진다 . 교육은 최소한 초등 및 기초단계에서는 무상이어야 한다. 초등교육은 의무적이어야 한다. 기술 및 직업교육은 일반적으로 접근이 가능하여야 하며, 고등교육은 모든 사람에게 실력에 근거하여 동등하게 접근 가능하여야 한다.
  2) 교육은 인격의 완전한 발전과 인권과 기본적 자유에 대한 존중의 강화를 목표로 한다. 교육은 모든 국가 , 인종 또는 종교 집단간에 이해, 관용 및 우의를 증진하며 , 평화의 유지를 위한 국제연합의 활동을 촉진하여야 한다.
  3) 부모는 자녀에게 제공되는 교육의 종류를 선택할 우선권을 가진다 .
  제 27 조
  1) 모든 사람은 공동체의 문화생활에 자유롭게 참여하며 예술을 향유하고 과학의 발전과 그 혜택을 공유할 권리를 가진다 .
  2) 모든 사람은 자신이 창작한 과학적 , 문학적 또는 예술적 산물로부터 발생하는 정신적, 물질적 이익을 보호받을 권리를 가진다 ."

  test2 = "Rappelle-toi Barbara
  Il pleuvait sans cesse sur Brest ce jour-là
  Et tu marchais souriante
  Épanouie ravie ruisselante
  Sous la pluie
  Rappelle-toi Barbara
  Il pleuvait sans cesse sur Brest
  Et je t'ai croisée rue de Siam
  Tu souriais
  Et moi je souriais de même
  Rappelle-toi Barbara
  Toi que je ne connaissais pas
  Toi qui ne me connaissais pas
  Rappelle-toi
  Rappelle-toi quand même jour-là
  N'oublie pas
  Un homme sous un porche s'abritait
  Et il a crié ton nom
  Barbara
  Et tu as couru vers lui sous la pluie
  Ruisselante ravie épanouie
  Et tu t'es jetée dans ses bras
  Rappelle-toi cela Barbara
  Et ne m'en veux pas si je te tutoie
  Je dis tu à tous ceux que j'aime
  Même si je ne les ai vus qu'une seule fois
  Je dis tu à tous ceux qui s'aiment
  Même si je ne les connais pas
  Rappelle-toi Barbara
  N'oublie pas
  Cette pluie sage et heureuse
  Sur ton visage heureux
  Sur cette ville heureuse
  Cette pluie sur la mer
  Sur l'arsenal
  Sur le bateau d'Ouessant
  Oh Barbara
  Quelle connerie la guerre
  Qu'es-tu devenue maintenant
  Sous cette pluie de fer
  De feu d'acier de sang
  Et celui qui te serrait dans ses bras
  Amoureusement
  Est-il mort disparu ou bien encore vivant
  Oh Barbara
  Il pleut sans cesse sur Brest
  Comme il pleuvait avant
  Mais ce n'est plus pareil et tout est abimé
  C'est une pluie de deuil terrible et désolée
  Ce n'est même plus l'orage
  De fer d'acier de sang
  Tout simplement des nuages
  Qui crèvent comme des chiens
  Des chiens qui disparaissent
  Au fil de l'eau sur Brest
  Et vont pourrir au loin
  Au loin très loin de Brest
  Dont il ne reste rien. "

  it "should detect korean" do
    subject.detect(test).should eq("kor")
  end
  it "should detect french" do
    subject.detect(test2).should eq("fra")
  end
end
