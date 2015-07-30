require 'mysql'
require 'natto'

connection = Mysql::new("127.0.0.1", "root", "01xcdusd", "collagree_autofacilitation201503")
# connection を使い MySQL を操作する

# 投稿内容を引っ張ってくる
# ファシリテーターの発言を除きたいときは「 and not user_id = 1」をつけよう
entry_sql = connection.prepare("select id, body, created_at from entries where theme_id = 1;")
entry_res = entry_sql.execute

keyword_sum = 0
entry_count = 0

count15 = 0
array15 = Array.new(24, 0)

count16 = 0
array16 = Array.new(24, 0)

count17 = 0
array17 = Array.new(24, 0)

entry_res.each do |entry|
	str = entry[2].to_s
	date = str[8...10]
	time = str[11...13]
	if date == "16"
		count15 += 1
		array15[time.to_i] += 1
	elsif date == "17"
		count16 += 1
		array16[time.to_i] += 1
	elsif date == "18"
		count17 += 1
		array17[time.to_i] += 1
	end
	puts time
end

puts array15

puts "1日目の投稿数：#{count15}"
for i in 0..23
	print "#{i}時〜#{i+1}時："
	j = array15[i]
	while j > 0
		print "■"
		j -= 1
	end
	print "\n"
end

puts "2日目の投稿数：#{count16}"
for i in 0..23
	print "#{i}時〜#{i+1}時："
	j = array16[i]
	while j > 0
		print "■"
		j -= 1
	end
	print "\n"
end

puts "3日目の投稿数：#{count17}"
for i in 0..23
	print "#{i}時〜#{i+1}時："
	j = array17[i]
	while j > 0
		print "■"
		j -= 1
	end
	print "\n"
end

connection.close