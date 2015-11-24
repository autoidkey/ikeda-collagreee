#!/usr/bin/env python#
# coding: utf-8
import os, sys
import csv
import collections
from prettyprint import pp
from os import path

"""感情極性辞書から単語の取得　→　noun, declinable"""

read_file = open("python/midashi/tools/nega_posi_eq_meishi.csv", "rb")  # 読み込み用ファイルオープン
noun = {}
for row in csv.reader(read_file):  # ファイル読み込み
    #print row
    value = row[0].split()
    if value[1] == "p":
        noun[value[0]] = 1.0
    elif value[1] == "n":
        noun[value[0]] = -1.0
    else:
        noun[value[0]] = 0.0
#pp(noun)
#c = collections.Counter(noun.values())
#print "p:", c[1], "n:", c[-1], "e:", c[0] #p: 3350 n: 4958 e: 5002
read_file.close()
#sys.exit(1)

read_file = open("python/midashi/tools/nega_posi_yogen.txt", "r")
declinable = {}
for row in read_file.readlines():
    value = row.split()
    word = ""
    for w in range(1, len(value)):
        word += value[w]
    if value[0] in ("ポジ（評価）", "ポジ（経験）"):
        declinable[word] = 1.0
    else:
        declinable[word] = -1.0
#pp(declinable)
#c = collections.Counter(noun.values())
#print "p:", c[1], "n:", c[-1], #p: 3350 n: 4958
read_file.close()
#sys.exit(1)


class NegaPosiJudge(object):
    """ネガ・ポジ判定した文を管理するクラス"""
    def __init__(self, sentence=["None"]):
        """初期化メソッド"""
        self.value = self.judge(self.n_gram(sentence, 4))

    def judge(self, sentence=["None"]):
        """判定メソッド"""
        judged = 0.0
        self.judged_word = []
        for n in range(0, len(sentence)):
            for k in sentence[n]:
                word = ""
                for i in k:
                    word += i
                #print word
                try:
                    judged += 1.0 * (n+1) / len(sentence) * noun[word]
                    self.judged_word.append([word, noun[word]])
                except:
                    pass
                try:
                    judged += 1.0 * (n+1) / len(sentence) * declinable[word]
                    self.judged_word.append([word, declinable[word]])
                except:
                    pass
        return judged

    def get_judge(self):
        """判定結果を返す"""
        return self.value

    def get_judged_word(self):
        """何かを返す(何かは考えてない)"""
        return self.judged_word

    def n_gram(self, sentence, n):
        """n-gramを計算する"""
        result = []
        for i in reversed(range(1, n+1)):
            result.append([sentence[k:k+i] for k in range(len(sentence)-i+1)])
        return result
    #使い方
    # a = NegaPosiJudge(sentence) sentenceはリスト化した単語
    # x = a.get_judge()
    # print x


if __name__ == "__main__":
    """メイン　試験用"""
    #result = NegaPosiJudge(["私", "は", "本", "を", "読み", "ます"])
    #print result.get_judge()
    string = ["私", "は", "本", "を", "読み", "ます", "できない", "ない", "いかさま", "あせも", "デフレ"]
    a = NegaPosiJudge(string)
    print a.get_judge()
    #pp(noun.keys())
