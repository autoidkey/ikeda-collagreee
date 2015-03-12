#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import difflib
import csv
import numpy as np
import scipy.spatial.distance
import MeCab
import mojimoji
import jctconv

def extract_time(time):
    return time.split(" ")[0]# +" "+ time.split(":")[0].split(" ")[-1]+":00:00"

# 共通の単語を返す
def calculate_set(set1,set2):
    return list(set1 & set2)


def extractKeywordAll(text):
    u"""textを形態素解析して、名詞のみのリストを返す"""
    tagger = MeCab.Tagger('-Ochasen')

    encoded_text = text

    if tagger.parseToNode(encoded_text) is None:
        return []
    node = tagger.parseToNode(encoded_text).next
    keywords = []
    while node:

        word = node.surface
        if word == "":
            node = node.next # 空の文字はスキップする
            continue

        parts = node.feature.split(",")
        # 全角から半角へ
        word = mojimoji.zen_to_han(word.lower().decode("utf-8"),kana=False).encode("utf-8")
        if len(parts) < 11:
            parts = parts + ["" for _ in range(11-len(parts))]
        w_name,w_type,_,_,_,_,w_original,w_read,_,_,_ = parts
        
        # 読みがなをひらがなに
        if w_read != "*":
            w_read_hira = jctconv.kata2hira(w_read.decode("utf-8"))
            parts[7] = w_read_hira 

        # 基本形を半角へ
        # w_original = mojimoji.zen_to_han(w_original.lower().decode("utf-8"),kana=False).encode("utf-8")
        # parts[6]   = w_original
        node = node.next

        keywords.append( (word, parts ))
    return keywords



#行列の指定行indexをリストに変換
def matTolist(mat, index):
    #return mat[index].tolist()[0]
    return np.array(mat[index]).reshape(-1,).tolist()

# cosine類似度
def cosine_similarity(vec1, vec2):
    u'''コサイン類似度。
    vec1, vec2 は同次元の特徴ベクトル(リスト型)。
    文章の類似度を測るために使われる指標の一つ。
    同一ベクトルであれば類似度=1(最大値)。
    全く異なる場合は類似度=0(最小値)。
    # >>> len(vec1) == len(vec2)
    True
    '''
    import math
    numerator = sum([vec1[x]*vec2[x] for x in range(len(vec1))])
    sum1 = sum([vec1[x]**2 for x in range(len(vec1))])
    sum2 = sum([vec2[x]**2 for x in range(len(vec2))])
    denominator = math.sqrt(sum1) * math.sqrt(sum2)
    if not denominator:
        return 0.0
    else:
        return float(numerator) / denominator


# 初期特徴ベクトル(mat)で類似度を確認。
def printMatSim(mat):
    for i in range(len(mat)):
        str = ""
        str += "d%d:" % (i)
        #j = i+1
        j = 0
        while j < len(mat):
            str += "%f, " % (cosine_similarity(matTolist(mat,i),matTolist(mat,j)))
            j = j+1
        print str


def MatSim(mat):
    mat_sim_result = []
    for i in range(len(mat)):
        i_vec = mat[i]
        #j = i+1
        sims = [1.0 - scipy.spatial.distance.cosine(i_vec, mat[j]) for j in range(len(mat))]        
        # sims = [(j,cosine_similarity(matTolist(mat,i),matTolist(mat,j))) for j in range(len(mat))]
        mat_sim_result.append(sims)
    return np.array(mat_sim_result)


def make_vectors(docs):
    u'''文書集合docsから、codebook(n-gram)に基づいた文書ベクトルを生成。
    codebook毎に出現回数をカウントし、ベクトルの要素とする。
    出力 vectors[] は、「1文書の特徴ベクトルを1リスト」として準備。
    '''
    import nltk
    codebook = list(set([word for doc in docs for word in doc ]))
    vectors = []
    for doc in docs:
        fdist = nltk.FreqDist()
        for word in doc:
            # fdist.inc(word)
            fdist[word] += 1          
        this_vector = []
        for word in codebook:
            this_vector.append(fdist[word])
        vectors.append(this_vector)
    return vectors


