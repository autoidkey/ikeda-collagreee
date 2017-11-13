# COLLAGREE

## Description
test by ikeda

collagree is a opinion collection app.  

New_Collagree removes dependent of outdated gems in Collagree

## Installation

```
$ bundle install --path vendor/bundle
```

* db作成

```
$ bundle exec rake db:create
$ bundle exec rake db:migrate
```

`config/database.yml`の`username`と`password`は自分の設定をする


### Requirement

* ruby-2.1.1
* mysql 5.6.x
* mecab 0.966
* ImageMagick 6.8.9-x

## How to Start

```
$ bundle exec spring rails s
```

## LICENCE

好きなライセンスをちゃんいみパイセンが

## 伊美先輩TODO
- tesut

* カラムの説明
    * Entry: 投稿，モデル内がツリー構造になっているが実際親子構造しか使っていない
        * title - 投稿につけるタイトル
        * body - 本文
        * parent_id - 親コメントID
	    * np - ネガポジ判定値（0-100）
	    * sort_time - TL順序を決める時間
	    * facilitation - ファシリテーション投稿かどうか
	    * invisible - 非表示フラグ
	    * top_fix - 固定投稿フラグ
	    * issue_names - 論点名の配列（いらない）
	    * root_node - ルート投稿かどうか（rubyでやるならいらない）
	    * user_image, username, user_info（rubyでやるならいらない）
	    * passion - 情熱、いらない
        * image - CarriarWaveでの画像アップロード
    * Theme: テーマ
  	    * title - テーマタイトル
  	    * body - テーマ説明
  	    * color - テーマの表示色
  	    * secret - 管理者用フラグ
  	    * faci - ファシリテータ・管理者用フラグ
  	    * nolink - リンクなしフラグ
  	    * image - CarriarWaveによるテーマ画像
    * Issue: 論点タグ、モデル内がツリー構造になっている
  	    * name - 論点名
    * User: ユーザ情報
  	    * role - 権限
  	    * name - 名前
  	    * realname - 本名
  	    * email - メールアドレス（devise）
  	    * encrypted_password - パスワード（devise）
  	    * gender - 性別（男、女）
  	    * age - 年齢（10代未満、20代、30代、40代、50代、60代、70代以上）
  	    * home - お住まい
  	    * move - 通勤について
  	    * remind - リマインダーメールの有無
  	    * mail_format - メールのフォーマット（htmlかtextか）
  	    * image - ユーザアイコン
  	    * 他、deviseによる追加
    * Keyword: キーワード
  	    * np - キーワードとスコアなど、{キーワード => {tfidfスコア、賛成数、反対数}}
	    * word - キーワードとスコアの配列、いらないこ
  	    * exclude - いらないこ
    * Exclusion: 除外キーワード
  	    * word: 除外ワード
    * Email: メール
  	    * email - メールアドレス
  	    * subject - 件名
  	    * big - 表題
  	    * title - 本文タイトル
 	    * body - メール本文
    * Contact: お問い合わせ
  	    * name - ユーザ名
  	    * email - メールアドレス
  	    * title - タイトル
  	    * body - 問い合わせ本文
    * Activity: 行動履歴
  	    * info - 行動履歴、{id: "", contents: "行動履歴"}
  	    * atype - 履歴の種類（投稿、返信、関連返信など）
  	    * read - 既読フラグ
    * Ability: cancanによる権限管理
    * Join: いらない子
    * Comment: いらない子
    * Facilitation_keywords: ファシリテーターが手動で管理できるキーワード
* ネガポジのアルゴリズム
* テーブルの構造
