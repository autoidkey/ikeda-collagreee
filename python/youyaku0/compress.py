#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
from pyknp import KNP
from prettyprint import pp

def compress_sentence(sentences):
    compressed_sentences = []

    for sentence in sentences:
        # sentence = unicode(sentence, 'utf-8')
        sentence = re.sub(re.compile(u" "), "", sentence) # 半角スペースを除去
        knp = KNP(option='-tab -anaphora') # 文書ごとにKNPをリセットする
        result = knp.parse(sentence)
        candidate = {} # 述語項構造候補辞書
        compressed_sentence = ""
        result_ids = []

        allowed_pos = (
            u"動",
            u"名",
            u"形",
            u"判"
        )

        # print "入力文:", sentence

        # loop for bunsetsu
        for bnst in result.bnst_list():
            # print u"ID:%s, 見出し:%s" % (bnst.bnst_id, "".join(mrph.midasi for mrph in bnst.mrph_list()))
            for tag in bnst.tag_list():
                entity_id = re.search(u"<EID:(.+?)>", tag.fstring)
                if entity_id is not None: # EIDが付与されている
                    entity_id = entity_id.group(1)
                    if bnst.bnst_id not in candidate.keys():
                        candidate[bnst.bnst_id] = [entity_id]
                    else:
                        candidate[bnst.bnst_id].append(entity_id)

        # loop for tag (kihonku, basic phrase)
        for tag in result.tag_list():
            is_jutsugo = False
            entity_id = re.search(u"<EID:(.+?)>", tag.fstring)
            if entity_id is not None: # EIDが付与されている
                entity_id = entity_id.group(1)

            jutsugo_ko = re.search(u"<述語項構造:(.+?):(.+?):(.+?)>", tag.fstring)
            if jutsugo_ko is not None: # 述語である
                is_jutsugo = True
                # print entity_id, jutsugo_ko.group(0)
                if jutsugo_ko.group(2).startswith(allowed_pos):
                    jutsugo_ko = jutsugo_ko.group(3) # 項の部分を取得
                    kos = jutsugo_ko.split(u";")
                    for key, value in candidate.items():
                        if entity_id in value:
                            result_ids.append(key)
                        for ko in kos:
                            element = ko.split(u"/") # "ヲ/C/環境/6"
                            if element[1] != u"O" and element[3] in value:
                                result_ids.append(key)

            jutsugo_ko = re.search(u"<述語項構造:(.+?):(.+?)>", tag.fstring)
            if not is_jutsugo and jutsugo_ko is not None: # 述語である
                # print entity_id, jutsugo_ko.group(0)
                if jutsugo_ko.group(2).startswith(allowed_pos):
                    for key, value in candidate.items():
                        if entity_id in value:
                            result_ids.append(key)

        # loop for bunsetsu
        for bnst in result.bnst_list():
            if bnst.bnst_id in result_ids:
                compressed_sentence += "".join(mrph.midasi for mrph in bnst.mrph_list())

        # print "出力文:", compressed_sentence
        compressed_sentences.append(compressed_sentence)

    return compressed_sentences

if __name__ == "__main__":
    sentences = [
        "交通インフラができるとストロー現象というのが危惧されますが、全く違うコンセプトの街になるなら双方に人の流れができるかもしれませんね。",
        "低層のオアシス２１が名古屋らしいなら、地下街はもっと名古屋らしいと思います。",
        "都市魅力としてなごやの地下街をさらに活性化させ（梅田の地下街が理想形ですが）、同じ地下空間を利用するリニアのインパクトを和らげ、吸収しやすくできるのではないでしょうか。。",
        "また東京と競うことによって、名古屋の良さであるコンパクトで住みやすい街という個性を失うことにもなりかねません。",
        "僕は数年前東京に上京して感じたのですが、コンパクトで住みやすい街とは、自然に短時間でであえることだと思います。"
    ]
    pp(compress_sentence(sentences))
