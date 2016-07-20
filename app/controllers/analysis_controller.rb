class AnalysisController < ApplicationController
	require 'csv'
	def index
	  	serch_theme_id = 3
	  	file_name = "treelog_d_3.csv"
	  	serch_user_id = User.pluck(:id) ##データを取る参加者
	  	# serch_user_id = [20,5,3,48,1]
	  	# serch_user_id = [92,19,17,15,58]
	  	logger.info({user: serch_user_id})
	  	# start_time = Time.local(2015, 12, 15, 0, 0, 0)
	  	# end_time = Time .local(2016, 1, 6, 0, 0, 0)
	  	start_time =  Time.local(2016, 6, 30, 9, 0, 0)
	  	end_time = Time.local(2016, 7, 6, 0, 0, 0)

	  	# object = Entry.all
	  	# object = Webview.all
	  	# object = Treedata.all
	  	object = TreeLog.all
	  	interval = 60*60*24

	  	@data_all = []
	  	
	  	# 時間ごとの投稿の推移
  		date_array = []
  		start = start_time
	  	while ((end_time - start) > 0)
	  		t = object.where(theme_id: serch_theme_id ,created_at: start .. (start + interval)).count
	  		date_array.push({start.to_s => t})
	  		# start = start.tomorrow １日毎に集計
	  		start = start + interval
	  	end
	  	@data_all.push(date_array)

		logger.info({data: @data_all})


		#からむの作成

		file_name = "log/csv/"+file_name
		File.open(file_name, 'w') {|file|
		@data_all.each do |data|

			sum = 0
		  		data.each do |d|
				  	key = d.keys[0]
				  	logger.warn key
				  	logger.warn d[key]
				  	sum = sum + d[key]
				    write = key.to_s+","+d[key].to_s + "\n"
				    file.write write
				end
			file.write "sum,"+sum.to_s+"\n"+"\n"
		 end
		}
		

		puts('書き込み完了')

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
end
