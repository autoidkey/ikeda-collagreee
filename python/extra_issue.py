#!/usr/bin/env python
# -*- coding: utf-8 -*-

''' 
 議論における複合語を抽出してMecabの辞書に追加するプログラム

 sato
'''
import jctconv
import MeCab
import re
import sys
import nltk
from itertools import chain
import csv
from gensim import corpora, models, similarities
import mojimoji

import csv
import pygraphviz as pgv
import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.pyplot as pyplot
from tfidf import TFIDF
import numpy as np
from sklearn.cluster import KMeans, MiniBatchKMeans
from x_means import XMeans

def extractKeywordAll(text):
    u"""textを形態素解析して、名詞のみのリストを返す"""
    tagger = MeCab.Tagger('-Ochasen')
    encoded_text = text.encode('utf-8')

    if tagger.parseToNode(encoded_text) == None:
        return []
    node = tagger.parseToNode(encoded_text).next
    keywords = []
    while node:
        if True:
            keywords.append(node.surface)
        node = node.next
    return keywords

def extractParts(text, limit=["名詞"],nolimit=False):
    u"""textを形態素解析して、名詞のみのリストを返す"""
    tagger = MeCab.Tagger('-Ochasen')
    # encoded_text = text.encode('utf-8')
    encoded_text = text
    if tagger.parseToNode(encoded_text) == None:
        return []
    node = tagger.parseToNode(encoded_text).next
    keywords = []
    while node:
        if node.feature.split(",")[0] in limit or nolimit == True:
            parts = node.feature.split(",")
            keywords.append((mojimoji.zen_to_han(node.surface.lower().decode("utf-8"),kana=False).encode("utf-8"), parts[0].lower(), parts[6].lower()))

        node = node.next
    return (keywords)

# 単語の置換をした文書を返す
def docs_replace_words(docs, replace_dict):
    replaced_docs = []
    for line in docs:
        words = line
        for i in xrange(len(words)):
            if words[i] in replace_dict:
                line[i] = replace_dict[words[i]]
        # docs[i] = line
        replaced_docs.append(line)
    return replaced_docs

# 全単語をくっつけさせる
def extraCoOccurrence(docs):
    freqpair = {}
    for line in docs:
        words = line
        for i in xrange(len(words)):
            for j in xrange(len(words)):
                if i == j or words[i] == words[j]:
                    continue
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





# doc1 = [u'国民', u'安心', u'安心', u'安全']  
# doc2 = [u'国民', u'国民', u'国民', u'生活', u'生活',u'安心']  
# doc3 = [u'生活', u'安全', u'安全']  
# doc4 = [u'生活', u'生活', u'生活', u'安心', u'安心', u'安全']  
# doc5 = [u'生活', u'生活', u'安心', u'安心', u'安心']  
# docs = [doc1, doc2, doc3, doc4, doc5]  
# tf_idf_test(docs)  


# def tf_idf_test(docs):  
#     tokens = [u'国民', u'安心', u'安心', u'安全', u'国民']  
#     for doc in docs:  
#         tokens += doc  
#     A = nltk.TextCollection(docs)  
#     token_types = set(tokens)  
#     for token_type in token_types:  
#         print token_type  
#         print 'TF = %f' % A.tf(token_type, tokens)  
#         print 'IDF = %f'% A.idf(token_type)  
#         print 'TF-IDF = %f' % A.tf_idf(token_type, tokens)  


def tfidf(doc,docs):
  """対象の文書と全文の形態素解析した単語リストを指定すると対象の文書のTF-IDFを返す"""
  tokens = list(chain.from_iterable(docs)) #flatten
  A = nltk.TextCollection(docs)
  token_types = set(tokens)

  return [{"word":token_type,"tfidf":A.tf_idf(token_type, doc)} for token_type in token_types]


# 論点を抽出する関数
# def extraNorm(text):
#     print "extraIssue"

#     csv_filename = 'corpus/collagree_theme_jinken.csv'
#     csv_filename = 'corpus/collagree_theme_saigai.csv'
#     csv_filename = 'corpus/collagree_theme_miryoku.csv'
#     # csv_filename = 'corpus/collagree_theme_kankyo.csv'

#     dataReader = csv.reader(file(csv_filename))
#     fline = dataReader.next()
#     body_index = fline.index("body")
#     limit = ["名詞","形容詞","動詞"]
#     docs = [extractParts(line[body_index],limit=limit,nolimit=True) for line in dataReader]
#     # print parts

#     norm_all = []
#     new_docs = []
#     new_doc = []
#     for i,words in enumerate(docs):

#         count = 0
#         new_doc = []
#         for j,w in enumerate(words):
#             # w[0] = w[0].replace("　","")
#             word = w[0].decode("utf-8")

#             new_doc.append(word)

#             if w[1] == "名詞":
#                 # norm_all.append(word)
#                 # new_doc.append(word)
#                 count += 1

#                 # print total_norm

#             elif count >= 2:

#                 total_norm = ""
#                 for c in reversed(range(count)):
#                     total_norm += words[j-c-1][0]

#                 # del new_doc[-count-1:]
#                 if "さん" not in total_norm:
#                     norm_all.append(total_norm.decode("utf-8"))
#                     new_doc.append(total_norm.decode("utf-8"))
#                 # new_doc.append(word)
#                 count = 0
#             else:
#                 count = 0
#         new_docs.append(new_doc)
    

#     tfidf_issue = tfidf(doc=norm_all, docs=new_docs)
#     tfidf_issue.sort(cmp=lambda x,y:cmp(x["tfidf"],y["tfidf"]),reverse=True)

#     result = [e for i,e in enumerate(tfidf_issue) if e["tfidf"] > 0.0 and len(e["word"]) > 1 if i < 20]

#     for i in result:
#         print i.get("tfidf"), i.get("word")

def show_result(items, show_neighbors=False):
    # 次数でソート & 隣接ノードの計算 G.degree().items()
    for node in sorted( items, key=lambda x:x[1], reverse=True):

        if node[0].encode("utf-8") in adjective_all:
            # print "スキップ"
            continue # 形容詞の場合はスキップ
        print "(%s)[%s]" % (node[1],node[0])


        if show_neighbors == True:
            for near_node in unG.neighbors(node[0]):
                if near_node == node[0].encode("utf-8"):
                    continue
                print near_node,
            print ""

    print ""

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
        n1 = n1.encode("utf-8")
        n2 = n2.encode("utf-8")
        l = [n1,n2,count]
        writer.writerow(l)
        # nodelist.append(n1)
        # nodelist.append(n2)
    f.close()



