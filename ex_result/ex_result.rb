require 'mysql'
require 'natto'

NpNode = Regexp.new('^名詞|^動詞|^形容詞|^副詞').freeze
Exculution = Regexp.new('[!-\/:-@\[-`{-~]').freeze
Norm = Regexp.new('^名詞').freeze

K = 2.0
B = 0.75

def calculate(entries)
  freq = {} # 単語出現回数
  df = {} # 単語出現文書数
  bm25 = {} # BM25値
  agree = {}
  disagree = {}

  all_words = %w()
  sum_words = 0.0
  n = entries.count.to_f # 全ドキュメント数

  entries.each do |text|
    norms = norm_connection(text.body) # 連結単語取り出し
    sum_words += all_word_count(text.body) # 全単語数
    # is_agree ||= text.np < 50 ? false : true

    freq_calc(norms, freq, text, agree, disagree)
    df_calc(norms, df, all_words)
  end

  avg_word_count = sum_words / n

  all_words.uniq.each do |node|
    bm25[node] = {
      score: idf(df[node], n) * (freq[node] * K + 1) / (freq[node] + K * (1 - B + B * (sum_words / avg_word_count))),
      agree: agree[node],
      disagree: disagree[node]
    }
  end
  bm25
end

def freq_calc(norms, freq, text, agree, disagree)
  norms.each do |node|
    freq[node] ||= 0
    freq[node] += 1
    agree[node] ||= 0
    disagree[node] ||= 0
   unless text.is_root?
      if text.np >= 50
        agree[node] += 1
      else
        disagree[node] += 1
      end
    end
  end
end

def df_calc(norms, idf, all_words)
  norms.uniq.each do |node|
    idf[node] ||= 0
    idf[node] += 1
    all_words << node
  end
end

def idf(df, n)
  Math::log10((n - df + 0.5) / df + 0.5)
end

def all_word_count(text)
  parse_to_list(text).count
end

# npに必要なノード
def np_nodes(text)
  parse_to_list(text).select { |e| NpNode.match(e.feature) }.map(&:surface)
end

# 名詞のみ
def norm_nodes(text)
  parse_to_list(text).select { |e| Norm.match(e.feature) }.map(&:surface)
end

def two_norms_nodes(text)
  last = nil
  ret = []

  parse_to_list(text).each do |e|
    if last.present? && Norm.match(e.feature) && Norm.match(last.feature)
      ret << last.surface + e.surface if last.present?
    end
    last = e
  end
  ret
end

def norm_connection(text)
  count = 0
  norms = parse_to_list(text)
  ret = []

  norms.each_with_index do |e, idx|
    # その単語が名詞なら次の単語を見る
    if Norm.match(e.feature)
      count += 1
    # 名詞以外が出てきたら、それまでの名詞を全部結合して登録する
    else
      ret << norms[idx - count..idx -1].map(&:surface).join('') if count > 1
      count = 0
    end
  end
  ret
end

# だいたい上のやつと一緒だけど、こっちは複合単語じゃない単語についても抽出している
def norm_connection2(text)
  count = 0
  norms = parse_to_list(text)
  ret = []

  norms.each_with_index do |e, idx|
    # その単語が名詞なら次の単語を見る
    if Norm.match(e.feature)
      count += 1
    # 名詞以外が出てきたら、それまでの名詞を全部結合して登録する
    else
      ret << norms[idx - count..idx -1].map(&:surface).join('') if count > 0
      count = 0
    end
  end
  ret
end

# 名詞だけ取り出す
def parse_noun(word)  
  # print "version: ", MeCab::VERSION, "\n"     # debug  

  nm = Natto::MeCab.new
  ret = []
  nm.parse(word) do |e|
    if e.feature.include?("名詞")
    	ret << e.surface
    end
  end
  
  return ret  
end  

def parse_to_list(text)
  nm = Natto::MeCab.new
  ret = []
  nm.parse(text) do |e|
    ret << e if e.surface.present?
  end
  ret
end


connection = Mysql::new("127.0.0.1", "root", "01xcdusd", "incentive_experimentation")
# connection を使い MySQL を操作する

# 投稿内容を引っ張ってくる
# ファシリテーターの発言を除きたいときは「 and not user_id = 1」をつけよう
entry_sql = connection.prepare("select id, body from entries where theme_id = 5;")
entry_res = entry_sql.execute

entries = []

keyword_sum = 0
entry_count = 0
entry_res.each do |entry|
	puts entry[0]
	puts entry[1]
	entries.push(entry[1])
	puts "---------------------------------------------------"
	puts "名詞だけ取り出すと"
	entry_words = parse_noun(entry[1]).uniq
	print entry_words
	puts "\n---------------------------------------------------"

	# キーワードとの一致判定
	count = 0
	entry_words.each do |entry_word|
	# print entry_word
	# puts "について"
		# キーワードを引っ張ってくる	
		keyword_sql = connection.prepare("select word from keywords where theme_id = 5 and user_id is NULL order by score DESC limit 0, 20;")
		keyword_res = keyword_sql.execute
		
		keyword_res.each do |keyword|
			# puts keyword[0]
			if keyword[0].include?(entry_word)
				# puts "「#{entry_word}」が「#{keyword[0]}」と#{entry_word.length} / #{keyword[0].length}一致"
				if entry_word.length * 2 >= keyword[0].length		# ここの条件で一致度を変える
					count += 1
					puts "「#{entry_word}」が「#{keyword[0]}」と#{entry_word.length} / #{keyword[0].length}で半分以上一致"
				end
			end
		end
	end
	puts "このエントリーの含有キーワード:#{count}個"
	keyword_sum += count
	entry_count += 1
	puts "\n==================================================="
end

puts "キーワードは合計で#{keyword_sum}回使われていました"
puts "エントリーの個数は#{entry_count}個でした"
keyword_ave = keyword_sum / entry_count
puts "1エントリーあたりのキーワード含有個数 = #{keyword_ave}"

connection.close