#!/usr/bin/python
# coding: utf-8

import datetime
import numpy as np
import scipy.spatial.distance as dist
from math import sqrt

class Label:
    def __init__(self, Z):
        self.Z = Z

    def midiate_threshold(self):
        threshold = 0.0
        prev_value = new_value = 0.0
        max_interval = 0.0

        for z in self.Z:
            new_value = z[2]
            if (new_value - prev_value) > max_interval:
                max_interval = new_value - prev_value
                # threshold = new_value
                threshold = (prev_value + new_value) / 2.0
            prev_value = new_value

        # print "threshold: ", threshold
        return threshold

    def upper_tail(self, k=1.0):
        alphas = [float(z[2]) for z in self.Z]
        alphas = np.array(alphas)

        mean = np.average(alphas)
        var = np.var(alphas)
        unbiased_dev = sqrt((len(alphas) / (len(alphas) - 1)) * var)
        # print "(mean, usd) = (%lf, %lf)" % (mean, unbiased_dev)

        for index, alpha in enumerate(reversed(alphas)):
            if alpha <= mean + k * unbiased_dev:
                # print "threshold:", alpha
                # print "clusters:", index + 1
                return alpha

        return alpha[0]

    def get_labels(self, size):
        # threshold = self.midiate_threshold()
        threshold = self.upper_tail()
        new_label = size
        labels = [i for i in range(size)]

        for z in self.Z:
            c1, c2, value = z[:3]
            if value > threshold:
                break
            for i, label in enumerate(labels):
                if label == c1:
                    labels[i] = new_label
                elif label == c2:
                    labels[i] = new_label
            new_label += 1

        return labels

def cosine(vec1, vec2):
    return 1.0 + np.dot(vec1, vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2))

def pearson(vec1, vec2):
    # 単純な合計
    sum1 = sum(vec1)
    sum2 = sum(vec2)

    # 平方の合計
    sum1Sq = sum([pow(v, 2) for v in vec1])
    sum2Sq = sum([pow(v, 2) for v in vec2])

    # 積の合計
    pSum = sum([vec1[i] * vec2[i] for i in range(len(vec1))])

    # ピアソンによるスコアを算出
    num = pSum - (sum1 * sum2 / len(vec1))
    den = sqrt((sum1Sq - pow(sum1, 2) / len(vec1)) * (sum2Sq - pow(sum2, 2) / len(vec2)))

    if den == 0:
        return 0
    else:
        return num / den # [0 ,1]

class Distance():
    def __init__(self, distance=cosine, method=''):
        self.distance = distance
        self.method = method
        # print "calculating distance"

    def calculate_distance(self, X, infos):
        size = X.shape[0]
        dMatrix = np.zeros([size, size])

        for i in range(size):
            for j in range(size):
                if self.method == '':
                    dMatrix[i, j] = self.distance(X[i], X[j])
                elif self.method == 'u':
                    dMatrix[i, j] = self.distance(X[i], X[j]) + self.weight_user(infos[i], infos[j])
                elif self.method == 'r':
                    dMatrix[i, j] = self.distance(X[i], X[j]) + self.weight_reply(infos[i], infos[j])
                elif self.method == 't':
                    dMatrix[i, j] = self.distance(X[i], X[j]) * self.weight_time(infos[i], infos[j])
                elif self.method in ['ut', 'tu']:
                    dMatrix[i, j] = (self.distance(X[i], X[j]) + self.weight_user(infos[i], infos[j])) * self.weight_time(infos[i], infos[j])
                elif self.method in ['rt', 'tr']:
                    dMatrix[i, j] = (self.distance(X[i], X[j]) + self.weight_reply(infos[i], infos[j])) * self.weight_time(infos[i], infos[j])
                elif self.method in ['ur', 'ru']:
                    dMatrix[i, j] = self.distance(X[i], X[j]) + self.weight_reply(infos[i], infos[j]) + self.weight_user(infos[i], infos[j])
                elif self.method in ['urt', 'utr', 'rut', 'rtu', 'tur', 'tru']:
                    dMatrix[i, j] = (self.distance(X[i], X[j]) + self.weight_reply(infos[i], infos[j]) + self.weight_user(infos[i], infos[j])) * self.weight_time(infos[i], infos[j])
                else:
                    print "cannot find method"

        dMatrix = 1.0 - (dMatrix - np.amin(dMatrix)) / (np.amax(dMatrix) - np.amin(dMatrix))
        for i in range(size):
            for j in range(size):
                if i == j:
                    dMatrix[i, j] = 0.0
        # print dMatrix

        return dist.squareform(dMatrix)

    def weight_time(self, info1, info2):
        alpha = 0.01
        delta = abs(info1['created_at'] - info2['created_at']).seconds / (60.0 * 60.0)

        return np.exp(-alpha * (delta * delta)) # [0, 1]

    def weight_user(self, info1, info2):
        if info1['user_id'] == info2['user_id']:
            return 0.1
        else:
            return 0.0

    def weight_reply(self, info1, info2):
        if info1['parent_id'] == info2['id'] or info2['parent_id'] == info1['id']:
            return 0.1
        else:
            return 0.0