# R用にネットワークのデータを保存する
def save_graph_format(co_occurence_obj=None, csv_filename="graph_data.csv",min_count=1):
    f = open(csv_filename, 'w')
    writer = csv.writer(f, lineterminator='\n',delimiter=',')
    # ヘッダーを書き込む
    writer.writerow(["node1","node2","count"])

    for nodes,count in co_occurence_obj.iteritems():
        if count < min_count:
            continue
        n1, n2 = nodes.split("\t")
        # n1 = n1.encode("utf-8")
        # n2 = n2.encode("utf-8")
        l = [n1,n2,count]
        writer.writerow(l)
        # nodelist.append(n1)
        # nodelist.append(n2)
    f.close()


# 全単語をくっつけさせる
def extraCoOccurrence(docs):
    freqpair = {}
    for line in docs:
        words = line
        for i in xrange(len(words)):
            for j in xrange(len(words)):
                if i == j or words[i] == words[j]:
                    continue
                # print words[i]
                # print words[j]
                dic_key = words[i] + "\t" + words[j]
                if dic_key in freqpair:
                    freqpair[dic_key] += 1
                else:
                    freqpair[dic_key] = 1
    return freqpair

# 前後の単語の共起のみを考慮
def extraCoOccurrence_win(docs,window=2, window_r=0, mode=1):
    ''' 
    mode :  1: j => i  (周辺単語から語へ)
            2: i => j  (語から周辺単語へ)
    '''
    freqpair = {}
    for line in docs:
        words = line
        for i in xrange(len(words)):
            start = max(i-window, 0)
            end   = min(i+window_r+1, len(words))
            for j in xrange(start,end):
                if i == j:
                    continue
                # エッジの方向をmodeによって場合分け
                if mode == 1:
                    dic_key = words[j] + "\t" + words[i]
                else:
                    dic_key = words[i] + "\t" + words[j]

                if dic_key in freqpair:
                    freqpair[dic_key] += 1
                else:
                    freqpair[dic_key] = 1
    return freqpair

# 前から後ろへ
def extraCoOccurrence_bf2af(docs):
    freqpair = {}
    for line in docs:
        words = line
        for i in xrange(len(words)):
            for j in xrange(i + 1, len(words)):
                dic_key = words[i] + "\t" + words[j]
                if dic_key in freqpair:
                    freqpair[dic_key] += 1
                else:
                    freqpair[dic_key] = 1
    return freqpair

# 後ろから前へ
def extraCoOccurrence_af2bf(docs):
    freqpair = {}
    for line in docs:
        words = line
        for i in xrange(len(words)):
            for j in xrange(i + 1, len(words)):
                dic_key = words[j] + "\t" + words[i]
                if dic_key in freqpair:
                    freqpair[dic_key] += 1
                else:
                    freqpair[dic_key] = 1
    return freqpair




# 共通の単語を返す(類似度も考慮)
def calculate_set2(set1,set2):
    result = calculate_set(set1,set2)
    for i1,s1 in enumerate(set1):
        for i2,s2 in enumerate(set2):

            # カウントが少ない方が抽象化される
            # w_minor = s2 if word_dict_count.get(s1) >  word_dict_count.get(s2) else s1
            # w_major = s1 if word_dict_count.get(s1) >  word_dict_count.get(s2) else s2

            sim = diff_sim(s1, s2)
            if sim > 0.8:
                result.append(s1)
                # result.append(s2)
                # print s1,s2 , "  = ",sim

    return list(set(result))
    # return list(set1 & set2)

# ユーザの返信関係を計算する

def diff_sim(w1,w2):
    return difflib.SequenceMatcher(None, w1, w2).quick_ratio()

# 文章内の単語を数え上げる
def doc_to_word_count(doc):
    word_and_counts = {}
    for word in doc:
        word_and_counts[word] = word_and_counts.get(word,0) + 1
    return word_and_counts


