#!/usr/bin/python
# -*- coding: utf-8 -*-

import mecab
import doc2vec
import numpy as np
import sys
from prettyprint import pp
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import Normalizer
from sklearn.decomposition import TruncatedSVD
from collections import OrderedDict

class LexRank:
    def __init__(self, sentences, vectors, cosine_threshold):
        self.sentences = sentences
        self.vectors = vectors
        self.cosine_threshold = cosine_threshold

    def lexrank(self):
        size = len(self.sentences)
        cosine_matrix = np.zeros([size, size])
        degree = np.zeros(size)
        # vectors = self.sentence_to_tfidf()
        # vectors = self.sentence_to_doc2vec()
        # print self.vectors
        # print "ranking %d sentences" % (size)

        # build cosine matrix
        for i in range(0, size):
            for j in range(0, size):
                cosine_matrix[i][j] = self.idf_modified_cosine(self.vectors[i], self.vectors[j])
                # print "%d:%d\t%lf" % (i, j, cosine_matrix[i][j])
                if cosine_matrix[i][j] > self.cosine_threshold:
                    cosine_matrix[i][j] = 1.0
                    degree[i] += 1.0
                else:
                    cosine_matrix[i][j] = 0.0

        for i in range(0, size):
            for j in range(0, size):
                cosine_matrix[i][j] = cosine_matrix[i][j] / degree[i]

        # print cosine_matrix

        # return result of applying power method to cosine matrix
        rank = self.power_method(cosine_matrix, size, epsilon=0.0)
        return rank

    def cont_lexrank(self, infos):
        size = len(self.sentences)
        cosine_matrix = np.zeros([size, size])
        row_sums = np.zeros(size)
        # vectors = self.sentence_to_tfidf()
        # vectors = self.sentence_to_doc2vec()
        # print self.vectors
        # print "ranking %d sentences" % (size)

        # build cosine matrix
        for i in range(0, size):
            for j in range(0, size):
                cosine_matrix[i][j] = (1.0 + self.idf_modified_cosine(self.vectors[i], self.vectors[j])) * self.rel(infos[i], infos[j])
                row_sums[i] += cosine_matrix[i][j]

        for i in range(0, size):
            for j in range(0, size):
                cosine_matrix[i][j] = cosine_matrix[i][j] / row_sums[i]

        # print cosine_matrix

        # return result of applying power method to cosine matrix
        rank = self.power_method(cosine_matrix, size, epsilon=1e-6)
        return rank

    def rel(self, info1, info2):
        if info1['id'] == info2['id']:
            return 2.0
        elif info1['parent_id'] == info2['id'] or info2['parent_id'] == info1['id']:
            return 1.5
        else:
            return 1.0

    def power_method(self, matrix, size, epsilon):
        # initialize eigenvector by dviding 1 by matrix size
        matrix = self.transform_matrix(matrix, size)
        eigenvector = np.ones(size) / size
        delta = sys.maxint
        t = 0

        while delta > epsilon:
            t += 1
            new_eigenvector = np.dot(matrix.T, eigenvector)
            delta = np.linalg.norm(new_eigenvector - eigenvector)
            eigenvector = new_eigenvector
            # print "iter:%s\t(delta:%f > epsilon:%f)" % (t, delta, epsilon)

        return eigenvector

    def transform_matrix(self, matrix, size):
        """transform cosine matrix to suitable matrix with damping factor for computing power method"""
        damping = 0.85
        U = np.ones([size, size]) / size
        matrix = (1.0 - damping) * U + damping * matrix
        return matrix

    def idf_modified_cosine(self, vector1, vector2):
        # numerator = sum([v1 * v2 for v1, v2 in zip(vector1, vector2)])
        # denominator = (sum(map(lambda x: x * x, vector1)) ** 0.5) * (sum(map(lambda y: y * y, vector2)) ** 0.5)
        # return numerator / denominator if denominator != 0.0 else 0.0
        return np.dot(vector1, vector2) / (np.linalg.norm(vector1) * np.linalg.norm(vector2))

    def sentence_to_tfidf(self):
        wakatis = []
        for sentence in self.sentences:
            sentence = sentence.encode('utf-8')
            wakati = mecab.extract_word(sentence)
            wakatis.append(" ".join([w for w in wakati]))

        vectorizer = TfidfVectorizer(use_idf=True)
        vectors = vectorizer.fit_transform(wakatis)
        if vectors.shape[0] > 10:
            vectors = self.compress_vector(vectors, dim=10)
        return vectors

    def sentence_to_doc2vec(self):
        words = []
        for sentence in self.sentences:
            sentence = sentence.encode('utf-8')
            words.append(mecab.extract_word(sentence))

        pp(words)

        d2v = doc2vec.Doc2Vec(words, size=10)
        vectors = d2v.vectorizer()
        # vectors = self.compress_vector(vectors, dim=10)
        return vectors

    def compress_vector(self, vectors, dim):
        lsa = TruncatedSVD(dim)
        compressed_vectors = lsa.fit_transform(vectors)
        compressed_vectors = Normalizer(copy=False).fit_transform(compressed_vectors)
        return compressed_vectors

def best_print(sentences, rank):
    dic = dict(zip(sentences, rank))
    # for key, value in sorted(dic.items(), key=lambda x: x[1], reverse=True):
        # print "%lf: %s" % (value, key)

if __name__ == "__main__":
    sentences = [
        "自転車が利用できるスロープ、道路の平坦さは、足の不自由なお年寄りが歩く上でも有意義です",
        "そこを利用する乗りのマナーも重要ですが、バリアフリーな道と道は有意義だと",
        "快適で自然が両立するためには、近場ではスローな移動が重要になると",
        "僕の父でもそうですが、移動でもクルマを使っている状況は",
        "またいえることなのですが歩いていて楽しい場所が少ない",
        "車から利用に一気に切り替えるのではなく、自転車やモビリティーを活用するべきだと",
        "エリアは機関が少ないですから"
    ]

    sentences = [
        "名古屋を取り巻く線に自転車道路を整備して、市民の状態の移動した方が快適なづくりを行うべきだと",
        "またサイクリングロードを作ることに隣接している体との交流が加速すると"
    ]

    lr = LexRank(sentences, cosine_threshold=0.1)
    rank = lr.cont_lexrank()
    # print "rank:", rank
    best_print(sentences, rank)