def show_graph(co_occurence_obj=None, graph_filename="c_graph.png",min_count=1,adjective_all=[]):



    # G = pgv.AGraph(strict=False, directed=True,concentrate=True,overlap=True, ranksep = 1, nodesep = 4.0)

    G = nx.DiGraph()

    # nodelist = []
    # for nodes,count in co_occurence_obj.iteritems():
    #     if count <= 1:
    #         continue
    #     n1, n2 = nodes.split("\t")
    #     nodelist.append(n1)
    #     nodelist.append(n2)

    # nodelist = list(set(nodelist))
    # G.add_nodes_from(nodelist,color="red",style='filled', shape='box',alpha="0.5")



    # clusterings = dict()
    # cluster_index = 0
    # for nodes,count in co_occurence_obj.iteritems():

    #     if clusterings.get(cluster_index,[]) == []:
    #         clusterings[i] = []

    #     n1, n2 = nodes.split("\t")

    #     clusterings[cluster_index].append(n1)
    #     clusterings[cluster_index].append(n2)





    for nodes,count in co_occurence_obj.iteritems():
        if count < min_count:
            continue
        n1, n2 = nodes.split("\t")
        # nodelist.append(n1)
        # nodelist.append(n2)
        G.add_node(n1)
        G.add_node(n2)
        G.add_edge(n1,n2, len=max(3.5, 4.5-count), weight=count,color='gray')
        # G.add_edge(edge1,edge2,label=count)
        

    # nodelist = list(set(nodelist))
    # G.add_nodes_from(nodelist)

    # for prog in "neato,dot,twopi,fdp,nop,circo".replace(" ","").split(","):
    # print prog

    prog = "neato"
    # 描写用に変換
    draw_graph = nx.to_agraph(G)
    draw_graph.layout(prog=prog)
    draw_graph.draw(graph_filename)

    # ノード数
    print G.number_of_nodes()
    # エッジ数
    # print G.number_of_edges()



    # print "-"*10
    # # 次数でソート
    # for node in sorted(G.degree().items() , key=lambda x:x[1], reverse=True)[:10]:
    #     print node[0],node[1],
    # print ""

    # # 入次数でソート
    # print "-"*10
    # for node in sorted(G.in_degree().items() , key=lambda x:x[1], reverse=True)[:10]:
    #     print node[0],node[1],
    # print ""

    # # 出次数でソート
    # print "-"*10
    # for node in sorted(G.out_degree().items() , key=lambda x:x[1], reverse=True)[:10]:
    #     print node[0],node[1],
    # print ""

    # # PageRank
    # print "-"*10
    # for node in sorted(nx.pagerank(G,alpha=0.9).items() , key=lambda x:x[1], reverse=True)[:10]:
    #     print node[0],node[1],
    # print ""


    # print adjective_all


    # クラスタリング
    unG = G.to_undirected()
    # print nx.clustering(unG)



    # # Tf-Idfを足し合わせる
    # tf_idf_nodes_sum = dict()
    # for node in G.nodes():
    #     tf_idf_nodes_sum[node] = sum([tfidf_dict.get(near_node) for near_node in unG.neighbors(node)])

    
    # # Tf-Idfの平均
    # tf_idf_nodes_average = dict()
    # for node in G.nodes():
    #     l = [tfidf_dict.get(near_node) for near_node in unG.neighbors(node)]
    #     tf_idf_nodes_average[node] = sum(l) / len(l)


    # for node in G.nodes():
    #     print node
    #     print  G.neighbors(node) # 入りノード
    #     print  unG.neighbors(node) # 接続したノード


    def tf_idf_nodes(is_average=False, is_in_degree=True , self_node=0):
        # sum     : self_node = 1
        # average : self_node = 2
        if is_in_degree == True:
            GG = G # 入りノード
        else:
            GG = unG # 接続ノード

        tf_idf_nodes = dict()
        for node in G.nodes():
            l = [tfidf_dict.get(near_node) for near_node in GG.neighbors(node)]
            v = sum(l)

            if is_average == True and len(l) != 0:
                v = sum(l) / len(l) # 平均を取る


            if self_node > 0:
                if self_node == 1:
                    v += tfidf_dict.get(node) # 自身のTf-Idf値を足し合わせる
                # if self_node == 2:
                    # v = (v + tfidf_dict.get(node) )/ 2.0 # 自身のTf-Idf値との平均





            tf_idf_nodes[node] = v

        return tf_idf_nodes


    print "*"*40

    print "degree"
    show_result(G.degree().items())


    print "*"*40
    print "degree tfidf sum"
    show_result(tf_idf_nodes(is_average=False, is_in_degree=False).items())


    print "*"*40
    print "degree tfidf sum self sum"
    show_result(tf_idf_nodes(is_average=False, is_in_degree=False, self_node=1).items())

    # print "*"*40
    # print "degree tfidf sum self average"
    # show_result(tf_idf_nodes(is_average=False, is_in_degree=False, self_node=2).items())


    print "*"*40
    print "degree tfidf average"
    show_result(tf_idf_nodes(is_average=True, is_in_degree=False).items())
    

    print "*"*40
    print "degree tfidf average self"
    show_result(tf_idf_nodes(is_average=True, is_in_degree=False,self_node=1).items())
    

    # print "*"*40
    # print "degree tfidf average self average"
    # show_result(tf_idf_nodes(is_average=True, is_in_degree=False,self_node=2).items())
    


    print "*"*40
    print "in_degree"
    show_result(G.in_degree().items())

    print "*"*40
    print "in_degree tfidf sum"
    show_result(tf_idf_nodes(is_average=False, is_in_degree=True).items())


    print "*"*40
    print "in_degree tfidf sum self sum"
    show_result(tf_idf_nodes(is_average=False, is_in_degree=True, self_node=1).items())

    print "*"*40
    print "in_degree tfidf sum self average"
    show_result(tf_idf_nodes(is_average=False, is_in_degree=True, self_node=2).items())


    print "*"*40
    print "in_degree tfidf average"
    show_result(tf_idf_nodes(is_average=True, is_in_degree=True).items())

    print "*"*40
    print "in_degree tfidf average self"
    show_result(tf_idf_nodes(is_average=True, is_in_degree=True,self_node=1).items())

    # print "*"*40
    # print "in_degree tfidf average self average"
    # show_result(tf_idf_nodes(is_average=True, is_in_degree=True,self_node=2).items())


    print "*"*40
    print "out_degree"
    show_result(G.out_degree().items())

    print "*"*40
    print "pagerank"
    show_result(nx.pagerank(G,alpha=0.9).items())




    print "*"*40

    # ノード一覧
    # print G.nodes()

    # clusterings = dict()
    # Q = []
    # cluster_index = 0
    # visited = set()
    # import sys
    # sys.setrecursionlimit(100000)


    # def cluster_search(node,cluster_index):

    #     if clusterings.get(cluster_index,[]) == []:
    #         clusterings[cluster_index] = set()
    #     clusterings[cluster_index].add(node)
    #     visited.add(node)
    #     for neighbor in unG.neighbors_iter(node):
    #         Q.append(neighbor)

    #     for q_node in Q:
    #         cluster_search(q_node, cluster_index)
    #         # clusterings[cluster_index].add(q_node)
    #         # visited.add(q_node)



    # for i,node in enumerate(unG.nodes()):
    #     if node not in visited:
    #         cluster_index = i
        
    #     cluster_search(node, cluster_index)


    # print clusterings.keys()

    # #ネットワークのグループ化
    # all_nodes = unG.nodes()
    # grouped_nodes = set()
    # groups = dict()
    # cluster_index = 0
    # for node in all_nodes:

    #     if node in grouped_nodes:
    #         continue

    #     neighbors = list(nx.bfs_edges(unG,node))
    #     if len(neighbors) == 0:
    #         continue

    #     group = list(reduce(lambda x,y: list(x)+list(y),neighbors))

    #     # group = [i for i in set_i for set_i in list(nx.bfs_edges(unG,node))]

    #     # print len(group)
    #     groups[cluster_index] = group

    #     cluster_index += 1


    #     grouped_nodes = set(list(grouped_nodes) + (group))

    # print groups.keys()
    # group_value = [len(groups[key]) for key in groups.keys()]
    # print group_value
    # print [float(i)/sum(group_value) for i in group_value]
    # for i in grouped_nodes:
        # print i
    # print G.edges()
    # for n in G.neighbors_iter(u"コミュニティサイクル  "):
        # print n
    # 次数
    # print G.degree()
    # 入次数
    # print G.in_degree()
    # 出次数
    # print len(G.out_degree())
    # PageRankを求める
    # print nx.pagerank(G,alpha=0.9)
    return G



