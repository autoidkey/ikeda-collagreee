class AnalysisController < ApplicationController
	include Bm25
	require 'csv'

	def index
	  	serch_theme_id = 1
	  	file_name = "entry_top3_"
	  	times = [5] ##配列で管理
	  	serch_user_id = User.pluck(:id) ##データを取る参加者
	  	remove_user = [1,251,252,253,254,255,256,257,258,259,260,214,271,265]
	  	active_user = [178, 146, 221, 58, 96, 41, 262, 210, 40, 97, 261, 263, 264, 74, 44, 266, 158, 267, 268, 269, 224, 50, 270, 273, 272, 125]
	  	# serch_user_id = [20,5,3,48,1]
	  	# serch_user_id = [92,19,17,15,58]
	  	# start_time = Time.local(2015, 12, 15, 0, 0, 0)
	  	# end_time = Time .local(2016, 1, 6, 0, 0, 0)
	  	start_time =  Time.local(2016, 7, 12, 14, 48, 53)
	  	end_time = Time.local(2016, 7, 12, 16, 23, 53)

	  	# object = Entry.all
	  	# object = Entry.where.not(user_id: remove_user)
	  	# object = Webview.where.not(user_id: remove_user)
	  	# object = Treedata.all
	  	# object = TreeLog.all

	  	serch_user = active_user

	  	# もじおこしのデータをxlsから読み込む
	  	##############################
	 #  	array_text = []
	 #  	book = Spreadsheet.open("log/csv2/kumamoto2.xls")    
	 #  	sheet = book.worksheet('Sheet1')                                                                        
		# sheet.each do |row|                                                                                          
		# 	row.each do |r|
		# 		array_text.push(r)
		# 	end
		# end

		# file_name = "log/csv2/"+"keywords_kumamoto"+".csv"
		# File.open(file_name, 'w') {|file|
		# 	calculate3(array_text).each do |key, val|
		# 		write = key.to_s+","+val[:score].to_s+"\n"
		# 		file.write write
		# 	end
		# }

		#######################################

		#######################################
		# COLLAGREEの全体のキーワード
		# @theme = Theme.find(serch_theme_id) 
		# @keyword = @theme.keywords.select { |k| k.user_id.nil? }.sort_by { |k| -k.score }.group_by(&:score)
		# p @keyword
		# file_name = "log/csv2/"+"keyword_collagree"+".csv"
		# File.open(file_name, 'w') {|file|
		# 	@keyword.each_with_index do |(key, val), idx|
		# 		val.each do |wordlist|
		# 			write = key.to_s+","+wordlist[:word]+"\n"
		# 			file.write write
		# 		end
		# 	end
		# }

		#######################################

	  	# 時間ごとのキーワード
		##############################
	 #  	times.each do |time|

	 #  		file_name = "keywords_"
		#   	object = Entry.where(user_id: serch_user)
		#   	interval = 60*time

		#   	# 時間ごとの投稿の推移
	 #  		date_array = []
	 #  		@data_all = []
	 #  		start = start_time
		#   	while ((end_time - start) > 0)
		#   		entries = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1))
		#   		keyword_array = []
		#   		calculate(entries).each do |key, val|
		# 	        params = {
		# 	          word: key,
		# 	          score: val[:score]
		# 	        }
		# 	        keyword_array.push(params)
		# 	    end
		# 	    logger.info({keywords: keyword_array})
		#   		date_array.push({start.to_s(:time) => keyword_array})
		#   		# start = start.tomorrow １日毎に集計
		#   		start = start + interval
		#   	end
		#   	@data_all.push(date_array)

		# 	logger.info({data: @data_all})

		# 	file_name = "log/csv2/"+file_name+time.to_s+".csv"
		# 	File.open(file_name, 'w') {|file|
		# 	@data_all.each do |data|

		# 	  		data.each do |d|
		# 			  	key = d.keys[0]
		# 			  	array = d[key]
		# 			    write = key.to_s+"\n"
		# 			    array.each do |a|
		# 			    	write = write+a[:word].to_s+","+a[:score].to_s+"\n"
		# 				end
		# 			    file.write write
		# 			end
		# 	 end
		# 	}

		# end

		##############################


	  	# なんでも使える
	  	##############################
	 #  	times.each do |time|

	 #  		file_name = "webview_sum_"
		#   	object = Webview.where(user_id: serch_user)
		#   	interval = 60*time

		#   	# 時間ごとの投稿の推移
	 #  		date_array = []
	 #  		@data_all = []
	 #  		start = start_time
		#   	while ((end_time - start) > 0)
		#   		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1)).count
		#   		date_array.push({start.to_s(:time) => t})
		#   		# start = start.tomorrow １日毎に集計
		#   		start = start + interval
		#   		logger.info({time: start.to_s})
		#   	end
		#   	@data_all.push(date_array)

		# 	logger.info({data: @data_all})


		# 	#からむの作成

		# 	file_name = "log/csv2/"+file_name+time.to_s+".csv"
		# 	File.open(file_name, 'w') {|file|
		# 	@data_all.each do |data|

		# 		sum = 0
		# 	  		data.each do |d|
		# 			  	key = d.keys[0]
		# 			  	# logger.warn key
		# 			  	# logger.warn d[key]
		# 			  	sum = sum + d[key]
		# 			    write = key.to_s+","+d[key].to_s + "\n"
		# 			    file.write write
		# 			end
		# 		file.write "sum,"+sum.to_s+"\n"+"\n"
		# 	 end
		# 	}

		# end


		##############################

		# 投稿の文字の長さのsum
		##############################
	 #  	times.each do |time|

	 #  		file_name = "entry_length_sum_"
		#   	object = Entry.where(user_id: serch_user)
		#   	interval = 60*time

		#   		  	# 時間ごとの投稿の推移
	 #  		date_array = []
	 #  		@data_all = []
	 #  		start = start_time
		#   	while ((end_time - start) > 0)
		#   		length_count = 0
		#   		entries = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1))
		#   		entries.each do |entry|
		#   			length_count = length_count + entry.body.length
		#   		end
		#   		date_array.push({start.to_s(:time) => length_count})
		#   		# start = start.tomorrow １日毎に集計
		#   		start = start + interval
		#   		logger.info({time: start.to_s})
		#   	end
		#   	@data_all.push(date_array)

		# 	logger.info({data: @data_all})

		# 	file_name = "log/csv2/"+file_name+time.to_s+".csv"
		# 	File.open(file_name, 'w') {|file|
		# 	@data_all.each do |data|

		# 		sum = 0
		# 	  		data.each do |d|
		# 			  	key = d.keys[0]
		# 			  	# logger.warn key
		# 			  	# logger.warn d[key]
		# 			  	sum = sum + d[key]
		# 			    write = key.to_s+","+d[key].to_s + "\n"
		# 			    file.write write
		# 			end
		# 		file.write "sum,"+sum.to_s+"\n"+"\n"
		# 	 end
		# 	}

		# end

		##############################


		# スレッドの出来上がり数
		##############################
	 #  	times.each do |time|

	 #  		file_name = "thread_open_sum_"
		#   	object = Entry.where(user_id: serch_user)
		#   	interval = 60*time

		#   		  	# 時間ごとの投稿の推移
	 #  		date_array = []
	 #  		@data_all = []
	 #  		start = start_time
		#   	while ((end_time - start) > 0)
		#   		t = object.where(theme_id: serch_theme_id ,parent_id: nil ,created_at: start .. (start + interval - 1)).count
		#   		date_array.push({start.to_s(:time) => t})
		#   		# start = start.tomorrow １日毎に集計
		#   		start = start + interval
		#   		logger.info({time: start.to_s})
		#   	end
		#   	@data_all.push(date_array)

		# 	logger.info({data: @data_all})

		# 	file_name = "log/csv2/"+file_name+time.to_s+".csv"
		# 	File.open(file_name, 'w') {|file|
		# 	@data_all.each do |data|

		# 		sum = 0
		# 	  		data.each do |d|
		# 			  	key = d.keys[0]
		# 			  	sum = sum + d[key]
		# 			    write = key.to_s+","+d[key].to_s + "\n"
		# 			    file.write write
		# 			end
		# 		file.write "sum,"+sum.to_s+"\n"+"\n"
		# 	 end
		# 	}

		# end

		##############################


  # 		date_array = []
  # 		@data_all = []
  # 		start = start_time
	 #  	while ((end_time - start) > 0)
	 #  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval)).count
	 #  		date_array.push({start.to_s => t})
	 #  		# start = start.tomorrow １日毎に集計
	 #  		start = start + interval
	 #  	end
	 #  	@data_all.push(date_array)

		# logger.info({data: @data_all})


		# #からむの作成

		# file_name = "log/csv/"+file_name
		# File.open(file_name, 'w') {|file|
		# @data_all.each do |data|

		# 	sum = 0
		#   		data.each do |d|
		# 		  	key = d.keys[0]
		# 		  	logger.warn key
		# 		  	logger.warn d[key]
		# 		  	sum = sum + d[key]
		# 		    write = key.to_s+","+d[key].to_s + "\n"
		# 		    file.write write
		# 		end
		# 	file.write "sum,"+sum.to_s+"\n"+"\n"
		#  end
		# }


	 #  	file_name = "log/csv/"+file_name
		# File.open(file_name, 'w') {|file|
		# 	active_user.each do |data|
		# 	    write = Entry.where(user_id: data).count.to_s+"\n"
		# 	    file.write write
		# 	end
		# }


		##########################
		#スレッドのタイトル
		# times.each do |time|
		# 	entry = Entry.where(parent_id: nil).pluck(:id)
		# 	interval = 60*time
		# 	logger.info({entry_id: entry})


		# 	# スレッドを一気に読み込む
		# 	hash = Hash.new { |h, k| h[k] = [] }

		# 	entry.each do |e|
		# 		file_name = "thread_times_"+time.to_s+"_entry"+e.to_s+".csv"
		# 		c = childlen_serching(e)
		# 		object = Entry.where(id: c)
		# 		logger.info({object: object})
		# 		logger.info({entry_child: c})

		#   		date_array = []
		#   		@data_all = []
		#   		start = start_time
		# 	  	while ((end_time - start) > 0)
		# 	  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval)).count
		# 	  		date_array.push({start.to_s => t})
		# 	  		# start = start.tomorrow １日毎に集計
		# 	  		start = start + interval
		# 	  	end
		# 	  	@data_all.push(date_array)

		# 		logger.info({data: @data_all})


		# 		#からむの作成
		

		# 		file_name = "log/csv2/"+file_name
		# 		File.open(file_name, 'w') {|file|
		# 		@data_all.each do |data|
		# 			array = []
		# 			file.write e.to_s+"\n"
		# 		  		data.each.each_with_index do |d, i|
		# 				  	key = d.keys[0]
		# 				  	logger.warn key
		# 				  	logger.warn d[key]
		# 				    write = key.to_s+","+d[key].to_s + "\n"
		# 				    file.write write
		# 				    hash[key.to_s].push(d[key])
		# 				end
		# 		 end
		# 		}

		# 	end

		# 	logger.info({test: hash})
		# 	file_name = "log/csv2/"+"thread_all_"+time.to_s+".csv"

		# 	File.open(file_name, 'w') {|file|
		# 		write = ","
		# 		Entry.where(parent_id: nil).pluck(:id).each do |e|
		# 			write = write+e.to_s+","
		# 		end
		# 		write = write+"\n"
		# 		file.write write

		# 		hash.each{|key, value|
		# 			write = key.to_s+","
		# 			value.each do |v|
		# 				write = write+v.to_s+","
		# 			end
		# 			write = write+"\n"
		# 			file.write write
		# 		}
		# 	}
		# end

		################################


		# entry.each do |e|
		# 	file_name = "thread_times_1_"+e.to_s+".csv"
		# 	c = childlen_serching(e)
		# 	object = Entry.where(id: c)
		# 	logger.info({object: object})
		# 	logger.info({entry_child: c})

	 #  		date_array = []
	 #  		@data_all = []
	 #  		start = start_time
		#   	while ((end_time - start) > 0)
		#   		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval)).count
		#   		date_array.push({start.to_s => t})
		#   		# start = start.tomorrow １日毎に集計
		#   		start = start + interval
		#   	end
		#   	@data_all.push(date_array)

		# 	logger.info({data: @data_all})


		# 	#からむの作成

		# 	file_name = "log/csv/"+file_name
		# 	File.open(file_name, 'w') {|file|
		# 	@data_all.each do |data|
		# 		array = []
		# 		sum = 0
		# 		file.write e.to_s+"\n"
		# 	  		data.each.each_with_index do |d, i|
		# 			  	key = d.keys[0]
		# 			  	logger.warn key
		# 			  	logger.warn d[key]
		# 			  	sum = sum + d[key]
		# 			    write = key.to_s+","+d[key].to_s + "\n"
		# 			    file.write write
		# 			end
		# 		file.write "sum,"+sum.to_s+"\n"+"\n"
		# 	 end
		# 	}


		# end



	  	# アクティブなユーザの分析
	 #  	active_user = []
  # 		start = start_time
	 #  	while ((end_time - start) > 0)
	 #  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval))
	 #  		t.each do |i|
	 #  			if !active_user.include?(i.user_id) && !remove_user.include?(i.user_id)
	 #  				active_user.push(i.user_id)
	 #  			end
	 #  		end
	 #  		# start = start.tomorrow １日毎に集計
	 #  		start = start + interval
	 #  	end
		# logger.info({usre: active_user})
		# logger.info({usre: active_user.count})




	  	#　投稿の長さ
	 # 	 entry_all = Entry.order(id: :asc).where(theme_id: serch_theme_id)
	 #  	file_name = "log/csv/"+file_name
		# File.open(file_name, 'w') {|file|
		# 	write = "id,length,body\n"
		# 	file.write write
		# 	entry_all.each do |data|
		#   	 	write = data.created_at.to_s+","+data.body.length.to_s + "\n"
		#    		file.write write
		# 	end
		# }
		

	  	
		

		# puts('書き込み完了')

	 #  	@data_all = []
	  	
	 #  	# ユーザで日にちごと
	 #  	serch_user_id.each do |user|
	 #  		date_array = []
	 #  		start = start_time
		#   	while ((end_time - start) > 0)
		#   		t = object.where(theme_id: serch_theme_id , user_id: user,created_at: start .. (start + interval)).count
		#   		date_array.push({start.to_s => t})
		#   		# start = start.tomorrow １日毎に集計
		#   		start = start + interval
		#   	end
		#   	@data_all.push(date_array)
		#  end

		#  logger.info({data: @data_all})


		# #からむの作成
		# colum = ["date"]
		# serch_user_id.each do |u|
		# 	colum.push(u)
		# end

		# file_name = "log/csv/test_view2"+".csv"
		# File.open(file_name, 'w') {|file|
		# count = 0
		# @data_all.each do |data|

		# 	sum = 0
		#   		data.each do |d|
		# 		  	key = d.keys[0]
		# 		  	logger.warn key
		# 		  	logger.warn d[key]
		# 		  	sum = sum + d[key]
		# 		    write = key.to_s+","+d[key].to_s + "," + serch_user_id[count].to_s+ "\n"
		# 		    file.write write
		# 		end
		# 	file.write "sum,"+sum.to_s+"\n"+"\n"
		# 	count = count + 1
		#  end
		# }
		

		# puts('書き込み完了')
	end

	def childlen_serching(id)
		childlen = []
		serchlist = []
		serchlist.push(id)
		entry = Entry.all

		while(serchlist.count != 0)
			serchid = serchlist.shift
			entry.each do |e|
				if e.parent_id == serchid
					childlen.push(e.id)
					serchlist.push(e.id)
				end
			end
		end
		return childlen

	end
end
