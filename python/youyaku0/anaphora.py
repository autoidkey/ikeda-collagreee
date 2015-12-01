#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
from pyknp import KNP
from prettyprint import pp

def anaphora_analysis(sentences):
    knp = KNP(option='-tab -anaphora') # KNP
    completed_sentences = []
    candidate = {} # 固有表現候補辞書

    for sentence in sentences:
        sentence = unicode(sentence, 'utf-8')
        sentence = re.sub(re.compile(u" "), "", sentence) # 半角スペースを除去
        result = knp.parse(sentence)
        midasis = []

        # print "入力文:", sentence
        # print "出力文:",

        # loop for tab (kihonku, basic phrase)
        for tag in result.tag_list():
            entity_id = re.search(u"<EID:(.+?)>", tag.fstring)
            if entity_id is not None: # EIDが付与されている
                entity_id = entity_id.group(1)
                named_entity = re.search(u"<NE:(?:ORGANIZATION|PERSON|LOCATION):(.+?)>", tag.fstring)
                if named_entity is not None: # 固有表現が付与されている
                    if entity_id not in candidate.keys(): # 候補がないとき
                        candidate[entity_id] = [named_entity.group(1)]
                    elif len(named_entity.group(1)) > len(candidate[entity_id][-1]): # 異なる候補が既にあるとき
                        candidate[entity_id].append(named_entity.group(1))

            is_corefer = False
            corefer_id = re.search(u"<COREFER_ID:.+?>", tag.fstring)
            if corefer_id is not None: # 共参照関係にある
                is_corefer = True

            # loop for mrph in tag
            for mrph in tag.mrph_list():
                if is_corefer and (mrph.bunrui == u"普通名詞"):
                    try:
                        mrph.midasi = candidate[entity_id][-1]
                    except:
                        pass
                midasis.append(mrph.midasi)

        # print "".join(m for m in midasis)
        completed_sentences.append("".join(m for m in midasis))

    # print "登場固有表現候補:"
    # for key, value in sorted(candidate.items()):
    #     print "EID: %s, %s" % (key, " / ".join(v for v in candidate[key]))

    return completed_sentences

if __name__ == "__main__":
    sentences = [
        "交通インフラができるとストロー現象というのが危惧されますが、全く違うコンセプトの街になるなら双方に人の流れができるかもしれませんね。",
        "低層のオアシス２１が名古屋らしいなら、地下街はもっと名古屋らしいと思います。",
        "都市魅力としてなごやの地下街をさらに活性化させ（梅田の地下街が理想形ですが）、同じ地下空間を利用するリニアのインパクトを和らげ、吸収しやすくできるのではないでしょうか。。",
        "また東京と競うことによって、名古屋の良さであるコンパクトで住みやすい街という個性を失うことにもなりかねません。",
        "僕は数年前東京に上京して感じたのですが、コンパクトで住みやすい街とは、自然に短時間でであえることだと思います。"
    ]
    pp(anaphora_analysis(sentences))