def extraNormList(words,limit=["名詞","形容詞"]):
    count = 0
    new_doc = []
    norm_all = []
    hiragana_no_flag = False
    converted_words_dict = {}
    for j,w in enumerate(words):
        # w[0] = w[0].replace("　","")
        word = w[0].decode("utf-8")
        word_original = w[2].decode("utf-8")


        

        # if w[1] == "動詞":
            # new_doc.append(word_original)

        if w[1] == "形容詞" and w[1] in limit:
            # new_doc.append(word_original) #形容詞を除く？
            new_doc.append(word_original)
        # 「の」は例外にする
        conditon_add = count > 1 and w[0] in ["の","・"]
        if conditon_add:
            count += 1

        elif w[1] == "名詞" and w[0] not in ["みたい","形","的","よろしくお願いします","それぞれ","さ","それ","よう","〜","そこ","もの","物","事","こと","も","の","''","場合","(",")",")、","、","。","－","？","！","（","）","〜","､",")","、"] and w[1] in limit:
            # norm_all.append(word)
            # new_doc.append(word)
            count += 1

            # print total_norm

        elif count >= 2:
            if hiragana_no_flag:
                count = 0
                continue

            total_norm = ""
            conv_w_list = []
            for c in reversed(range(count)):
                total_norm += words[j-c-1][0]
                conv_w_list.append(words[j-c-1][0].decode("utf-8"))

            converted_words_dict[total_norm.decode("utf-8")] = conv_w_list

            # del new_doc[-count-1:]
            if "さん" not in total_norm and "http" not in total_norm and "さま" not in total_norm:
                norm_all.append(total_norm.decode("utf-8"))
                new_doc.append(total_norm.decode("utf-8"))
            count = 0
        elif count == 1:
            norm_all.append(words[j-1][0].decode("utf-8"))
            if len(words[j-1][0].decode("utf-8")) >= 1: # TODO 長さを１つに変更
                new_doc.append(words[j-1][0].decode("utf-8")) # 1つの名詞も追加 CHECK
            count = 0

        else:
            # new_doc.append(word_original)
            count = 0


        hiragana_no_flag = False
        if conditon_add:
            hiragana_no_flag = True

    return norm_all,new_doc,converted_words_dict


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
        print w
        w_major = abst_dict.get(w)

        while (True):
            if w_major in abst_dict:
                print "###"
                replace_major_word = abst_dict.get(w_major)
                if replace_major_word == w:
                    break
                abst_dict[w] = replace_major_word
                w_major = replace_major_word
            else:
                break


    return abst_dict

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


# コミュニティ抽出したファイルを整形する
def load_community_file_overlapping(filename="csv/all/un_overlapping.txt"):
    dataReader = csv.reader(file(filename),delimiter=' ')
    clusters = {}
    word2clusterindex = {}
    # ヘッダー部分を省略する
    fline = dataReader.next()
    for line in dataReader:
        # print line
        node,index = line
        # index = str(nindex)+"_"+str(c_index)
        # print "node", node, type(node)
        # node = node.ecode("utf-8")
        clusters[index] = clusters.get(index, []) + [node]
        word2clusterindex[node] = list(set(clusters.get(node, []) + [index]))
    
    nclustrs = {}
    for key,c in clusters.items():
        index = key.split("_")[0]
        nclustrs[index] = nclustrs.get(index,0) + len(c)


    for key,c in sorted(clusters.items() ,key=lambda x:nclustrs.get(x[0].split("_")[0]), reverse=True):
        print "+"*30
        print "-",key
        for node in c:
            print node

    return clusters,nclustrs,word2clusterindex

# コミュニティ抽出したファイルを整形する
def load_community_file(filename="csv/all/Community.txt"):

    dataReader = csv.reader(file(filename),delimiter=' ')
    clusters = {}
    word2clusterindex = {}
    # ヘッダー部分を省略する
    fline = dataReader.next()
    for line in dataReader:
        # print line
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

