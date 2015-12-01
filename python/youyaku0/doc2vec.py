#!/usr/bin/python
# coding: utf-8

from gensim.models import doc2vec
import numpy as np

class LabeledListSentence(object):
    def __init__(self, text_words):
        self.text_words = text_words

    def __iter__(self):
        for uid, line_words in enumerate(self.text_words):
            yield doc2vec.LabeledSentence(line_words, tags=['SENT_%s' % uid])

class Doc2Vec:
    def __init__(self, text_words, size):
        """
        text_words like:
        text_words = [
            ['human', 'interface', 'computer'],
            ['survey', 'user', 'computer', 'system', 'response', 'datetime'],
            ['eps', 'user', 'interface', 'system']
        ]
        """

        self.text_words = text_words
        self.size = size

    def build_model(self):
        all_sents = LabeledListSentence(self.text_words)

        model = doc2vec.Doc2Vec(size=self.size, window=5, min_count=0, alpha=0.025, min_alpha=0.025)
        model.build_vocab(all_sents)

        for epoch in range(20):
            model.train(all_sents)
            model.alpha -= 0.001 # decrease the learning rate
            model.min_alpha = model.alpha # fix the learning rate, no decay

        return model

    def vectorizer(self):
        """convert sentence to vector using doc2vec"""
        model = self.build_model()
        vectors = []

        try:
            vectors = np.array([model.docvecs["SENT_%s" % uid] for uid in range(len(self.text_words))])
        except:
            print "cannot find SENT_%s" % uid
            pass

        return vectors
