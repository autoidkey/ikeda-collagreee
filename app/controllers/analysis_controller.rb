class AnalysisController < ApplicationController
	include Bm25
	require 'csv'

	def index

		# fix_time
	  	serch_theme_id = 13
	  	times = [60] ##配列で管理 10~13
	  	serch_user_id = User.pluck(:id) ##データを取る参加者
	  	# remove_user = [1,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,34,35,36,37,38,39,40,41,42,43,44,100,84,31,32,10,11,12,13,99]
	  	# remove_user = [1,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,34,35,36,37,38,39,40,41,42,43,44]
	  	remove_user = [1,46]
	  	# serch_user_id = [20,5,3,48,1]
	  	# serch_user_id = [92,19,17,15,58]
	  	# start_time = Time.local(2015, 12, 15, 0, 0, 0)
	  	# end_time = Time .local(2016, 1, 6, 0, 0, 0)
	  	start_time =  Time.local(2016, 10, 11, 0, 0, 0)
	  	end_time = Time.local(2016, 10, 15, 0, 0, 0)

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

		##############################


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
		  		date_array.push({start.to_s(:time) => t})
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
		  		date_array.push({start.to_s(:time) => t})
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
		  		date_array.push({start.to_s(:time) => t})
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
		  		date_array.push({start.to_s(:time) => length_count})
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
		  		date_array.push({start.to_s(:time) => t})
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

		  		date_array.push({start.to_s(:time) => array.uniq.count})
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

		  		date_array.push({start.to_s(:time) => array.uniq.count})
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
		  		date_array.push({start.to_s(:time) => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name + ","
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
		  		date_array.push({start.to_s(:time) => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name + ","
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
		  		date_array.push({start.to_s(:time) => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name + ","
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
		  		date_array.push({start.to_s(:time) => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name + ","
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
		  		date_array.push({start.to_s(:time) => array})
		  		start = start + interval
			end

		  	@data_all.push(date_array)

			logger.info({data: @data_all})


			#からむの作成

			file_name = "log/csv2/"+file_name+time.to_s+".csv"
			File.open(file_name, 'w') {|file|
				write = "user,"
			  	serch_user.each do |user|
			  		write = write + User.find(user).name + ","
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
end
