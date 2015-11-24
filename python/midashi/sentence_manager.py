#!/usr/bin/env python#
# coding: utf-8
import os
import sys
import re
import CaboCha
import chunk_manager
import itertools
from tools.nega_posi import NegaPosiJudge
from tools import cosine


class SentenceManager(object):
    """文管理クラス"""
    __slots__ = ['chunks', 'think', 'need', 'original_sentence']

    def __init__(self, sentence):
        """初期化メソッド"""
        self.chunks = []
        self.original_sentence = ""
        self.think = 0
        self.need = 0
        #CaboChaの用意
        c = CaboCha.Parser()
        tree = c.parse(sentence)
        #chunkの数だけ回す
        for i in range(tree.chunk_size()):
            chunk = tree.chunk(i)
            cm = chunk_manager.ChunkManager(chunk.link, chunk.token_pos)
            self.chunks.append(cm)
            for x in range(chunk.token_pos, chunk.token_pos + chunk.token_size):
                feature = tree.token(x).feature.split(",")
                # 記号の場合は処理しない
                if feature[0] == "記号":
                    continue
                self.chunks[i].set_chunk(tree.token(x).surface)
                try:
                    feature_pre = tree.token(x-1).feature.split(",")
                except:
                    feature_pre = [""]
                #原形を扱う
                if feature[6] == "*":
                    self.chunks[i].set_original_forms(tree.token(x).surface)
                else:
                    self.chunks[i].set_original_forms(feature[6])
                #マッチングワードの判定
                if tree.token(x).surface in ("思う", "おもう", "考える", "かんがえる", "感じる", "かんじる") or feature[6] in ("思う", "おもう", "考える", "かんがえる", "感じる", "かんじる"):
                    if i >= tree.chunk_size()-1:
                        self.think += 1
                elif tree.token(x).surface in ("必要", "重要", "大切", "ひつよう", "じゅうよう", "たいせつ", "べし") or feature[6] in ("必要", "重要", "大切", "ヒツヨウ", "ひつよう", "ジュウヨウ", "じゅうよう", "タイセツ", "たいせつ", "べし"):
                    if i >= tree.chunk_size()-3:
                        self.need += 1
                #名詞を扱う
                if (feature[0] == "名詞" or feature[1] == "接尾") and self.chunks[i].words and (feature[1] not in ("数", "非自立", "代名詞")) and (feature[1] != "サ変接続" or feature[6] != "*"):
                    if feature_pre[0] in ("名詞", "接頭詞"):
                        self.chunks[i].set_noun(tree.token(x).surface)
                elif feature[0] in ("名詞") and (feature[1] not in ("非自立", "代名詞")) and (feature[1] != "サ変接続" or feature[6] != "*"):
                    self.chunks[i].set_words(tree.token(x).surface)
                    self.chunks[i].set_parts(feature[0])
                else:
                    self.chunks[i].set_parts(feature[0])
            self.original_sentence += self.chunks[i].chunk

    def make_link_list(self, chunk_num, result_list):
        """linkのlistを生成"""
        result_list.append(chunk_num)
        for i in range(len(self.chunks)):
            if self.chunks[i].link == chunk_num:
                result_list = self.make_link_list(i, result_list)
                break
        if chunk_num != -1 and self.chunks[chunk_num].link not in result_list:
            result_list = self.make_link_list(self.chunks[chunk_num].link, result_list)
        return result_list

    def make_link_list2(self):
        """linkの相互listを生成"""
        result = []
        for num in self.chunks:
            result.append([[], 0])
        for num in range(len(self.chunks)):
            value = self.chunks[num].link
            result[num][1] = value
            if value != -1:
                result[value][0].append(num)
        #例[[[1, 2], 4], [[1, 2], 4]]　左が受けている番号，右が係っている番号
        return result

    def get_word_links(self, word_list):
        """wordのlistからlinkのlistを生成"""
        result = []
        for word in word_list:
            for i in range(len(self.chunks)):
                if word in self.chunks[i].words:
                    result += self.make_link_list(i, [])
                else:
                    pass
        return list(set(result))

    def get_sentence_by_links(self, link_list):
        """linkのlistから文章を生成"""
        result = ""
        link_list.sort()
        for l in link_list:
            if l == -1:
                continue
            result += self.chunks[l].chunk
        return result

    def get_judgment(self):
        """判定結果を返す"""
        a = NegaPosiJudge(self.get_original_form())
        return a.get_judge()

    def get_original_sentence(self):
        """もとの文章を返す"""
        return self.original_sentence

    def get_original_form(self):
        """原形が入ったリストを返す"""
        result = []
        for num in range(len(self.chunks)):
            result += self.chunks[num].original_forms
        return result

    def get_need(self):
        """"必要"などが入っていれば1以上"""
        return self.need

    def get_think(self):
        """"思う"などが入っていれば1以上"""
        return self.think

    def get_word(self):
        """文章内の必要語（名詞など）のみ集めて返す"""
        result = []
        for num in range(len(self.chunks)):
            result += self.chunks[num].words
        return result

    def get_re_value(self, comment):
        """返信先との関連性を返す"""
        A = {}
        B = {}
        for word in self.get_word():
            try:
                A[word] += 1
            except:
                A[word] = 1
        for word in comment:
            try:
                B[word] += 1
            except:
                B[word] = 1
        return cosine.cosineSim(A, B)

    def get_kouho(self, template):
        """引数のリストから候補リストを生成して返す"""
        # templateは[["名詞", "は"], ["名詞", "を"], ["動詞", "と"]]のような順番と文節末が分かるように格納されたリスト
        result = []
        kouho = []
        # kouhoとtemplateを対応付ける
        for i in range(len(template)):
            kouho.append([])
        for i in range(len(self.chunks)):
            for tmp_num in range(len(template)):
                if self.chunks[i].original_forms == []:
                    continue
                if (template[tmp_num][0] in self.chunks[i].parts or template[tmp_num][0] == "全部") and (self.chunks[i].original_forms[-1] == template[tmp_num][1] or self.chunks[i].chunk.endswith(template[tmp_num][1]) or template[tmp_num] == "全部"):
                    kouho[tmp_num].append(i)
        if len(template) == 1:
            return kouho
        # 全組み合わせを生成
        elif len(template) == 2:
            comb = list(itertools.product(kouho[0], kouho[1]))
        elif len(template) == 3:
            comb = list(itertools.product(kouho[0], kouho[1], kouho[2]))
        else:
            print "error!"
            sys.exit(1)
        # 順序がtemplateと一致する組み合わせを取り出す
        for x in comb:
            tmp = set()
            s = [y for y in x if y in tmp or tmp.add(y)]
            if s != []:
                continue
            list_x = list(x)
            t = list(list_x)
            list_x.sort()
            if list_x == t:
                result.append(t)
        return result

    def get_agrees(self, template, bm25):
        """agree, disagreeの中でそれぞれの判定を得た単語でbm25の重みが大きい数語を取り出す"""
        # 単語の判定
        kouho = []
        a = NegaPosiJudge(self.get_original_form())
        judged_word = a.get_judged_word()
        if template == "agree":
            for word in judged_word:
                if word[1] == 1.0:
                    kouho.append(word[0])
        elif template == "disagree":
            for word in judged_word:
                if word[1] == -1.0:
                    kouho.append(word[0])
        weight = []
        for x in range(len(kouho)):
            word = kouho[x]
            weight.append([word, 1.0])
            for value in bm25:
                if kouho[x] == value[0]:
                    weight[x][1] *= value[1]
                    break
        weight.sort(key=lambda x: x[1], reverse=True)
        # 数語を取り出し，出現順に並べる
        tyou = []
        for w in range(len(weight)):
            if weight[w][0] in tyou:
                continue
            if len(tyou) > 2:
                while True:
                    if len(weight) == w:
                        break
                    weight.pop()
            if len(weight) == w:
                break
            tyou.append(weight[w][0])
        kouho = []
        for chunk_num in range(len(self.chunks)):
            for t in tyou:
                if t in self.chunks[chunk_num].chunk or t in self.chunks[chunk_num].original_forms:
                    kouho.append(chunk_num)
        kouho = list(set(self.hokan(kouho, 15)))
        result = ""
        for k in kouho:
            result += self.chunks[k].chunk
        while True:
            if len(result)/3 <= 15:
                break
            else:
                min_value = 0.0
                min_num = kouho[0]
                for k in range(len(kouho)):
                    if min_value < self.chunks[kouho[k]].chunk_weight:
                        min_value = self.chunks[kouho[k]].chunk_weight
                        min_num = k
                kouho.pop(min_num)
                result = ""
                for k in kouho:
                    result += self.chunks[k].chunk
        return result

    def get_None(self, bm25):
        """テンプレートNone用のパターン　重みの大きい順に候補にした単語を文での出現順に並べるだけ"""
        weight = []
        for x in range(len(self.get_word())):
            word = self.get_word()[x]
            weight.append([word, 1.0])
            for value in bm25:
                if self.get_word()[x] == value[0]:
                    weight[x][1] *= value[1]
                    break
        weight.sort(key=lambda x: x[1], reverse=True)
        sent = ""
        # 重みの大きい順に15文字以内になるまで候補を減らす
        tyou = []
        for w in range(len(weight)):
            if weight[w][0] in tyou:
                continue
            if (len(sent)+len(weight[w][0]))/3 < 15:
                sent += weight[w][0] + " "
            else:
                while True:
                    if len(weight) == w:
                        break
                    weight.pop()
            if len(weight) == w:
                break
            tyou.append(weight[w][0])
        # 候補の中から出現順に取り出す
        result = ""
        tyou = []
        for x in self.get_word():
            for w in weight:
                if x == w[0] and w[0] not in tyou:
                    tyou.append(w[0])
                    result += x + " "
        return result

    def hokan(self, kouho, limit):
        """抽出した候補の補完を係り受けから行う"""
        string = ""
        all_chunk = []
        for x in range(len(self.chunks)):
            all_chunk.append(x)
        # 20文字以上ならそのまま返す
        for x in kouho:
            string += self.chunks[x].chunk
        if len(string)/3 > limit:
            return kouho
        elif kouho == all_chunk:
            return kouho
        # 係り受けのリストから候補を抽出
        hokan_kouho = []
        link_list = self.make_link_list2()
        for num in kouho:
            hokan_kouho += link_list[num][0]
        # 候補から重複を排除
        uniq = list(set(hokan_kouho))
        while True:
            try:
                uniq.remove(-1)
            except:
                break
        uniq.sort()
        # 候補から決定している候補との重複を削除
        for num in kouho:
            if num in uniq:
                uniq.remove(num)
        # 重みの最も大きい候補を候補リストに加える
        kouho_list = list(kouho)
        max_value = 0.0
        num = -1
        for x in uniq:
            if max_value < self.chunks[x].chunk_weight:
                max_value = self.chunks[x].chunk_weight
                num = x
        if num != -1:
            kouho_list.append(num)
        kouho_list.sort()
        sentence = ""
        for x in kouho_list:
            sentence += self.chunks[x].chunk
        if len(sentence)/3 > limit:
            return kouho
        elif kouho == kouho_list:
            return kouho
        else:
            kouho_list = self.hokan(kouho_list, limit)
        return list(set(kouho_list))

    def get_weighting(self, bm25, template):
        """文節に重み付けをし，見出しを生成して返す"""
        # もし元の文が20文字以内ならそのまま返す
        if len(self.original_sentence)/3 < 20:
            return self.original_sentence
        # bm25は単語とそのbm25の値が入った２次元リスト
        # templateはテンプレートの種類（think, need など）
        for chunk_num in range(len(self.chunks)):
            for word in bm25:
                if word[0] in self.chunks[chunk_num].chunk:
                    self.chunks[chunk_num].set_chunk_weight(self.chunks[chunk_num].chunk_weight * word[1])
                    break
        # パターンとのマッチングを行う
        # 「〜を〜と思う」というパターンの場合，
        # 〜は〜を〜と思う　→〜を〜と　のみ抽出
        # ただし，順番が異なる場合，例えば
        # 〜と〜を思う　→マッチングしない
        # 〜を〜を〜と思う　→〜をは重みの大きい方がマッチする
        # 試しに「〜を（は）〜と思う」のパターンでマッチングしてみる
        # kouho = self.get_kouho([["", ""], ["", ""]])
        kouho = []
        if template == "think":
            kouho += self.get_kouho([["名詞", "が"], ["名詞", "に"]])
            kouho += self.get_kouho([["名詞", "が"], ["名詞", "も"]])
            kouho += self.get_kouho([["名詞", "が"], ["名詞", "と"]])
            kouho += self.get_kouho([["名詞", "という"], ["名詞", "は"]])
            kouho += self.get_kouho([["名詞", "な"], ["全部", "だと"]])
            kouho += self.get_kouho([["名詞", "なのは"], ["名詞", "全部"]])
            kouho += self.get_kouho([["名詞", "に"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "に"], ["全部", "と"]])
            kouho += self.get_kouho([["名詞", "に"], ["名詞", "とは"]])
            kouho += self.get_kouho([["名詞", "の"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "の"], ["名詞", "に"]])
            kouho += self.get_kouho([["名詞", "の"], ["名詞", "に"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "の"], ["名詞", "を"]])
            kouho += self.get_kouho([["名詞", "は"], ["名詞", "の"]])
            kouho += self.get_kouho([["名詞", "は"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "は"], ["全部", "と"]])
            kouho += self.get_kouho([["名詞", "を"], ["全部", "と"]])
            kouho += self.get_kouho([["名詞", "を"], ["動詞", "全部"]])
        elif template == "need":
            kouho += self.get_kouho([["名詞", "を"], ["動詞", "全部"]])
            kouho += self.get_kouho([["動詞", "ような"], ["名詞", "も"]])
            kouho += self.get_kouho([["名詞", "の"], ["名詞", "の"]])
            kouho += self.get_kouho([["名詞", "を"], ["動詞", "であれば"], ["名詞", "も"]])
            kouho += self.get_kouho([["名詞", "が"], ["動詞", "全部"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "の"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "として"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "で"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "の"], ["名詞", "に"], ["名詞", "が"]])
            kouho += self.get_kouho([["名詞", "を"], ["全部", "が"]])
            kouho += self.get_kouho([["名詞", "を"], ["動詞", "べきだと"]])
            kouho += self.get_kouho([["名詞", "が"], ["全部", "必要だと"]])
            kouho += self.get_kouho([["名詞", "が"], ["全部", "重要だと"]])
        elif template == "agree":
            return self.get_agrees(template, bm25) + "はいい"
        elif template == "disagree":
            return self.get_agrees(template, bm25) + "はよくない"
        elif template == "None":
            return self.get_None(bm25)
        else:
            print "template error!"
            return "error"
        # マッチングした後，候補の中で最も値の高いものを抽出
        try:
            final = kouho[0]
        except:
            return "kouho error"
        if len(kouho) > 1:
            value = 0.0
            for k in kouho:
                kouho_value = 0.0
                for num in k:
                    kouho_value += self.chunks[num].chunk_weight
                if value < kouho_value:
                    value = kouho_value
                    final = k
        # テンプレート外で見出しの文字数に余裕がある場合は単語間の関係性を考慮した補完を行う
        # 例えば，
        # つながりのある　まちづくりを　したいと　思います
        # の場合，「まちづくりをしたい」では余裕があるため，抽出文節である「まちづくりを」の隣にある「つながりのある」を補完する
        #  →「つながりのあるまちづくりをしたい」
        # 関係性には係り受けを用いる
        # 候補が複数存在する場合は重みの大きい方
        sentence = ""
        for num in final:
            sentence += self.chunks[num].chunk
        if len(sentence)/3 < 20:
            final = list(set(self.hokan(final, 20)))
            sentence = ""
            for num in final:
                sentence += self.chunks[num].chunk
        return sentence
