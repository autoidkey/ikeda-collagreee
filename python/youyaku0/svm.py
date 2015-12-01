#!/usr/bin/python
# -*- coding:utf-8 -*-

import re
import numpy as np
from sklearn import svm, grid_search

class SVM:
    def __init__(self, train_vecs, test_vecs, train_labels):
        self.train_vecs = train_vecs
        self.test_vecs = test_vecs
        self.train_labels = train_labels

    def concat_length(self, vecs, lengths):
        vecs = np.c_[vecs, lengths]
        return vecs

    def classifier(self, train_lengths, test_lengths):
        # ベクトルに文字列長を付与
        self.train_vecs = self.concat_length(self.train_vecs, train_lengths)
        self.test_vecs = self.concat_length(self.test_vecs, test_lengths)

        # グリッドサーチを実行
        # tuned_parameters = {'kernel':['rbf'], 'C':np.logspace(-4, 4, 10), 'gamma':np.logspace(-4, 4, 10)}
        # clf = grid_search.GridSearchCV(svm.SVC(), tuned_parameters, n_jobs=-1) # Support Vector Classification(分類)，RBFカーネルを使用
        clf = svm.SVC(kernel='rbf', gamma=10.0, C=1.0)

        # 学習および予測
        clf.fit(self.train_vecs, self.train_labels)
        test_labels = clf.predict(self.test_vecs)
        # print clf.best_estimator_

        return test_labels
