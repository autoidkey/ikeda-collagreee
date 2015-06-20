require 'mysql'
require 'natto'

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

connection = Mysql::new("127.0.0.1", "root", "パスワードを入れてね", "incentive_experimentation")
# connection を使い MySQL を操作する

# 投稿内容を引っ張ってくる
# ファシリテーターの発言を除きたいときは「 and not user_id = 1」をつけよう
entry_sql = connection.prepare("select id, body from entries where theme_id = 3;")
entry_res = entry_sql.execute

keyword_sum = 0
entry_count = 0
entry_res.each do |entry|
	puts entry[0]
	puts entry[1]
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
		keyword_sql = connection.prepare("select word from keywords where theme_id = 3 and user_id is NULL;")
		keyword_res = keyword_sql.execute
		
		keyword_res.each do |keyword|
			# print keyword[0]
			if keyword[0].include?(entry_word)
				# puts "「#{entry_word}」が「#{keyword[0]}」と#{entry_word.length} / #{keyword[0].length}一致"
				if entry_word.length == keyword[0].length		# ここの条件で一致度を変える
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
puts "キーワード / エントリー = #{keyword_ave}"

connection.close