class AnalysisController < ApplicationController
	include Bm25
	require 'csv'
	require 'spreadsheet'

	def facilitator
		# book = Spreadsheet::Workbook.new
		# sheet = book.create_worksheet
		# # いろいろな方法でデータを入れられる
		# # 計算式は入力できない
		# sheet.row(0).concat %w{day hour value}


		# colが建て、rowがよこ
		# [たて,よこ]
		@hashmap = {"row" => User.maximum(:row), "col" => User.maximum(:col), "noroom" => [[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[1,8],[1,9],[2,2],[2,3],[2,4],[2,5],[2,6],[2,7],[2,8],[2,9],[3,2],[3,3],[3,4],[3,5],[3,6],[3,7],[3,8],[3,9],[4,2],[4,3],[4,4],[4,5],[4,6],[4,7],[4,8],[4,9]]}
		@row = []
		@col = []
		for c in 1..@hashmap["col"]
			@col.push(c)
		end
		for r in 1..@hashmap["row"]
			@row.push(r)
		end
		CSV.open("public/log/entries.tsv", "w", :col_sep => "\t") do |io|
		  io.puts(["day","hour","value","username"]) # 見出し
		  for c in 1..@hashmap["col"]
		  	for r in 1..@hashmap["row"]
		  		if User.exists?(:col => c, :row => r)
		  			user = User.where(:col => c, :row => r)[0]
		  			ran = user.entries.count

		  			io.puts([c, r, ran, user.name])
		  		end
		  	end
		  end
		end

	end

	def graph
		@array = []
		object = Entry.sort_time.all.in_theme(2).root
		object.each do |entry|
			@child_entries = []
			child_entry_array3(entry)
			@child_entries.each do |e|
				@array.push([entry.title, e.created_at, e.created_at + 5.minute])
			end
		end

		@array2 = []
		a = TaggedEntry.all
		a.each do |t|
			@array2.push([t.issue.name, t.entry.created_at, t.entry.created_at + 1.minute])
		end

	end

	def index

		# fix_time
	  	serch_theme_id = 1
	  	times = [60*24] ##配列で管理 10~13 分で記入
	  	serch_user_id = User.pluck(:id) ##データを取る参加者
	  	# remove_user = [1,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,34,35,36,37,38,39,40,41,42,43,44,100,84,31,32,10,11,12,13,99]
	  	# remove_user = [1,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,34,35,36,37,38,39,40,41,42,43,44]
	  	remove_user = [1,2]
	  	# serch_user_id = [20,5,3,48,1]
	  	# serch_user_id = [92,19,17,15,58]
	  	# start_time = Time.local(2015, 12, 15, 0, 0, 0)
	  	# end_time = Time .local(2016, 1, 6, 0, 0, 0)
	  	start_time =  Time.local(2016, 12, 12, 0, 0, 0)
	  	end_time = Time.local(2017, 1, 10, 0, 0, 0)

	  	# object = Entry.all
	  	# object = Entry.where.not(user_id: remove_user)
	  	# object = Webview.where.not(user_id: remove_user)
	  	# object = Treedata.all
	  	# object = TreeLog.all
	  	objects = {"like_sum"=>Like.all, "entry_sum"=>Entry.all, "view_sum"=>Webview.all, }

	  	serch_user = User.where.not(id: remove_user).pluck(:id)

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

		# 各スレッドの移り変わりグラフ化よう
		###########################
	  	times.each do |time|

	  		file_name = "entry_change_g"
		  	object = Entry.sort_time.all.in_theme(serch_theme_id).root
		  	interval = 60*time
		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time

			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"

			File.open(file_name, 'w') {|file|
				file.write ","
				while ((end_time - start) > 0)
					file.write start.to_s + ","
			  		# start = start.tomorrow １日毎に集計
			  		start = start + interval
			  	end
			  	file.write "\n"

				object.each do |entry|
					# 最初の行はカウントを行う
					file.write entry.id.to_s + ","

					start = start_time
					@child_entries = []
					@child_entries = child_entry_array2(entry)
					while ((end_time - start) > 0)
						count = 0

						@child_entries.each do |e|
							if e.created_at > start && e.created_at < (start + interval)
								count = count + 1
							end
						end

				  		start = start + interval

				  		file.write count.to_s + ","
				  	end

				  	file.write "\n"

			 	end
			}

		end
		#############################

		# 各スレッドの移り変わり
		###########################
	  	times.each do |time|

	  		file_name = "entry_change_del"
		  	object = Entry.sort_time.all.in_theme(serch_theme_id).root
		  	interval = 60*time
		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time

			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"

			File.open(file_name, 'w') {|file|
				file.write ","
				while ((end_time - start) > 0)
					file.write start.to_s + ","
			  		# start = start.tomorrow １日毎に集計
			  		start = start + interval
			  	end
			  	file.write "\n"

				object.each do |entry|
					# 最初の行はカウントを行う
					file.write entry.id.to_s + ","

					start = start_time
					@child_entries = []
					@child_entries = child_entry_array2(entry)
					while ((end_time - start) > 0)
						body = ""

						@child_entries.each do |e|
							if e.created_at > start && e.created_at < (start + interval)
								body = body + e.id.to_s + "，"
							end
						end

				  		start = start + interval

				  		file.write body + ","
				  	end

				  	file.write "\n"


				  	# 次は内容を記載する
				  	file.write entry.title.to_s + ","

					start = start_time
					@child_entries = []
					@child_entries = child_entry_array2(entry)
					while ((end_time - start) > 0)
						body = ""

						@child_entries.each do |e|
							if e.created_at > start && e.created_at < (start + interval)
								body = body + e.body.gsub(/(\r\n|\r|\n|\f)/,"") + "||"
							end
						end

				  		start = start + interval

				  		file.write body + ","
				  	end

				  	file.write "\n"



			 	end
			}

		end
		#############################

		# 各投稿を実際に表示されているように並び替える
		##############################

		file_name = "entry_sort"
		entries = Entry.sort_time.all.in_theme(serch_theme_id).root
		@array = []
		entries.each do |entry|
			child_entry_array(entry)
		end
		p @array

		file_name = "log/csv2/"+file_name+".csv"

		File.open(file_name, 'w') {|file|
			file.write "id,title,body,created_at,\n"

			@array.each do |data|
				file.write data[0].to_s+","+data[1].to_s+","+data[2].to_s+","+data[3].to_s+",\n"
			end
		}



	  	#いいねの時間ごと
	  	###########################
	  	times.each do |time|

	  		file_name = "like_sum"
		  	object = Like.where(user_id: serch_user)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1)).count
		  		date_array.push({start.to_s => t})
		  		# start = start.tomorrow １日毎に集計
		  		start = start + interval
		  		logger.info({time: start.to_s})
		  	end
		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				sum = 0
			  		data.each do |d|
					  	key = d.keys[0]
					  	# logger.warn key
					  	# logger.warn d[key]
					  	sum = sum + d[key]
					    write = key.to_s+","+d[key].to_s + "\n"
					    file.write write
					end
				file.write "sum,"+sum.to_s+"\n"+"\n"
			 end
			}

		end
		#############################

		#投稿の時間ごと
	  	###########################
	  	times.each do |time|

	  		file_name = "entry_sum"
		  	object = Entry.where(user_id: serch_user)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1)).count
		  		date_array.push({start.to_s => t})
		  		# start = start.tomorrow １日毎に集計
		  		start = start + interval
		  		logger.info({time: start.to_s})
		  	end
		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				sum = 0
			  		data.each do |d|
					  	key = d.keys[0]
					  	# logger.warn key
					  	# logger.warn d[key]
					  	sum = sum + d[key]
					    write = key.to_s+","+d[key].to_s + "\n"
					    file.write write
					end
				file.write "sum,"+sum.to_s+"\n"+"\n"
			 end
			}

		end
		#############################

		#論点タグの時間ごと
	  	###########################
	  	times.each do |time|

	  		file_name = "issue"
		  	object = TaggedEntry.all
		  	colum = Issue.pluck(:id)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		array = []
		  		colum.each do |col|
			  		t = object.where(issue_id: col,created_at: start .. (start + interval - 1)).count
			  		array.push(t)
			  	end
			  	date_array.push({start.to_s => array})
		  		# start = start.tomorrow １日毎に集計
		  		start = start + interval
		  	end
		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				write = ","
				colum.each do |issue|
					write = write + Issue.find(issue).name.encode!("Shift_JIS") + ","
				end
				file.write write + "\n"

				p data
		  		data.each do |d|
				  	key = d.keys[0]
				  	# logger.warn key
				  	# logger.warn d[key]
				    write = key.to_s+","
				    sum = 0
				    d[key].each do |t|
				    	write = write + t.to_s + ","
				    	sum = sum + t
				    end
				    file.write write + sum.to_s + "\n"
				end

				write = ","
				sum = 0
				colum.each do |issue|
					write = write + TaggedEntry.where(issue_id: issue).count.to_s + ","
					sum = sum + TaggedEntry.where(issue_id: issue).count
				end
				file.write write + sum.to_s + "\n"
				
			 end
			}

		end
		#############################


		#それぞれのユーザ論点タグ
	  	###########################
	  	times.each do |time|

	  		file_name = "person_issue"
		  	object = TaggedEntry.all
		  	interval = 60*time
		  	colum = Issue.pluck(:id)
		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time

		  	serch_user.each do |user|

		  		array = []

		  		colum.each do |col|
		  			sum = 0
		  			object.where(issue_id: col).each do |issue|
		  				if issue.entry.user_id == user
		  					sum = sum + 1
		  				end
			  		end
			  		array.push(sum)
		  		end
		  		date_array.push({user.to_s => array})

		  	end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				write = ","
				colum.each do |issue|
					write = write + Issue.find(issue).name + ","
				end
				file.write write + "\n"

				p data
		  		data.each do |d|
				  	key = d.keys[0]
				  	# logger.warn key
				  	# logger.warn d[key]
				    write = key.to_s+","
				    sum = 0
				    d[key].each do |t|
				    	write = write + t.to_s + ","
				    	sum = sum + t
				    end
				    file.write write + sum.to_s + "\n"
				end


				
			 end
			}

		end
		#############################



		#閲覧数の時間ごと
	  	###########################
	  	times.each do |time|

	  		file_name = "view_sum"
		  	object = Webview.where(user_id: serch_user)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1)).count
		  		date_array.push({start.to_s => t})
		  		# start = start.tomorrow １日毎に集計
		  		start = start + interval
		  		logger.info({time: start.to_s})
		  	end
		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				sum = 0
			  		data.each do |d|
					  	key = d.keys[0]
					  	# logger.warn key
					  	# logger.warn d[key]
					  	sum = sum + d[key]
					    write = key.to_s+","+d[key].to_s + "\n"
					    file.write write
					end
				file.write "sum,"+sum.to_s+"\n"+"\n"
			 end
			}

		end
		#############################

		# 投稿の文字の長さのsum
		#############################
	  	times.each do |time|

	  		file_name = "entry_length_sum_"
		  	object = Entry.where(user_id: serch_user)
		  	interval = 60*time

		  		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		length_count = 0
		  		entries = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1))
		  		entries.each do |entry|
		  			length_count = length_count + entry.body.length
		  		end
		  		date_array.push({start.to_s => length_count})
		  		# start = start.tomorrow １日毎に集計
		  		start = start + interval
		  		logger.info({time: start.to_s})
		  	end
		  	@data_all.push(date_array)

			logger.info({data: @data_all})

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				sum = 0
			  		data.each do |d|
					  	key = d.keys[0]
					  	# logger.warn key
					  	# logger.warn d[key]
					  	sum = sum + d[key]
					    write = key.to_s+","+d[key].to_s + "\n"
					    file.write write
					end
				file.write "sum,"+sum.to_s+"\n"+"\n"
			 end
			}

		end

		##############################


		# スレッドの出来上がり数
		#############################
	  	times.each do |time|

	  		file_name = "thread_open_sum_"
		  	object = Entry.where(user_id: serch_user)
		  	interval = 60*time

		  		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		t = object.where(theme_id: serch_theme_id ,parent_id: nil ,created_at: start .. (start + interval - 1)).count
		  		date_array.push({start.to_s => t})
		  		# start = start.tomorrow １日毎に集計
		  		start = start + interval
		  		logger.info({time: start.to_s})
		  	end
		  	@data_all.push(date_array)

			logger.info({data: @data_all})

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				sum = 0
			  		data.each do |d|
					  	key = d.keys[0]
					  	sum = sum + d[key]
					    write = key.to_s+","+d[key].to_s + "\n"
					    file.write write
					end
				file.write "sum,"+sum.to_s+"\n"+"\n"
			 end
			}

		end

		##############################

		# 閲覧の投稿者数 
	  	############################
	  	times.each do |time|

	  		file_name = "view_person_sum_"
		  	object = Webview.where(user_id: serch_user)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1))
	
		  		array = []
		  		t.each do |a|
		  			array.push(a.user_id)
		  		end

		  		date_array.push({start.to_s => array.uniq.count})
		  		# start = start.tomorrow １日毎に集計
		  		start = start + interval
		  		logger.info({time: start.to_s})
		  	end
		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				sum = 0
			  		data.each do |d|
					  	key = d.keys[0]
					  	# logger.warn key
					  	# logger.warn d[key]
					  	sum = sum + d[key]
					    write = key.to_s+","+d[key].to_s + "\n"
					    file.write write
					end
				file.write "sum,"+sum.to_s+"\n"+"\n"
			 end
			}

		end

		##############################

		# 投稿の投稿者数 
		##############################
		times.each do |time|

	  		file_name = "entry_person_sum_"
		  	object = Entry.where(user_id: serch_user)
		  	interval = 60 * time

		  	# 時間ごとの投稿の推移
	  		date_array = []
	  		@data_all = []
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1))
	
		  		array = []
		  		t.each do |a|
		  			array.push(a.user_id)
		  		end

		  		date_array.push({start.to_s => array.uniq.count})
		  		# start = start.tomorrow １日毎に集計
		  		start = start + interval
		  		logger.info({time: start.to_s})
		  	end
		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
			@data_all.each do |data|

				sum = 0
			  		data.each do |d|
					  	key = d.keys[0]
					  	# logger.warn key
					  	# logger.warn d[key]
					  	sum = sum + d[key]
					    write = key.to_s+","+d[key].to_s + "\n"
					    file.write write
					end
				file.write "sum,"+sum.to_s+"\n"+"\n"
			 end
			}

		end

		##############################


		# 単語数（指定時間における）
	  	############################
	 #  	times.each do |time|

	 #  		file_name = "entry_word_sum_"
		#   	object = Entry.where(user_id: serch_user)
		#   	interval = 60*time

		#   	# 時間ごとの投稿の推移
	 #  		date_array = []
	 #  		@data_all = []
	 #  		start = start_time
		#   	while ((end_time - start) > 0)
		#   		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval - 1))
	
		#   		array = []
		#   		count = 0
		#   		t.each do |a|
		#   			words = count_words(a.body)
		#   			p words
		#   			words.each{|key, value|
		# 			  count = count + value
		# 			}
		#   		end

		#   		date_array.push({start.to_s(:time) => count})
		#   		# start = start.tomorrow １日毎に集計
		#   		start = start + interval
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

		# ユーザごとの分析---投稿数
	  	############################
	  	times.each do |time|

	  		file_name = "persons_data_entry_"
	  		user_array = []
	  		date_array = []
		  	@data_all = []


		  	object = Entry.where(theme_id: serch_theme_id)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		array = []
		  		serch_user.each do |user|
		  			t = object.where(user_id: user ,created_at: start .. (start + interval - 1))
			  		array.push(t.count)
		  		end
		  		date_array.push({start.to_s => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user_id,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).id.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	write = "username,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	count_array = []
			  	serch_user.each_with_index do |user,i|
			  		count_array[i] = 0
			  	end

				@data_all.each do |data|

				  		data.each do |d|
						  	key = d.keys[0]
						  	# logger.warn key
						  	# logger.warn d[key]

						    write = key.to_s+","
						    d[key].each_with_index do |data, i|
						    	write = write + data.to_s + ","
						    	count_array[i] = count_array[i] + data
						    end
						    write = write + "\n"
						    file.write write
						end
				end

				write = ","
				count_array.each do |count|
					write = write + count.to_s + ","
				end
				write = write + "\n"
				file.write write
			}

		end
		##############################

		# ユーザごとの分析---閲覧数
	  	############################
	  	times.each do |time|

	  		file_name = "persons_data_view_"
	  		user_array = []
	  		date_array = []
		  	@data_all = []


		  	object = Webview.where(theme_id: serch_theme_id)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		array = []
		  		serch_user.each do |user|
		  			t = object.where(user_id: user ,created_at: start .. (start + interval - 1))
			  		array.push(t.count)
		  		end
		  		date_array.push({start.to_s => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user_id,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).id.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	write = "username,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	count_array = []
			  	serch_user.each_with_index do |user,i|
			  		count_array[i] = 0
			  	end

				@data_all.each do |data|

				  		data.each do |d|
						  	key = d.keys[0]
						  	# logger.warn key
						  	# logger.warn d[key]

						    write = key.to_s+","
						    d[key].each_with_index do |data, i|
						    	write = write + data.to_s + ","
						    	count_array[i] = count_array[i] + data
						    end
						    write = write + "\n"
						    file.write write
						end
				end

				write = ","
				count_array.each do |count|
					write = write + count.to_s + ","
				end
				write = write + "\n"
				file.write write
			}

		end
		##############################

		# ユーザごとの分析---いいね
	  	############################
	  	times.each do |time|

	  		file_name = "persons_data_like_"
	  		user_array = []
	  		date_array = []
		  	@data_all = []


		  	object = Like.where(theme_id: serch_theme_id)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		array = []
		  		serch_user.each do |user|
		  			t = object.where(user_id: user ,created_at: start .. (start + interval - 1))
			  		array.push(t.count)
		  		end
		  		date_array.push({start.to_s => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user_id,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).id.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	write = "username,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	count_array = []
			  	serch_user.each_with_index do |user,i|
			  		count_array[i] = 0
			  	end

				@data_all.each do |data|

				  		data.each do |d|
						  	key = d.keys[0]
						  	# logger.warn key
						  	# logger.warn d[key]

						    write = key.to_s+","
						    d[key].each_with_index do |data, i|
						    	write = write + data.to_s + ","
						    	count_array[i] = count_array[i] + data
						    end
						    write = write + "\n"
						    file.write write
						end
				end

				write = ","
				count_array.each do |count|
					write = write + count.to_s + ","
				end
				write = write + "\n"
				file.write write
			}

		end
		##############################


		# ユーザごとの分析---単語数
	  	###########################
	 #  	times.each do |time|

	 #  		file_name = "persons_data_word_"
	 #  		user_array = []
	 #  		date_array = []
		#   	@data_all = []


		#   	object = Entry.where(theme_id: serch_theme_id)
		#   	interval = 60*time

		#   	# 時間ごとの投稿の推移
	 #  		start = start_time
		#   	while ((end_time - start) > 0)
		#   		array = []
		#   		serch_user.each do |user|
		#   			t = object.where(user_id: user ,created_at: start .. (start + interval - 1))
		#   			count = 0
		# 	  		t.each do |a|
		# 	  			words = count_words(a.body)
		# 	  			words.each{|key, value|
		# 				  count = count + value
		# 				}
		# 	  		end
		# 	  		array.push(count)
		#   		end
		#   		date_array.push({start.to_s(:time) => array})
		#   		start = start + interval
		# 	end

		#   	@data_all.push(date_array)

		# 	logger.info({data: @data_all})


		# 	file_name = "log/csv2/"+file_name+time.to_s+".csv"
		# 	File.open(file_name, 'w') {|file|
		# 		write = "user,"
		# 	  	serch_user.each do |user|
		# 	  		write = write + User.find(user).name + ","
		# 	  	end
		# 	  	write = write + "\n"
		# 	  	file.write write

		# 	  	count_array = []
		# 	  	serch_user.each_with_index do |user,i|
		# 	  		count_array[i] = 0
		# 	  	end

		# 		@data_all.each do |data|

		# 		  		data.each do |d|
		# 				  	key = d.keys[0]
		# 				  	# logger.warn key
		# 				  	# logger.warn d[key]

		# 				    write = key.to_s+","
		# 				    d[key].each_with_index do |data, i|
		# 				    	write = write + data.to_s + ","
		# 				    	count_array[i] = count_array[i] + data
		# 				    end
		# 				    write = write + "\n"
		# 				    file.write write
		# 				end
		# 		end

		# 		write = ","
		# 		count_array.each do |count|
		# 			write = write + count.to_s + ","
		# 		end
		# 		write = write + "\n"
		# 		file.write write
		# 	}

		# end
		#############################

		# ユーザごとの分析---文字の長さ
	  	############################
	  	times.each do |time|

	  		file_name = "persons_data_length_"
	  		user_array = []
	  		date_array = []
		  	@data_all = []


		  	object = Entry.where(theme_id: serch_theme_id)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		array = []
		  		serch_user.each_with_index do |user, i|
		  			t = object.where(user_id: user ,created_at: start .. (start + interval - 1))
		  			count = 0
			  		t.each do |a|
			  			count = count + a.body.length
			  		end
			  		array.push(count)
		  		end
		  		date_array.push({start.to_s => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user_id,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).id.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	write = "username,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	count_array = []
			  	serch_user.each_with_index do |user,i|
			  		count_array[i] = 0
			  	end

				@data_all.each do |data|

				  		data.each do |d|
						  	key = d.keys[0]
						  	# logger.warn key
						  	# logger.warn d[key]

						    write = key.to_s+","
						    d[key].each_with_index do |data, i|
						    	write = write + data.to_s + ","
						    	count_array[i] = count_array[i] + data
						    end
						    write = write + "\n"
						    file.write write
						end
				end

				write = ","
				count_array.each do |count|
					write = write + count.to_s + ","
				end
				write = write + "\n"
				file.write write
			}

		end
		##############################


		# ユーザごとの分析---スレッドの作成数
	  	############################
	  	times.each do |time|

	  		file_name = "persons_data_thread_open_"
	  		user_array = []
	  		date_array = []
		  	@data_all = []


		  	object = Entry.where(theme_id: serch_theme_id)
		  	interval = 60*time

		  	# 時間ごとの投稿の推移
	  		start = start_time
		  	while ((end_time - start) > 0)
		  		array = []
		  		serch_user.each_with_index do |user, i|
		  			t = object.where(user_id: user ,parent_id: nil ,created_at: start .. (start + interval - 1))
			  		array.push(t.count)
		  		end
		  		date_array.push({start.to_s => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user_id,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).id.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	write = "username,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name.to_s + ","
			  	end
			  	write = write + "\n"
			  	file.write write

			  	count_array = []
			  	serch_user.each_with_index do |user,i|
			  		count_array[i] = 0
			  	end

				@data_all.each do |data|

				  		data.each do |d|
						  	key = d.keys[0]
						  	# logger.warn key
						  	# logger.warn d[key]

						    write = key.to_s+","
						    d[key].each_with_index do |data, i|
						    	write = write + data.to_s + ","
						    	count_array[i] = count_array[i] + data
						    end
						    write = write + "\n"
						    file.write write
						end
				end

				write = ","
				count_array.each do |count|
					write = write + count.to_s + ","
				end
				write = write + "\n"
				file.write write
			}

		end
		##############################







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

	def count_words(text)
	  # 単語の構成文字
	  word_char = '[\w’\/-]'
	  # Google Play Awards や Clash of Kings のような複合語を検索する
	  compound_words = /[A-Z]#{word_char}*(?: of| [A-Z]#{word_char}*)+/
	  # 英単語を検索する
	  words = /#{word_char}+/
	  # 複合語が優先的に検索されるように正規表現を結合する
	  regex = Regexp.union(compound_words, words)
	  text.scan(regex).each_with_object(Hash.new(0)) do |word, count_table|
	    count_table[word] += 1
	  end
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

	def fix_time
		# 1:42:42
		# 2:23:00
		# +40m,18s
		# Entry.all.each do |entry|
		# 	entry.created_at = entry.created_at - (40*60 + 18) - (40*60 + 18)
		# 	entry.save 
		# end
		# Webview.all.each do |entry|
		# 	entry.created_at = entry.created_at - (40*60 + 18)
		# 	entry.save 
		# end

		# Like.all.each do |entry|
		# 	entry.created_at = entry.created_at - (40*60 + 18)
		# 	entry.save 
		# end
		
	end

	# def child_entry_count(entry, user)
	# 	count = 0
	# 	if entry.user_id == user
	# 		count = count + 1
	# 	end

	# 	if entry.children.count > 0

	# 		entry.children.each do |e|
	# 			count = count + child_entry_count(e, user)
	# 		end
	# 	end

	# 	return count
	# end

	def child_entry_array(entry)
		if entry.title.nil?
			title = ""
		else
			title = entry.title.gsub(/(\r\n|\r|\n|\f)/,"")
		end

		if entry.body.nil?
			body = ""
		else
			body = entry.body.gsub(/(\r\n|\r|\n|\f)/,"")
		end

		@array.push([entry.id, title, body , entry.created_at])
		entry.children.each do |e|
			child_entry_array(e)
		end
	end

	def child_entry_array2(entry)
		entry.children.each do |e|
			@child_entries.push(e)
			child_entry_array2(e)
		end
	end

	def child_entry_array3(e)
		@child_entries.push(e)
		e.children.each do |e|
			child_entry_array3(e)
		end
	end
end
