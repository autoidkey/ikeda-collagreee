#!/usr/bin/python
# -*- coding: utf-8 -*-

import preprocess
import anaphora
import mecab
import doc2vec
import clusters
import svm
import compress
import lexrank

import re
import sys
import copy
import numpy as np
import matplotlib.pyplot as plt
from os import path
from scipy.cluster.hierarchy import dendrogram, linkage
from prettyprint import pp

if __name__ == "__main__":
    """1. 前処理"""
    #これでrubyからの引数をとる
    argvs = sys.argv
    input_path = path.abspath('./../../python/youyaku1/input_data') + '/' + sys.argv[1]
    output_path = path.abspath('./../../python/youyaku1/output_data') + '/' + sys.argv[1]
    svm_path = path.abspath('./../../python/youyaku1/input_data') + '/svmdata_200.csv'
    # input_path = path.abspath('python/youyaku1/input_data') + '/' + sys.argv[1]
    # output_path = path.abspath('python/youyaku1/output_data') + '/' + sys.argv[1]
    # svm_path = path.abspath('python/youyaku1/input_data') + '/svmdata_200.csv'
    # input_path = path.abspath('input_data') + '/' + sys.argv[1]
    # output_path = path.abspath('output_data') + '/' + sys.argv[1]
    # svm_path = path.abspath('input_data') + '/svmdata_200.csv'

    # 要約率の設定
    # youyaku_ritsu = float(sys.argv[2])
    youyaku_ritsu = float(0.25)

    # COLLAGREE過去データをスレッドごとに集計（threads: 辞書）
    # threads = preprocess.remake_file(input_path, output_path)

    # COLLAGREE過去データを読み込む（thread: リスト）
    thread = preprocess.read_thread(input_path)
    theme_id =  thread[0]["theme_id"]

    # SVM正解データを読み込む（svmdata: 辞書）
    svmdata = preprocess.read_svmfile(svm_path)

    # SVM正解データに含まれる文の単語（名詞，動詞）リストなどを作成
    words_svmdata = []
    train_lengths = []
    train_labels = []

    for body, is_need in svmdata.items():
        words = mecab.extract_word(body)

        # 単語数が1未満なら無視
        if len(words) < 1:
            # print body
            continue

        words_svmdata.append(words)
        train_lengths.append([len(body)])
        train_labels.append(is_need)

    # 1つのスレッドの全文字数
    all_length = 0
    for post in thread:
        all_length += len(post['body'].decode('utf-8'))

    # # スレッド主の発言は重要であるため別処理
    # parent = thread.pop(0)

    """2. ベクトル化"""
    # 1つのスレッドに含まれるすべての意見と文の単語リスト
    words_opinion = []
    words_sentence = []

    # 1つのスレッドに含まれるすべての文の文字列長
    test_lengths = []

    # 1つのスレッドに含まれる意見および文の単語リストを作成
    for post in thread:
        # 投稿時刻を扱いやすい形式に変換
        post['created_at'] = preprocess.fit_time(post['created_at'])
        words_opinion.append(mecab.extract_word(post['body']))
        sents = mecab.separate_text(post['body'])

        # 意見単位で指示詞補完＆意見を保持
        sents = anaphora.anaphora_analysis(sents)
        post['sents'] = sents

        for sent in sents:
            sent = sent.encode('utf-8')
            words_sentence.append(mecab.extract_word(sent))
            test_lengths.append([len(sent)])

    # 確認のため単語リストを出力
    # pp(words_opinion)
    # pp(words_sentence)
    # pp(words_svmdata)

    # print "vectorizing opinion"
    d2v_opinion = doc2vec.Doc2Vec(words_opinion, size=200)
    vecs_opinion = d2v_opinion.vectorizer()

    # print "vectorizing sentence"
    d2v_sentence = doc2vec.Doc2Vec(words_sentence, size=200)
    vecs_sentence = d2v_sentence.vectorizer()

    # print "vectorizing svm data and sentence"
    d2v_concat = doc2vec.Doc2Vec(words_svmdata+words_sentence, size=200)
    vecs_concat = d2v_concat.vectorizer()

    """3. クラスタリング"""
    # スレッド主の発言は重要であるため別処理
    parent = thread.pop(0)
    parent_vecs = vecs_sentence[0: len(parent['sents'])]
    del vecs_sentence[0: len(parent['sents'])]
    del vecs_opinion[0]
    del vecs_concat[len(words_svmdata): len(words_svmdata) + len(parent['sents'])]
    del test_lengths[0: len(parent['sents'])]

    vecs_opinion = np.array(vecs_opinion)
    vecs_sentence = np.array(vecs_sentence)
    vecs_concat = np.array(vecs_concat)

    if len(thread) > 2:
        p = clusters.Distance(method='urt').calculate_distance(vecs_opinion, infos=thread)
        Z = linkage(p, method="average")
        # print "selecting label"
        clust_labels = clusters.Label(Z).get_labels(vecs_opinion.shape[0])
        # print "clusters label:", clust_labels
        # dendrogram(Z)
        # plt.show()
    else:
        clust_labels = [1] * len(thread)

    # 重要文抽出で必要になる各クラスタの総文字数
    sub_lengths = {0: len(parent['body'].decode('utf-8'))}
    for index, post in enumerate(thread):
        post['cluster'] = clust_labels[index]
        try:
            sub_lengths[clust_labels[index]] += len(post['body'].decode('utf-8'))
        except:
            sub_lengths[clust_labels[index]] = len(post['body'].decode('utf-8'))

    """4. 不要発言除去"""
    train_vecs = vecs_concat[0: len(words_svmdata)]
    test_vecs = vecs_concat[len(words_svmdata):]
    test_labels = svm.SVM(train_vecs, test_vecs, train_labels).classifier(train_lengths, test_lengths)
    # print "clussified label:", test_labels

    # 不要発言ラベルを各投稿に付与
    position = 0
    for index, post in enumerate(thread):
        post['is_need'] = map(int, test_labels[position: position + len(post['sents'])])
        position += len(post['sents'])

    """5. 文短縮"""
    for post in thread:
        post['sents'] = compress.compress_sentence(post['sents'])

    """6. 重要文抽出"""
    youyaku_length = 0
    youyakus = []
    clusts = {}

    # LexRankで用いる文の情報を取得
    for post in thread:
        if post['cluster'] not in clusts.keys():
            clusts[post['cluster']] = []

        tmp = {'id': post['id'], 'user_id': post['user_id'], 'parent_id': post['parent_id'], 'created_at': post['created_at']}

        for index, sent in enumerate(post['sents']):
            if post['is_need'][index] == 1:
                info = copy.deepcopy(tmp)
                info['sent'] = sent
                info['rank'] = 0.0
                info['vec'] = vecs_sentence[index]
                clusts[post['cluster']].append(info)
            else:
                # print "not need:", sent
                pass

    # スレッド主の発言を1つのクラスタとみなす
    sents = mecab.separate_text(parent['body'])
    sents = anaphora.anaphora_analysis(sents) # 照応解析
    sents = compress.compress_sentence(sents) # 文短縮

    # スレッド主の発言の情報を取得
    clusts[0] = []
    for index, sent in enumerate(sents):
        info = {'id': parent['id'], 'sent': sent, 'user_id': parent['user_id'], 'parent_id': parent['parent_id'], 'created_at': parent['created_at'], 'rank': 0.0, 'vec': parent_vecs[index]}
        clusts[0].append(info)

    # クラスタごとに要約文を生成
    for clust in clusts.keys():
        youyaku = []

        # 1つのクラスタに含まれるすべての文
        sentences = [info['sent'] for info in clusts[clust]]
        vectors = [info['vec'] for info in clusts[clust]]

        # 要素数が1以下のクラスタはLexRankを用いない
        if len(clusts[clust]) > 1:
            lr = lexrank.LexRank(sentences, vectors, cosine_threshold=0.1)
            rank = lr.cont_lexrank(clusts[clust])
            lexrank.best_print(sentences, rank)

            # 文の情報にランクを付与
            for index, info in enumerate(clusts[clust]):
                info['rank'] = rank[index]

        # クラスタ内で要約率を満たすまで重要文を選択
        length = 0
        for info in sorted(clusts[clust], key=lambda x: x['rank'], reverse=True): # ランクが高い順に並び替え
            # 要約文が制約文字数を超えたとき
            if sub_lengths[clust] * youyaku_ritsu <= length:
                break

            # 中身が空っぽのとき
            if len(info['sent']) == 0:
                continue

            youyaku.append(info)
            length += len(info['sent'])
            youyaku_length += len(info['sent'])

        youyakus.extend(youyaku)

    # 時系列が若い順に要約文を出力
    preprocess.write_thread(output_path, sorted(youyakus, key=lambda x: x['created_at']))
    for youyaku in sorted(youyakus, key=lambda x: x['created_at']):
        print "%s,%s,%s,%s" % (youyaku['id'], parent['id'], theme_id, youyaku['sent'])
