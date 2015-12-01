# 意見要約を行う
class YouyakuJob
  include Bm25
  def execute
    entry_all = Entry.all
    #スレッドのタイトルのノードidを取得する
    parent_id = []
    entry_all.each do |entry|
      if entry["parent_id"].nil?
        parent_id.push(entry["id"])
      end
    end
    if parent_id.length == 0
      return []
    end

    entry_all = Entry.all
    thread_array = serch_thread(entry_all , parent_id)
    #スレッドの中身が１つのやつは消去する
    i = 0
    while i < thread_array.length-1 do
      if thread_array[i].length < 2
        thread_array.delete_at(i)
      else
        i = i + 1
      end
    end


    if thread_array[thread_array.length-1].length < 2
      thread_array.delete_at(thread_array.length-1)
    end

    # csvの出力　python/youyaku1に使用する
    count = 0
    thread_array.each do |t|
      name = "./../../python/youyaku1/input_data/backup"+count.to_s+".csv"
      File.open(name, 'w') do |f|
        csv_string = CSV.generate do |csv|
          csv << Entry.column_names
          # users = Entry.where(:theme_id => params[:id] , :id => t)
          users = Entry.where(:id => t)
          #スレッドのタイトルを一番目にする
          flag = 0
          num = 0
          users.each do |user|
            if user["title"] != nil
              num = flag
            else
              flag = flag + 1
            end
          end
          temp = users
          temp[0],temp[num] = temp[num],temp[0]
          users = temp
          #ここまで

          users.each do |user|
            array = user.attributes.values_at("id","title","body","parent_id","np","user_id","facilitation","invisible","top_fix","created_at","updated_at","theme_id","image","has_point","has_reply","agreement","claster","stamp")
            time = array[9].strftime("%Y-%m-%d %H:%M:%S")
            array[9] = time.to_s
            time = array[10].strftime("%Y-%m-%d %H:%M:%S")
            array[10] = time.to_s
            csv << array
            # logger.warn user.attributes.values_at("id","title","body","parent_id","np","user_id","facilitation","invisible","top_fix","created_at","updated_at","theme_id","image","has_point","has_reply","agreement","claster","stamp")
          end
        end
        f.puts csv_string
        count = count + 1
      end
    end

    Youyakudata.all.delete_all()
    for i in 0..count-1
      s = "backup"+i.to_s+".csv"
      puts i
      IO.popen("python ./../../python/youyaku1/main.py #{s}").each do |line|
        puts line
        num = line.index(",")
        target_id = line[0,num]
        line.slice!(0, num+1)
        num = line.index(",")
        parent_id = line[0,num]
        line.slice!(0, num+1)
        num = line.index(",")
        theme_id = line[0,num]
        line.slice!(0, num+1)
        body = line
        youyaku = Youyakudata.new(target_id: target_id, thread_id: parent_id, theme_id: theme_id, body: line)
        youyaku.save
      end
    end

  end
end