# 類似する単語をまとめる  例：コミュニティサイクル，コミュニティーサイクル
def words_to_abstraction(words_list, word_dict_count ,threhold = 0.9):
    import difflib
    abst_dict = {}
    for i in xrange(len(words_list)):
        w1 = words_list[i]
        for j in xrange(i,len(words_list)):
            w2 = words_list[j]
            # 同じ単語の類似度は取らない
            if w1 == w2:
                continue
            # カウントが少ない方が抽象化される
            w_minor = w2 if word_dict_count.get(w1) >  word_dict_count.get(w2) else w1
            w_major = w1 if word_dict_count.get(w1) >  word_dict_count.get(w2) else w2
            if abst_dict.get(w_minor, None) is not None:
                continue
            sim = difflib.SequenceMatcher(None, w1, w2).quick_ratio()
            if sim > threhold:
                abst_dict[w_minor] = w_major
    # 再帰的な変換を統一する
    for w in abst_dict.keys():
        # print w
        w_major = abst_dict.get(w)

        while (True):
            if w_major in abst_dict:
                # print "###"
                replace_major_word = abst_dict.get(w_major)
                if replace_major_word == w:
                    break
                abst_dict[w] = replace_major_word
                w_major = replace_major_word
            else:
                break


    return abst_dict

# 文字の前処理
def pre_process(s):
    s = s.replace("'","").replace('"','')
    return s



def remove_url(text):
    p = re.compile(r"<[^>]*?>")
    text = p.sub("", text) 
    text = strip_tags(text)
    text = re.sub(r'(http|https)(://[[:alnum:]\S\$\+\?\.-=_%,:@!#~*/&-]+)', '', text)
    text = re.sub(r'^https?:\/\/.*[\r\n-]*', '', text, flags=re.MULTILINE)
    return text


# コミュニティ抽出したファイルを整形する
def load_community_file(filename="csv/all/Community.txt"):

    dataReader = csv.reader(file(filename),delimiter=' ')
    clusters = {}
    word2clusterindex = {}
    # ヘッダー部分を省略する
    fline = dataReader.next()
    for line in dataReader:
        print len(line)
        print line[0]
        print line[1]
        nindex,node,c_index = line
        index = str(nindex)+"_"+str(c_index)
        # print "node", node, type(node)
        # node = node.ecode("utf-8")
        clusters[index] = clusters.get(index, []) + [node]
        word2clusterindex[node] = index
    
    nclustrs = {}
    for key,c in clusters.items():
        index = key.split("_")[0]
        nclustrs[index] = nclustrs.get(index,0) + len(c)


    # for key,c in sorted(clusters.items() ,key=lambda x:nclustrs.get(x[0].split("_")[0]), reverse=True):
    #     print "+"*30
    #     print "-",key
    #     for node in c:
    #         print node
    # print clusters.keys()
    return clusters,nclustrs,word2clusterindex


# 単語の重要度のファイルを読み込む(Rで計算した結果ファイル)
def load_node_files(filename="csv/csv_user_all/Newtube758/pagerank.txt"):
    dataReader = csv.reader(file(filename),delimiter=' ')
    score_dict = {}
    # ヘッダー部分を省略する
    fline = dataReader.next()
    for line in dataReader:
        word,score = line
        word = word.replace('"','')
        score_dict[word] = float(score)

        # print word,score
    return score_dict

# 単語の置換をした文書を返す
def docs_replace_words(docs, replace_dict):
    replaced_docs = []
    for line in docs:
        words = line
        for i in xrange(len(words)):
            if words[i] in replace_dict:
                line[i] = replace_dict[words[i]]
            # else:
                # for k,v in replace_dict.items():
                    # line[i] = line[i].replace(k,v)
        # docs[i] = line
        replaced_docs.append(line)
    return replaced_docs    


from HTMLParser import HTMLParser

class MLStripper(HTMLParser):

    def __init__(self):
        self.reset()
        # stripしたテキストを保存するバッファー
        self.fed = []

    def handle_data(self, d):
        # 任意のタグの中身のみを追加していく
        self.fed.append(d)

    def get_data(self):
        # バッファーを連結して返す
        return ''.join(self.fed)

def strip_tags(html):
    s = MLStripper()
    s.feed(html)
    return s.get_data()    