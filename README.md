# COLLAGREE

## Description

collagree is a opinion collection app.  

New_Collagree removes dependent of outdated gems in Collagree

## Installation

```
$ bundle install --path vendor/bundle
```

* db作成

```
$ bundle exec db:create
$ bundle exec db:migrate
```

`config/database.yml`の`username`と`password`は自分の設定をする


### Requirement

* ruby-2.1.1
* mysql 5.6.x
* mecab 0.966

## How to Start

```
$ bundle exec spring rails s
```

## LICENCE

好きなライセンスをちゃんいみパイセンが

## 伊美先輩TODO

* カラムの説明
* ネガポジのアルゴリズム
* テーブルの構造