if __name__ == '__main__':





    csv_filename = 'corpus/collagree_theme_jinken.csv'
    csv_filename = 'corpus/collagree_theme_saigai.csv'
    csv_filename = 'corpus/collagree_theme_miryoku.csv'
    csv_filename = 'corpus/collagree_theme_kankyo.csv'

    dataReader = csv.reader(file(csv_filename))
    fline = dataReader.next()
    body_index = fline.index("body")
    facilitation_index = fline.index("facilitation")
    limit = ["名詞","形容詞","動詞"]

    # 形態素解析した本文
    docs = [extractParts(line[body_index],limit=limit,nolimit=True) for line in dataReader]
    
    # 本文
    dataReader = csv.reader(file(csv_filename))
    fline = dataReader.next()
    docs_line = [line[body_index] for line in dataReader]
    
    # ファシリテーターかのフラグ
    dataReader = csv.reader(file(csv_filename))
    fline = dataReader.next()
    facilitation_line = [line[facilitation_index] for line in dataReader]

    # ユーザー名
    dataReader = csv.reader(file(csv_filename))
    fline = dataReader.next()
    username_index = fline.index("username")
    users_line = [line[username_index] for line in dataReader]
    users_set = set(users_line)

    docs_per_users = dict()
    all_docs_per_users = dict()


    # print parts
    start_flag = False # すでに名詞カウントが始まっているか
    stack = []

    norm_all = []
    # total_doc_lines = []
    # norm_adjective_all = []
    adjective_all = []
    converted_docs = []
    tmp = ""
    # import re
    # import string
    converted_words_dict = {}
    for i,line in enumerate(docs_line):
        # print i
        username = users_line[i]

        if str(facilitation_line[i]) == "true":
            # print "*"
            continue

        line = line.replace("\r\n", "")
        line_show = ""
        for line_one in line.split("。"):
            if line_one is "" :
                continue
            line_show += line_one+"。\n"

        # print str(line)
        # print line_show

        # print "-"*20
        # 連続する名詞を１つの名詞として扱う
        limit = ["名詞","形容詞","動詞"]
        # limit = ["名詞","形容詞"]
        # limit = ["名詞","動詞"]
        # limit = ["名詞"]        
        norm_list,new_doc,conv_dict = extraNormList(docs[i],limit=limit)

        for k,v in conv_dict.items():
            converted_words_dict[k] = v
        # print "docid_:",i
        # print docs[i]
        # for n in new_doc:
            # print n
        # for ii in new_doc:
            # print ii,

        # print ""
        # print "-"*50
        # for ii in norm_list:
        #     norm_all.append(ii)
        #     print ii,
        # 名詞一覧に追加
        norm_all = norm_all + norm_list

        # # 名詞・形容詞一覧
        # norm_adjective_all = norm_adjective_all + norm_adjective_list
        # 形容詞一覧
        adjective_all = adjective_all + [w[0] for w in docs[i] if w[1] == "形容詞"]
        # print ""
        # print "-"*50


        # 各ユーザーについて保存
        if username in docs_per_users:
            docs_per_users[username].append(new_doc)
            # all_docs_per_users[username].append(line_show)
            all_docs_per_users[username].append([i,new_doc])
        else:
            docs_per_users[username] = [new_doc]
            # all_docs_per_users[username] = [line_show]
            all_docs_per_users[username] = [[i,new_doc]]


        # total_doc_lines.append(line_show)

        converted_docs.append(new_doc)

    print len(converted_docs)
    # norm_list_all = [norm_word for norm_word in norm_list for norm_list in norm_all]
    
    # print len(norm_list_all)


    # tfidf_issue = tfidf(doc=norm_all, docs=converted_docs)

    # tfidf_issue.sort(cmp=lambda x,y:cmp(x["tfidf"],y["tfidf"]),reverse=True)
    # # print tfidf_issue
    # result = [e for i,e in enumerate(tfidf_issue) if e["tfidf"] > 0.0 and len(e["word"]) > 1]

    # print "Tf-Idf"
    # for i in result:
    #     print i.get("tfidf"), i.get("word")



    # tfidf_dict = dict()
    converted_docs_flat = reduce(lambda x,y: x+y, converted_docs)
    # for i in tfidf(doc=list(set(converted_docs_flat)), docs=converted_docs):
    #     tfidf_dict[i.get("word")] = i.get("tfidf")

    # ## LDA
    # dictionary = corpora.Dictionary(converted_docs)
    # # print(dictionary.token2id)
    # corpus = [dictionary.doc2bow(text) for text in converted_docs]
    # print len(corpus)
    # lda = models.ldamodel.LdaModel(corpus, num_topics=10, id2word=dictionary,alpha=0.001)
    # topic_index = lda[dictionary.doc2bow(converted_docs[0])]
    # # print dictionary.doc2bow(new_docs[10])
    # lda_result = lda.show_topics(formatted=False,num_topics=-1,num_words=20)
    # # print dictionary.keys()
    # print len(lda_result)
    # for per_topic in lda_result:
    #     for w in per_topic:
    #         print w[1],
    #     print "\n", "-"*50


    # 類似度で単語を名寄せする    
    word_dict_count = doc_to_word_count(converted_docs_flat)
    words_list = list(set(converted_docs_flat))
    replace_dict =  words_to_abstraction(words_list, word_dict_count=word_dict_count, threhold=0.8)
    # 名寄せされた単語で置換する
    converted_replaced_docs = docs_replace_words(docs=converted_docs,replace_dict=replace_dict)
    # converted_replaced_docs = converted_docs


    print "*total network"
    # ネットワーク全体での分析
    # co_occurence_obj = extraCoOccurrence(converted_docs)
    co_occurence_obj_replaced = extraCoOccurrence(converted_replaced_docs)
    # save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename="co_graph_all.csv") # Norm Adjective Verb
    # save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename="co_graph_all_NAV.csv") # Norm Adjective Verb

    # co_occurence_obj_replaced = extraCoOccurrence_bf2af(converted_replaced_docs)

    # G = show_graph(co_occurence_obj_replaced,min_count=1,adjective_all=adjective_all)


    # #テキストに保存する
    # # co_occurence_obj_replaced = extraCoOccurrence_win(converted_replaced_docs,window=1, window_r=1,mode=2)
    # # save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename="co_graph_win1_1.csv")

    # # co_occurence_obj_replaced = extraCoOccurrence_win(converted_replaced_docs,window=1, window_r=0,mode=2)
    # # save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename="co_graph_win1_0.csv")


    # # co_occurence_obj_replaced = extraCoOccurrence(converted_replaced_docs)
    # # save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename="co_graph_all.csv")

    # # co_occurence_obj_replaced = extraCoOccurrence_bf2af(converted_replaced_docs)
    # # save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename="co_graph_bf2af.csv")

    # # co_occurence_obj_replaced = extraCoOccurrence_af2bf(converted_replaced_docs)
    # # save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename="co_graph_af2bf.csv")


    # # クラスタリング
    # unG = G.to_undirected()

    # #ネットワークのグループ化(サブネットワークの検出)
    # all_nodes = unG.nodes()
    # grouped_nodes = set()
    # sub_nx = dict()
    # nw_index = 0
    # for node in all_nodes:

    #     if node in grouped_nodes:
    #         continue
    #         # for c_i in xrange(nw_index):
    #             # if node in sub_nx[c_i]:
    #                 # sub_nx[c_i] = list(set(sub_nx[c_i] + group))

        
    #     neighbors = list(nx.bfs_edges(unG,node))
    #     if len(neighbors) == 0:
    #         continue
    #     group = list(reduce(lambda x,y: list(x)+list(y),neighbors))


    #     sub_nx[nw_index] = list(set(group))
    #     nw_index += 1

    #     # print neighbors
       
    #     # print group
    #     # group = [i for i in set_i for set_i in list(nx.bfs_edges(unG,node))]

    #     # print len(group)
    #     grouped_nodes = set(list(grouped_nodes) + (group))

    # print sub_nx.keys()
    # group_value = [len(sub_nx[key]) for key in sub_nx.keys()]
    # print group_value
    # print [float(i)/sum(group_value) for i in group_value]



    # groups_pair = [(key, len(sub_nx[key])) for key in sub_nx.keys()]

    # for items in sorted(groups_pair , key=lambda x:x[1], reverse=True)[:10]:
    #     nw_index,nx_count = items
    #     print nw_index
    #     # for i in  groups[nw_index]:
    #         # print i



    # print "pagerank"
    # # PageRankの上位から順番に近くのノードをクラスタに追加していく
    # neighbors = []
    # pagerank_sorted = sorted(nx.pagerank(G,alpha=0.9).items(),key=lambda x:x[1], reverse=True)

    # for item in pagerank_sorted:
    #     word,pagerank = item
    #     print "*"*10
    #     print word
    #     print "*"*10
    #     word_neighbors = list(unG.neighbors(word))

    #     neighbors.append(set(word_neighbors))
    #     print "-"*5


    # # 似ている共起をしているノードを中心語を中心としてクラスタリング
    # threhold_sim = 0.75
    # node_rank_range = 50

    # grouped_nodes = set()
    # groups = {}
    # for i in xrange(min(len(pagerank_sorted),node_rank_range)):
    #     print "*"*10
    #     print i, pagerank_sorted[i][0]
    #     print "*"*10

    #     word,pagerank = pagerank_sorted[i]
    #     # 共起の類似度
    #     # similarity_nodes =  sorted([(j,float(len(neighbors[i] & neighbors[j]))/max(len(neighbors[i]),len(neighbors[j]))) for j in xrange(len(neighbors)) if i != j], key=lambda x:x[1], reverse=True)
    #     # similarity_nodes = [(j,sim) for j,sim in similarity_nodes if sim >= threhold_sim]

    #     # for index,set_len in similarity_nodes:
    #     #     word,pagerank = pagerank_sorted[index]
    #     #     print word,"(",set_len,")"

    #     # 論点の周辺単語をグループに追加 すでにグループに追加されている単語は除く
    #     groups[word] = neighbors[i] - grouped_nodes

    #     grouped_nodes = grouped_nodes | neighbors[i]
    #     # print similarity_nodes

    # for i in xrange(min(len(pagerank_sorted),node_rank_range)):
    #     word,pagerank = pagerank_sorted[i]
    #     print "-"*10
    #     print i," ",word
    #     print "-"*10
    #     for n in groups[word]:
    #         print n

    #     # similarity_nodes
    #     # for j in xrange(i+1,len(neighbors)):
    #     #     if i == j:
    #     #         continue
    #     #     i_set = neighbors[i]
    #     #     j_set = neighbors[j]
    #     #     print i_set & j_set

    #     # print i

    # for R 

    # topname = "N"
    topname = "NAV"

    co_occurence_obj_replaced = extraCoOccurrence(converted_replaced_docs)
    allover_csv_filename = "csv/co_graph_all_%s.csv" % topname
    save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename=allover_csv_filename) 

    folder = "csv_user_all_%s" % topname
    # 各ユーザの共起ネットワークをファイルに保存してRで解析する
    for username in users_set:
        # ディレクトリの作成
        directory = "csv/%s/%s" % (folder,username)
        import os
        if not os.path.exists(directory):
            os.makedirs(directory)
        # csv保存
        user_docs_replaced = docs_per_users[username]
        co_occurence_obj_replaced = extraCoOccurrence(user_docs_replaced)
        csv_filename = "csv/%s/co_all_user_%s.csv" % (folder,username)
        save_graph_format(co_occurence_obj=co_occurence_obj_replaced,csv_filename=csv_filename)

    # for R
    import pyper
    r = pyper.R()
    r('library(igraph)')
    # folder = "csv_user_all_NAV"
    cmd = 'x <- read.table("%s", header=T, sep=",")' % allover_csv_filename
    print r(cmd)
    print allover_csv_filename
    r('g <- graph.data.frame(x[,1:2],directed=T)')
    r('E(g)$weight <- x[,3]')
    r('g <- simplify(g,remove.multiple=T,remove.loops=T)')

    r('b <- sort(betweenness(g),decreasing = TRUE)')
    r('close <- sort(close <- closeness(g),decreasing = TRUE)')
    r('vec <- sort(vec <- evcent(g)$vector,decreasing = TRUE)')
    r('pg <- sort(pg <- page.rank(g)$vector,decreasing = TRUE)')

    cmd = 'write.table(b, "csv/all_%s/betweenness.txt",sep=" ")' % (topname)
    r(cmd)
    cmd = 'write.table(close, "csv/all_%s/closeness.txt",sep=" ")' % (topname)
    r(cmd)
    cmd = 'write.table(vec, "csv/all_%s/vec.txt",sep=" ")' % (topname)
    r(cmd)
    cmd = 'write.table(pg, "csv/all_%s/pagerank.txt",sep=" ")' %(topname)
    r(cmd)

    # クラスタリングを実行
    cmd = '''
# 連結成分でネットワーク
dcg <- decompose.graph(g)

# 連結ネットワーク単位にコミュニティーと中心性を計算する
sp.df.all <- c() # コミュニティ分割結果データフレーム
for (i in 1:length(dcg)){
  set.seed(1) # シードを固定
  sp <- spinglass.community(dcg[[i]]) # 焼きなまし法 グラフラプラシアンを使ってQ値が最大となるような分割を探す
  sp.df <- cbind(i, as.data.frame(sp$names), as.data.frame(sp$membership)) # データフレーム形式に変換
  sp.df.all <- rbind(sp.df.all, sp.df) # コミュニティーに結果を追加
}
colnames(sp.df.all) <- c("i", "NodeName", "Community") # 列名変更

library(linkcomm)
# undata <- getLinkCommunities(x[,1:2],plot=FALSE)
data <- getLinkCommunities(x[,1:2],directed=T,dirweight=x[,3],plot=FALSE)
lc <- newLinkCommsAt(data,cutat=0.95)


    '''
    r(cmd)
    cmd = 'write.table(sp.df.all, "csv/all_%s/Community.txt", row.name=F, col.names=T, sep=" ", quote=F, append=F)'%(topname)
    r(cmd)

