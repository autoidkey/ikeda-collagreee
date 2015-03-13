#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re

def is_only_hira(text):
    regexp = re.compile(r'^(?:\xE3\x81[\x81-\xBF]|\xE3\x82[\x80-\x93])+$')
    result = regexp.search(text)
    if result != None :
        return True
    else :
        return False

def is_only_char(text, stop_words):
    for st in stop_words:
        if text.replace(st,"") == "":
            return True
    return False

def force_decode(string, codecs=['utf-8']):
    for i in codecs:
        try:
            return string.decode(i)
        except:
            pass


def is_time_or_num(text):
    text = force_decode(text)
    import zenhan
    text = zenhan.z2h(text)
    p = re.compile(u'([0-9:]|時|分)')
    text =  p.sub('', text)
    if text == "":
        return True
    return False


def not_includes(ng_list, word):
    return sum([ng in word for ng in ng_list])

def extraIssueSet(words):
    '''
    ・数詞は抽出しない
    ・平仮名のみの単語は抽出しない • 接頭詞は名詞として扱う
    ・１文字の単語は抽出しない

    I. 名詞の直後に接尾辞が来ていたり,主辞として自動解析された名詞が接尾辞だった場合,接尾辞と名詞 を結合して一つの名詞とみなす.名詞や述語の語尾 の単語は原形にした. 「フォロワー+さん」→「フォロワーさん」 「机+っぽい」→「机っぽい」
    II. 名詞の直後にサ変動詞が来る場合,サ変動詞とその直前の名詞を組み合わせ一つの動詞とみなす. 「心配+する」→「心配する」
    III. 動詞の接尾辞として「やすい」「にくい」あるいは否定語の「ない」「ぬ」が付属している場合,その「動 詞(接尾辞)」を一つの形容詞として扱う.この処理 により肯定の場面と否定の場面で使用される際の極性の違いを区別することができる. 「壊れ+やすい」→「壊れる(やすい)」 「食べにくい」→「食べる(にくい)」 「考えない」→「考える(否定)」 「言わず」→「言う(否定)」
    IV. 「しかし」「だが」「ところが」「けれど」「でも」「が」 などの逆接の接続詞がある場合,コロケーションは 主節から取る.これは逆接を使用する際,書き手の 主張は主節に含まれると考えられるためである. 「ケーキは嫌いだがチョコは好きだ」 →  「チョコ+は+好き」のみ取得.「ケーキ+は+嫌 い」は取得しない



    ・否定語の「ない」「ぬ」
    ・「しかし」「だが」「ところが」「けれど」「でも」「が」 などの逆接の接続詞の後ろから取る
    ・


    名詞  ,固有名詞    ,*          ,*          ,*     ,*     ,ホリエモン,*   ,*    ,wikipedia,
    名詞  ,一般        ,*          ,*          ,*     ,*     ,市        ,シ  ,シ
    品詞  ,品詞細分類1 ,品詞細分類2,品詞細分類3,活用形,活用型,原形      ,読み,発音


    '''

    count = 0
    stop_words = ["みたい","形","的","よろしくお願いします","それぞれ","さ","これ","あの","そのもの","それ","よう","〜","そこ","もの","物","事","こと","も","の","''","場合","(",")",")、","、","。","－","？","！","（","）","〜","､",")","、","～","、","ファシリテーター","...", "ファシリテート","本日","昨日","今日","大変申し訳","申し訳","みんな","皆さん","そう","?","?)","お互い"]
    connect_words = ["の"]

    only_char = ["〜","ー","＝","!","?","！","？","@","#","・","。","、"]

    negative_words = ["ない","ぬ"]

    issue_word = ""
    issue_set = []
    issue_types = []
    combined_issue = {}
    combined_list = []
    for index,word_obj in enumerate(words):
        
        w, parts = word_obj
        w_type,w_type_detail,_,_,w_type_katsuyo,_,w_original,w_read,_,_,_ = parts
        
        if len(words) <=  index+1:
            next_word_is_norm = False
        else:
            next_word_obj = words[index+1]
            n_type,n_type_detail,_,_,n_type_katsuyo,_,n_original,n_read,_,_,_ = next_word_obj[1]
            next_word_is_norm = n_type == "名詞"
        # print w, w_type,w_type_detail,w_type_katsuyo,w_original
        # print w, w_type,w_type_detail,w_type_katsuyo,w_original



        if w_type == "名詞" and w not in stop_words:
            if count == 0:
                count += 1
                issue_word = w
                combined_list = [w]
            else:
                issue_word += w
                combined_list += [w]
        elif count > 0:
            if w_type == "動詞" and "サ変" in w_type_katsuyo:
                issue_word += w_original
                issue_set.append(issue_word)
                issue_types.append("動詞")
                issue_word = ""
                combined_list = []
                count = 0
            elif w in connect_words and next_word_is_norm and w not in stop_words:
                issue_word += w
                count += 1

            # elif w_original in negative_words:
            #     print issue_word,w_original

            else:
                if issue_word != "":
                    combined_issue[issue_word] = combined_list
                    issue_set.append(issue_word)     
                    issue_set.append(w)
                    issue_types.append("名詞")   
                    issue_types.append(w_type)
                    issue_word = ""
                    combined_list = []
                else:
                    issue_set.append(w)
                    issue_types.append(w_type)  

                count = 0
        else:
            issue_set.append(w) 
            issue_types.append(w_type)   
            issue_word = ""

    return locals()