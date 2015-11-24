#!/usr/bin/env python#
# coding: utf-8


class ChunkManager(object):
    """文節管理クラス"""
    __slots__ = ['chunk', 'words', 'original_forms', 'parts', 'chunk_weight', 'link', 'pos']

    def __init__(self, link, pos):
        """初期化メソッド"""
        super(ChunkManager, self).__init__()
        self.chunk = ""
        self.words = []
        self.original_forms = []
        self.parts = []
        self.chunk_weight = 1.0
        self.link = link
        self.pos = pos

    def set_chunk(self, word):
        """chunkに単語を追加"""
        self.chunk += word

    def set_words(self, word):
        """wordsに単語を追加"""
        self.words.append(word)

    def set_noun(self, word):
        """wordsの最後の要素に連結"""
        self.words[len(self.words)-1] += word

    def set_original_forms(self, word):
        """original_formsに原型を追加"""
        self.original_forms.append(word)

    def set_parts(self, part):
        """partsに品詞を追加"""
        self.parts.append(part)

    def set_chunk_weight(self, value):
        """chunk_weightに値をセット"""
        self.chunk_weight = value

    def check_weight(self, bm25):
        """bm25の値を反映する"""
        for bm25_word in bm25:
            if bm25_word[0] in self.words:
                self.chunk_weight *= bm25_word[1]
