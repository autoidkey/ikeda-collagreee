#!/usr/bin/python
# -*- coding:utf-8 -*-

# reference URL: https://gist.github.com/shimizukawa/5931218

import re
import MeCab

class determineDescriptor(object):
    def __init__(self, *allowed_features):
        self.allowed_features = allowed_features

    def __get__(self, instance, klass):
        return any(map(instance.feature.startswith, self.allowed_features))

class Word(object):
    def __init__(self, surface, feature):
        """単語の見出しと特徴を保持"""
        self.surface = surface
        self.feature = feature

    def __repr__(self):
        """オブジェクトに固有の文字列表現を与える"""
        return u'<{0.__class__.__name__} "{0.surface}", "{0.feature}">'.format(self).encode('utf-8')

    @property
    def is_connected(self):
        allowed_feature = (
            u"名詞,一般",
            u"名詞,数",
            u"名詞,サ変接続",
            u"名詞,接尾,一般",
            u"名詞,接尾,サ変接続",
            u"名詞,固有名詞",
            u"名詞,形容動詞語幹",
            u"名詞,副詞可能",
            u"記号,アルファベット",
        )

        # 後述の記号列を重複することなくリストを作成
        disallowed_symbols = set(map(lambda x: x, u"()[]<>|\"';,"))

        return (self.feature.startswith(allowed_feature) and self.surface not in disallowed_symbols)

    is_adjective = determineDescriptor(
        u"名詞,形容動詞語幹",
        u"名詞,ナイ形容詞語幹"
    )

    is_prefix = determineDescriptor(
        u"接頭詞,名詞接続"
    )

    is_postfix = determineDescriptor(
        u"名詞,接尾,形容動詞語幹",
        u"名詞,接尾,一般",
        u"名詞,接尾,地域",
        u"名詞,接尾,サ変接続"
    )

    is_digit_prefix = determineDescriptor(
        u"接頭詞,数接続"
    )

    is_numerative = determineDescriptor(
        u"名詞,接尾,助数詞"
    )

    is_digit = determineDescriptor(
        u"名詞,数"
    )

    is_noun = determineDescriptor(
        u"名詞"
    )

    is_verb = determineDescriptor(
        u"動詞"
    )

    @property
    def is_digit_only(self):
        return self.surface.isdigit()

    # 不要な記号を定義して削除
    _is_symbol_only = re.compile(r'[!"#\$\%\&\'\(\)\*\+,\-\./:;\<\=\>\?\@\[\\\]\^\_\`\{\}\~\|]+').search

    @property
    def is_symbol_only(self):
        return self._is_symbol_only(self.surface)

    def combine(self, other):
        if self.is_prefix and other.is_noun:
            # 接頭辞は次の名詞に繋ぐ（ex. 元都知事）
            self.surface += other.surface
            self.is_prefix = False
            self.is_noun = True
            # print self.surface

        elif self.is_noun and other.is_postfix:
            # 接尾辞は一個前が名詞だったら繋ぐ（ex. 巨大化）
            self.surface += other.surface
            self.is_noun = False
            self.is_postfix = True
            # print self.surface


        elif self.is_digit_prefix and other.is_digit:
            # 数接続の接頭詞の次に数字だったら繋ぐ（ex. 毎秒20）
            self.surface += other.surface
            self.is_digit_prefix = False
            self.is_digit = True
            # print self.surface

        elif self.is_digit and other.is_numerative:
            # 数字の次に助数詞がきたら繋げる（ex. 30個）
            self.surface += other.surface
            self.is_digit = False
            self.is_numerative = True
            # print self.surface

        elif self.is_noun and other.is_noun:
            # 名詞の次に名詞がきたら繋げる（ex. 志段味）
            self.surface += other.surface
            self.is_noun = True
            # print self.surface

        else:
            if (other.is_connected or other.is_adjective or other.is_postfix or other.is_prefix or other.is_digit_prefix or other.is_noun or other.is_verb):
                other.is_noun = other.is_connected
                return "start" # selfを確定
            else:
                other.is_noun = other.is_connected
                return "end"

        return "mid" # selfは未確定

def mecab_parse_iterator(tagger, text):
    """tagger(MeCab.Tagger instance), text(unicode) => word(unicode), feature(unicode)"""
    # text = text.encode('utf-8')
    node = tagger.parseToNode(text)

    while node:
        yield Word(node.surface.decode('utf-8'), node.feature.decode('utf-8'))
        node = node.next

def extract_word(text):
    # text = text.decode('utf-8')
    pword = Word('', '')
    result = []
    wakati = []

    for word in mecab_parse_iterator(MeCab.Tagger(), text):
        state = pword.combine(word)
        if state == "start":
            result.append(word)
            pword = word
        elif state == "mid":
            pass
        elif state == "end":
            pword = word

    for word in result:
        if not (word.is_digit_only or word.is_symbol_only): # False
            wakati.append(word.surface)

    return wakati

def separate_text(text):
    # text = text.decode('utf-8')
    text = re.sub(re.compile("\s"), "", text) # ホワイトスペース除去
    text = re.sub(re.compile("(https|http|ftp)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)"), "", text) # URL除去
    text = re.sub(re.compile("\(.+?\)|（.+?）"), "", text) # 括弧書き除去

    separated_texts = re.split("。|．|\?|？|", text) # 文分割
    while separated_texts.count("") > 0:
        separated_texts.remove("")

    return separated_texts