#     cmd = 'write.table(data$nodeclusters, "csv/all_%s/overlapping.txt", row.name=F, col.names=T, sep=" ", quote=F, append=F)' % (topname)
#     r(cmd)
#     cmd = 'write.table(lc$nodeclusters, "csv/all_%s/overlapping_0.95.txt", row.name=F, col.names=T, sep=" ", quote=F, append=F)' % (topname)
#     r(cmd)
#     for username in users_set:
#         # username = username.encode("utf-8")
#         print username
#         cmd = 'x <- read.table("csv/%s/co_all_user_%s.csv", header=T, sep=",")' % (folder,username)
#         print r(cmd)
#         r('g <- graph.data.frame(x[,1:2],directed=T)')
#         r('E(g)$weight <- x[,3]')
#         r('g <- simplify(g,remove.multiple=T,remove.loops=T)')


#         r('b <- sort(betweenness(g),decreasing = TRUE)')
#         r('close <- sort(close <- closeness(g),decreasing = TRUE)')
#         r('vec <- sort(vec <- evcent(g)$vector,decreasing = TRUE)')
#         r('pg <- sort(pg <- page.rank(g)$vector,decreasing = TRUE)')

#         cmd = 'write.table(b, "csv/%s/%s/betweenness.txt",sep=" ")' % (folder,username)
#         r(cmd)
#         cmd = 'write.table(close, "csv/%s/%s/closeness.txt",sep=" ")' % (folder,username)
#         r(cmd)
#         cmd = 'write.table(vec, "csv/%s/%s/vec.txt",sep=" ")' % (folder,username)
#         r(cmd)
#         cmd = 'write.table(pg, "csv/%s/%s/pagerank.txt",sep=" ")' %(folder,username)
#         r(cmd)




    # clusters,nclustrs = load_community_file(filename="csv/win1_1/Community.txt")
    # clusters,nclustrs,word2clusterindex = load_community_file(filename="csv/all/Community.txt")
    # clusters,nclustrs,word2clusterindex = load_community_file_overlapping(filename="csv/all/un_overlapping.txt")

    clusters,nclustrs,word2clusterindex = load_community_file(filename="csv/all_"+topname+"/Community.txt")
    # clusters,nclustrs,word2clusterindex = load_community_file_overlapping(filename="csv/all_"+topname+"/overlapping.txt")
    # clusters,nclustrs,word2clusterindex = load_community_file_overlapping(filename="csv/all_NAV/overlapping_0.98.txt")

    # clusters,nclustrs,word2clusterindex = load_community_file_overlapping(filename="csv/all_NAV/un_overlapping.txt")


    # Wkipediaとword2vecを利用したクラスタリング

    print "*clustring"
    # 単語のベクトルを読み込む
    # from gensim.models import word2vec
    # model = word2vec.Word2Vec.load("../../wikipedia_corpus/w2v_200.model")
    # vec_size = model.layer1_size
    # word_vec_dict = {}
    # replace_dict_inv = dict([(v,k) for k,v in replace_dict.items()])
    # for d_username, doc_obj in all_docs_per_users.items():
    #     # 文書の重要度
    #     doc_utility = 0.0
    #     for doc_index_i,words in doc_obj:
    #         replaced_words = docs_replace_words(docs=words,replace_dict=replace_dict)
    #         for word in replaced_words:
    #             if word in model.vocab:
    #                 word_key = word
    #             if word.upper() in model.vocab:
    #                 word_key = word.upper()
    #             if replace_dict_inv.get(word) in model.vocab:
    #                 word_key = replace_dict_inv.get(word)
    #             if word_key in model.vocab:
    #                 index = model.vocab.get(word_key).index
    #                 vec = model.syn0[index]
    #                 word_vec_dict[word] = vec
    #             else:
    #                 if word in converted_words_dict:
    #                     for word in converted_words_dict[word]:
    #                         if word in model.vocab:
    #                             index = model.vocab.get(word).index
    #                             vec = model.syn0[index]
    #                             word_vec_dict[word] = word_vec_dict.get(word, np.zeros(vec_size,)) + vec
    #                 else:
    #                     print "no : ",word


    # X = np.array(word_vec_dict.values())
    # word_keys = word_vec_dict.keys()

    # print "len(X) : ", len(X)
    # km = KMeans(n_clusters=50,init='k-means++',n_init=1,verbose=True)
    # # km = XMeans(init='k-means++',n_init=1,verbose=True)

    # km.fit(X)
    # # print "cluster_sizes_:",km.cluster_sizes_

    # labels = km.labels_

    # clusters = {}
    # word2clusterindex = {}
    # for index,class_name in enumerate(labels):
    #     clusters[class_name] = clusters.get(class_name,[]) + [word_keys[index]]
    #     word2clusterindex[word_keys[index].encode("utf-8")] = class_name

    # # クラスタを表示
    # for cluster_name, lists in clusters.items():
    #     print cluster_name
    #     for l in lists:
    #         print l,",",

    #     print ""




    # 単語がどのクラスタに属するか変換
    # word2clusterindex = {}
    # for key,c in clusters.items():
    #     for word in c:
    #         word2clusterindex[word] = key


    print "clusters.items()", len(clusters.items())
    print "word2clusterindex.items()", len(word2clusterindex.items())

    usernames = []
    usernames.append("Newtube758")
    usernames.append("umesiso")
    usernames.append("それいゆ")
    usernames.append("ヨッシー")

    usernames.append("K.Samantha.A")
    usernames.append("かつやん")
    usernames.append("一名古屋人")
    usernames.append("membersonly")

    usernames.append("点線横断")
    usernames.append("qusu")
    usernames.append("Nayabashi5")
    usernames.append("こめっと")

    ''' 
        ユーザーのスコア付けを行う
    '''
    TFIDF_table = TFIDF()
    for words in converted_replaced_docs:
        TFIDF_table.add_doc(words)

    user_utility_dict = {}
    # for username in usernames:
    for username in users_set:
        user_issue_score = {}
        # score_dict = load_node_files(filename="csv/csv_user_all_NAV/"+username+"/pagerank.txt")
        score_dict = load_node_files(filename="csv/csv_user_all_"+topname+"/"+username+"/closeness.txt")        
        # score_dict = load_node_files(filename="csv/csv_user_all/"+username+"/pagerank.txt")        
        # score_dict = load_node_files(filename="csv/csv_user_all/"+username+"/closeness.txt")
        # score_dict = load_node_files(filename="csv/csv_user_all/"+username+"/betweenness.txt")
        # score_dict = load_node_files(filename="csv/csv_user_all/"+username+"/vec.txt")


        # 各ユーザごとにスコアを付与
        for word,score in score_dict.items():
            print word, type(word)
            if word not in word2clusterindex:
                print "skip! no cluster"
                continue
            # TF-IDFを考慮したバージョンTODO

            # over clustring
            if isinstance(word2clusterindex[word], list):
                for cluster_index in word2clusterindex[word]:
                    user_issue_score[cluster_index] = user_issue_score.get(cluster_index,[]) + [score]
            else:
            # hard clustring
                cluster_index = word2clusterindex[word]
                user_issue_score[cluster_index] = user_issue_score.get(cluster_index,[]) + [score]

        # 各ユーザのスコアの方式を変更
        for cluster_index,score_list in user_issue_score.items():
            user_issue_score[cluster_index] = max(score_list) # スコアの最大値
            user_issue_score[cluster_index] = sum(score_list) # スコアの和
            # user_issue_score[cluster_index] = sum(score_list)/len(score_list) # スコアの平均




        issue_score_sum = sum(user_issue_score.values())
        issue_score_max = max(user_issue_score.values())

        # ユーザの論点の重要度をノーマライズする 合計で1.0となるようにする
        for cluster_index in user_issue_score.keys():
            user_issue_score[cluster_index] /= issue_score_sum
            # user_issue_score[key] /= issue_score_max


        print "total_issue",len(clusters.keys())
        print "user_issue",len(user_issue_score.keys())

        # print sorted( user_issue_score.items(), key=lambda x:x[1], reverse=True)


        # 各意見について重要度を求める
        doc_utilities = []
        total_utility = []
        for d_username, doc_obj in all_docs_per_users.items():
            # 文書の重要度
            doc_utility = 0.0
            for doc_index_i,words in doc_obj:



                # TF-IDFを考慮して効用値を計算する
                replaced_words = docs_replace_words(docs=words,replace_dict=replace_dict)
                tfidf_dict = TFIDF_table.get_tfidf_value(replaced_words)
                # tfidf_dict = TFIDF_table.get_bm25_value(replaced_words)


                "\n"
                print "docid:",doc_index_i
                # print words
                if len(tfidf_dict.values()) != 0:
                    min_u = min([u for u in tfidf_dict.values()])
                    max_u = max([u for u in tfidf_dict.values()])



                # scikit-learn
                # tfidf_dict = {}
                # for i in tfidf(doc=replaced_words, docs=converted_replaced_docs):
                    # tfidf_dict[i.get("word")] = i.get("tfidf")

                for w,u in tfidf_dict.items():
                    print w,u
                    # tfidf_dict[w] = u / min_u
                    # tfidf_dict[w] = u / max_u

                




                # print ""
                # print doc_index_i
                # print "".join(words)

                # 名寄せ語の単語で効用値を求める
                for word in replaced_words:
                    w = word.encode("utf-8")

                    cluster_index = word2clusterindex.get(w, None)
                    if cluster_index is None:
                        continue

                    if not isinstance(cluster_index, list):
                        # hard clustring
                        cluster_indexes = [cluster_index]
                    else:
                        # soft clustring
                        cluster_indexes = word2clusterindex[w]
                        
                    for cluster_index in cluster_indexes:
                        # この単語に対する重要度
                        word_utility = user_issue_score.get(cluster_index, 0.0)
                        # word_utility = user_issue_score.get(cluster_index, 0.0) * tfidf_dict[word]

                        # print word_utility

                        # クラスタに属するノードの数で割る？
                        # print len(clusters.get(cluster_index))
                        # print cluster_index,
                        # word_utility /= len(clusters.get(cluster_index))

                        doc_utility += word_utility

                # average?
                doc_utility /= max(len(words), 2.5)  
                # doc_utility /= TFIDF_table.get_doc_average_len()



                doc_info = (doc_index_i,d_username) # 文書の情報
                doc_utilities.append([doc_info, doc_utility]) # 追加
                total_utility.append(doc_utility)
                # print "".join(words),doc_utility


        total_utility_sum  = sum(total_utility)
        total_utility_max  = max(total_utility)

        user_utility_dict[username] = {}
        print "\n【%s】\n" % username
        for doc_info, doc_utility in sorted( doc_utilities, key=lambda x:x[1], reverse=True)[:]:
            doc_index_i,doc_username = doc_info
            print "[",doc_index_i,"]","\t",doc_utility/total_utility_max, "\t",doc_username
            user_utility_dict[username][doc_index_i] = doc_utility/total_utility_max
            # print docs_line[doc_index_i].replace("\r\n","")
             # 全体で効用が1になるように設定

        print "_"*30


    # for pareto front
    # 発言数が多い順にユーザをソート
    sorted_users= sorted([(d_username,len(doc_obj)) for d_username, doc_obj in all_docs_per_users.items()], key=lambda x:x[1], reverse=True)
    sorted_users_list = [users[0] for users in sorted_users]

    user_num = 2 # パレートフロントを探すユーザ数
    for user_num in range(2,len(sorted_users_list)):
        print "-"*20
        doc_indexes = sorted([doc_index_i for d_username, doc_obj in all_docs_per_users.items() for doc_index_i,words in doc_obj])
        
        util_vecs = dict([(doc_index,np.array([user_utility_dict[username][doc_index] for username in sorted_users_list[:user_num]])) for doc_index in doc_indexes])
        # for i,u in util_vecs.items():
        #     print u
        for u in sorted_users_list[:user_num]:
            print u

        pareto_optimum_factor = []
        for doc_index_i in doc_indexes:
            util_vec_i = util_vecs[doc_index_i]
            pareto_optimum = True
            for doc_index_j in doc_indexes:
                util_vec_j = util_vecs[doc_index_j]
                if (util_vec_i < util_vec_j).all():
                    pareto_optimum = False

            if pareto_optimum:
                pareto_optimum_factor.append((doc_index_i,util_vec_i))
            
        parot_indexes =  [doc_index_i for doc_index_i,util_vec_i in pareto_optimum_factor]
        print parot_indexes
        print len(parot_indexes)/ float(len(doc_indexes))

    for doc_index_i,util_vec_i in pareto_optimum_factor:
        print doc_index_i,
        print sum(util_vec_i)/ float(len(util_vec_i))


    print sorted([(doc_index_i,sum(util_vec_i)/ float(len(util_vec_i))) for doc_index_i,util_vec_i in pareto_optimum_factor], key=lambda x:x[1] )
    # print len(doc_indexes)


    # for username in usernames:
    #     print "\n【%s】\n" % username
    #     for key,value in sorted(user_utility_dict[username].items(), key=lambda x:x[0], reverse=False):
    #         print key,"\t",value




    # for excel format
    # for username in usernames:
    #     print "【%s】" % username,
    # print ""
    # for key,value in sorted(user_utility_dict[usernames[0]].items(), key=lambda x:x[0], reverse=False):
    #     print key,"\t",value,
    #     for username in usernames[1:]:
    #         print "\t",user_utility_dict[username][key],
    #     print ""



    # for plot using Python
    # users_set_list = list(users_set)
    # # # save for graph
    # for i in range(len(users_set_list)):
    #     for j in range(i+1,len(users_set_list)):
    #         usera = users_set_list[i].decode("utf-8")
    #         userb = users_set_list[j].decode("utf-8")
    #         # usera = users_set_list[i]
    #         # userb = users_set_list[j]

    #         print usera,userb
    #         x = [v for k,v in sorted(user_utility_dict[users_set_list[i]].items(), key=lambda x:x[0], reverse=False)]
    #         y = [v for k,v in sorted(user_utility_dict[users_set_list[j]].items(), key=lambda x:x[0], reverse=False)]
    #         labels = [k for k,v in sorted(user_utility_dict[users_set_list[j]].items(), key=lambda x:x[0], reverse=False)]
    #         plt.clf()
    #         plt.subplots_adjust(bottom = 0.1)
    #         plt.scatter(
    #             x, y, marker = 'o',cmap = plt.get_cmap('Spectral'),s=100, c="#3cb371")
    #         for label, x, y in zip(labels, x, y):
    #             plt.annotate(
    #                 label, 
    #                 xy = (x, y), xytext = (-20, 20),
    #                 textcoords = 'offset points', ha = 'right', va = 'bottom',
    #                 bbox = dict(boxstyle = 'round,pad=0.1', fc = 'yellow', alpha = 0.5),
    #                 arrowprops = dict(arrowstyle = '->', connectionstyle = 'arc3,rad=0'))
    #         plt.xlabel(usera)
    #         plt.ylabel(userb)
    #         # plt.plot(x, y, 'o',color="#3cb371",markersize=15,linestyle='None')
    #         plt.savefig('csv/all_'+topname+'/Community_close/graph_'+usera+'_'+userb+'.png')
    #         # plt.show()



    # import numpy as np
    # import matplotlib.pyplot as plt
    # N = 10
    # data = np.random.random((N, 4))
    # labels = ['point{0}'.format(i) for i in range(N)]
    # plt.subplots_adjust(bottom = 0.1)
    # plt.scatter(
    #     data[:, 0], data[:, 1], marker = 'o', c = data[:, 2], s = data[:, 3]*1500,
    #     cmap = plt.get_cmap('Spectral'))
    # for label, x, y in zip(labels, data[:, 0], data[:, 1]):
    #     plt.annotate(
    #         label, 
    #         xy = (x, y), xytext = (-20, 20),
    #         textcoords = 'offset points', ha = 'right', va = 'bottom',
    #         bbox = dict(boxstyle = 'round,pad=0.5', fc = 'yellow', alpha = 0.5),
    #         arrowprops = dict(arrowstyle = '->', connectionstyle = 'arc3,rad=0'))

    # plt.show()            
    # # 各ユーザの意見一覧を表示
    # for username, doc_obj in all_docs_per_users.items():
    #     # if username not in usernames:
    #         # continue
    #     print "-"*20
    #     print username
    #     for doc_index_i,words in doc_obj:
    #         print "[",doc_index_i,"]"
    #         print docs_line[doc_index_i]




    # for key in docs_per_users.keys():
    #     user_docs = docs_per_users[key]
    #     print "-"*60
    #     print "username : ",key
    #     for udoc in all_docs_per_users.get(key):
    #         print udoc

    #     print "".join(user_docs[0])

    #     tfidf_dict = dict()
    #     total_doc_lines_flat = reduce(lambda x,y: x+y, user_docs)
    #     for i in tfidf(doc=list(set(total_doc_lines_flat)), docs=converted_docs):
    #         tfidf_dict[i.get("word")] = i.get("tfidf")

    #     # print user_docs
    #     # print user_docs
    #     graph_filename = "g_"+key+".png"
    #     co_occurence_obj = extraCoOccurrence(user_docs)
    #     show_graph(co_occurence_obj=co_occurence_obj, graph_filename=graph_filename,min_count=0)


    # 類似度に基づいて置換された文字
    # for i in replace_dict.keys():
        # print i, "=>",replace_dict[i]
        
    # 共起の辞書を表示する
    # for d,v in extraCoOccurrence(converted_replaced_docs).iteritems():
        # print d,v

    # for i in new_docs[0]:
    #     print i
    # print lda[corpus]
    # word_important = [e["word"] for i,e in enumerate(tfidf_issue) if e["tfidf"] > 0.0 and len(e["word"]) > 1 if i < 30]


    # for i,new_doc in enumerate(new_docs):
    #     for j,w in enumerate(new_doc):
    #         # word = w[0].decode("utf-8")
    #         print w,



