#!/usr/bin/env python#
# coding: utf-8
import os
import sys
import re
import math
import csv
from os import path
from sentence_manager import SentenceManager

# 発言から見出しを取得するためのプログラムです
# 返信先のコメント，見出しを生成したいコメント，BM25の値が必要になります


class CommentManager(object):
    """発言管理クラス"""
    __slots__ = ['henshin', 'comment', 'henshin_sentences', 'comment_sentences']

    def __init__(self, henshin, comment):
        """初期化メソッド"""
        # URLと記号を除去
        self.henshin = self.delete_symbols(henshin)
        self.comment = self.delete_symbols(comment)
        # 文に分ける
        self.henshin_sentences = self.sentence_parse(self.henshin)
        self.comment_sentences = self.sentence_parse(self.comment)

    def delete_symbols(self, comment):
        """URLと記号を削除"""
        c = re.sub('(http://[A-Za-z0-9\'~+\-=_.,/%\?!;:@#\*&\(\)]+)', r'', comment)
        c1 = unicode(c, 'utf-8')
        c2 = re.sub('\!|\?|．|。|！|？', r'\n', c1)
        c3 = re.sub('[!-/:-@[-`{-~、-◯]', r'', c2)
        return c3.encode('utf-8')

    def sentence_parse(self, comment):
        """引数の発言を文に分ける"""
        sentences = re.split(r'\!|\?|．|。|！|？|\n|\r|\t|\v', comment)
        for num in range(0, len(sentences)):
            sentences[num] = sentences[num].strip()
            if len(sentences[num])/3 < 3:
                sentences[num] = ""
        while sentences.count("") > 0:
            sentences.remove("")
        result = []
        for s in sentences:
            result.append(SentenceManager(s))
        return result

    def get_topic(self, bm25):
        """各発言の見出しを格納したリストを返す"""
        need_flag = 0
        think_flag = 0
        need_re_value = -1.0
        think_re_value = -1.0
        judge_value = 0.0
        judge_sentence = ""
        re_sentence = self.get_re_sentence()
        try:
            selected_sentence = self.comment_sentences[0]
            template = "None"
        except:
            return "URL or Symbol only"
        for k in self.comment_sentences:
            # 含まれる単語が１つ以下の場合は文として認めない
            if len(k.get_word()) < 2:
                continue
            #1: 必要・すべき　がふくまれている
            if k.get_need() >= 1:
                if k.get_re_value(re_sentence) > need_re_value:
                    need_flag = k.get_need()
                    need_re_value = k.get_re_value(re_sentence)
                    template = "need"
                    selected_sentence = k
                else:
                    if need_flag < k.get_need():
                        need_flag = k.get_need()
            #2: 思う・考える　が含まれている
            elif k.get_think() >= 1 and need_flag < 1:
                if k.get_re_value(re_sentence) > think_re_value:
                    think_flag = k.get_think()
                    think_re_value = k.get_re_value(re_sentence)
                    template = "think"
                    selected_sentence = k
                else:
                    if think_flag < k.get_think():
                        think_flag = k.get_think()
            #3: 返信先の賛否によって変化する
            else:
                #返信先に賛成・反対の要素が最も大きい文を取り出す　賛成・反対は問わない
                #返信先に賛成で賛成要素の大きい文
                j = k.get_judgment()
                if j >= 0.0 and math.fabs(judge_value) < j and need_flag < 1 and think_flag < 1:
                #if comment_agree_oppose == 1 and math.fabs(judge_value) < math.fabs(k.get_judgment()) and need_flag < 1 and think_flag < 1:
                    template = "agree"
                    selected_sentence = k
                    judge_value = j
                #返信先に反対で反対要素の大きい文
                elif j < 0.0 and math.fabs(judge_value) < math.fabs(j) and need_flag < 1 and think_flag < 1:
                    template = "disagree"
                    selected_sentence = k
                    judge_value = j
                #以上のどれにも当てはまらない場合
                elif judge_value == 0.0 and need_flag < 1 and think_flag < 1:
                    template = "None"
        # 「と思います」「という〜」「のような〜」のような表現で改行されている場合に対応　一つ前の文を取る
        if selected_sentence.get_original_sentence().startswith("と") or selected_sentence.get_original_sentence().startswith("の"):
            selected_sentence = comment[comment.index(selected_sentence)-1]
        # 重み付けして見出しを生成
        weight_result = selected_sentence.get_weighting(bm25, template)
        # モデルマッチングができなかったものを処理（先頭１５文字を取得）
        if weight_result == "kouho error":
                weight_result = selected_sentence.get_original_sentence()[0:45]
        # 生成した見出しを整形
        judge_sentence = self.format_sentence(weight_result)
        return judge_sentence

    def get_re_sentence(self):
        """スレ主のコメントに含まれる単語を返す"""
        result = []
        for sentence in self.henshin_sentences:
            result += sentence.get_word()
        return result

    def format_sentence(self, sentence):
        """生成した見出しから余計な表現を消す"""
        # 出現消去
        sentence = re.sub('でしょう|です|でした', "", sentence)
        # 置き換え
        sentence = self.replace_sentence(sentence)
        # 文末消去
        sentence = self.delete_ends(sentence)
        return sentence

    def replace_sentence(self, sentence):
        """文に含まれる表現の置き換えを行う"""
        # あります　しなければならない　しなければなりません　必要性がある　おります　しました
        # ある　　　する必要　　　　　　する必要　　　　　　　必要性　　　　いる　　　した
        replace_words = {"あります":"ある",
                        "しなければならない":"する必要",
                        "しなければなりません":"する必要",
                        "必要性がある":"必要性",
                        "おります":"いる",
                        "しました":"した"}
        find_list = re.findall('しなければなりません|しなければならない|必要性がある|あります|おります|しました', sentence)
        for x in find_list:
            sentence = re.sub(x, replace_words[x], sentence)
        result = sentence
        return result

    def delete_ends(self, sentence):
        """文末に含まれる不要表現を消去する"""
        # 一度unicodeにしてから処理しないとうまくいかない模様
        # を　も　と　の　に　は　だ　ね　よ　が　ん　思う　思います　ように　感じます　なの　かもしれない　なっています　思われます　かも　考えられます　しれません　いう　考える　かと
        s = unicode(sentence, 'utf-8')
        while True:
            find_list = re.findall(u'かもしれない|考えられます|なっています|思われます|しれません|思います|感じます|考える|ように|思う|なの|かも|んだ|いう|かと|を|も|と|の|に|は|だ|ね|よ|が', s)
            cnt = 0
            for x in find_list:
                if s.endswith(x):
                    cnt += 1
                    s = s.rstrip(x)
            if cnt == 0:
                break
        s = s.encode('utf-8')
        return s

if __name__ == '__main__':

    argvs = sys.argv
    """コマンドラインからの入力"""
    # print "返信先の発言を入力してください"
    # henshin = raw_input()
    henshin = argvs[0]
    # print "見出しを生成する発言を入力してください"
    # comment = raw_input()
    comment = argvs[1]
    del argvs[0]
    # BM25の取得　このプログラムではBM25が取得できないため追加
    length = len(argvs) / 2
    bm25 = []
    for var in range(1, length):
        bm25.append([argvs[var*2], float(argvs[var*2+1])])

    if len(henshin)/3 < 2:
        print "入力が正しくありません"
        sys.exit(1)

    try:
        henshin = henshin.encode('utf-8')
        comment = comment.encode('utf-8')
    except:
        pass


    # 返信先のコメント，見出しを生成したいコメントをstr型の引数としてインスタンスを生成
    a = CommentManager(henshin, comment)
    # bm25の値が格納されたリスト(例["名古屋", 12.9567])を引数としてget_topic(bm25)
    # 返り値が生成された見出しになる
    print a.get_topic(bm25)
