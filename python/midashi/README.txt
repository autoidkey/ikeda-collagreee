見出し生成プログラム
====

入力された発言に対して見出しを生成します．
ファイル位置に依存する部分をほぼ無くしたので，このフォルダごと置くならどこに置いても動作すると思います．
まだ評価を反映した内容ではないので，今後変更する可能性が高いです（特にagree, disagree）．

## 環境
インストール必須（こちらの環境で動作確認済み）
Python 2.7
MeCab 0.996
CaboCha 0.69

## 使い方
コマンドライン
1. コマンドラインからcomment_manager.pyを実行
2. 指示に従い「返信先のコメント」「見出し生成したいコメント」の順に入力
3. 見出しを生成した結果が出力される

プログラムをいじる場合
・comment_manager.pyの最下部にコマンドラインからの入力で動作させる部分のプログラムがあるので，それを見ながら変更してください．
・このプログラムではBM25の計算ができないため，サンプルとしてInputDataからbm25_jinken.csvを読み込んでいます．
・システムに組み込んで必要なデータ（返信先のコメント，見出し生成したいコメント，BM25の値）が与えられれば，InputDataは不要です．
・「返信先のコメント」「見出し生成したいコメント」はstr型，BM25はリスト型[“単語”, 値]です．

## 構成
midashiフォルダ内
comment_manager.py
入力されたコメントを分解．各文をsentence_manager.pyに投げる．
入出力はここで行う．
sentence_manager.py
受け取った１文を保持．文節に分け，chunk_manager.pyに投げる．
chunk_manager.py
受け取った文節を保持．タグや値を入れているところ．

toolsフォルダ内
cosine.py
コサイン類似度計算用
negaposi.py
ネガティブワード・ポジティブワード判定用
nega_posi_eq_meishi.csv
nega_posi_yogen.txt
ネガポジ判定の際に使用する感情極性辞書