class HomesController < ApplicationController
  protect_from_forgery except: :load_test_api

  def collagree
  end

  # ファシリテーターポスト
  def auto_facilitation_post

    theme_id = params[:id]
    # フラグ管理

    json_filename = 'app/assets/json/issues_'+theme_id.to_s+'.json'
    flag_filename =  'app/assets/json/flag_'+theme_id.to_s+'.txt'

    data_hash = JSON.parse(File.read(json_filename))
    p "="*100
    p data_hash
    write_count = 0
    timestamp = data_hash["timestamp"]
    if not File.exist?(flag_filename)
      File.write(flag_filename, "0")
    end
    recent_timestamp = File.read(flag_filename)
    File.write(flag_filename, timestamp)

    # オートファシリテーションを実行
    if recent_timestamp.to_i < timestamp.to_i
      data_hash["thread_ids"].each do |thread_id|

        issues = data_hash["issues"][thread_id.to_s]
        issues_str = ""
        issues.each do |issue|
          issues_str += "「"+ issue + "」"
        end
        post_body = "キーワードとして" + issues_str + "が上がっています。\r\nこのキーワードを元に議論を進めていきましょう。"

        p post_body

        # thread_entry = Entry.find(thread_id)
        Entry.post_facilitation_keyword(thread_id, theme_id , post_body)

      end

      write_count = data_hash["thread_ids"].count
    end

    render :json => {"count"=>  write_count}

  end

  # Python用に議論をjsonで返す
  def auto_facilitation_json
    # Modelのtimestampの更新を無効に
    Entry.record_timestamps = false

    theme_id = params[:id]
    theme = Theme.find(theme_id)
    theme.point_histories.delete_all

    entries = Entry.all.includes(:user).includes(:issues).in_theme(theme_id).root
    
    webviews = Webview.get_all(theme_id)

    entries_json = []
    ids_json = []
    ids_all_json = []
    entries.each do |entry|
      dict = {entry.id => entry}
      ids  = {"root"=> entry.id}
      ids_all = []
      dict,ids,ids_all = children_loop(entry, theme_id , dict , ids, ids_all)

      entries_json.push(dict)
      ids_json.push(ids)
      ids_all_json.push(ids_all)
    end

    render :json => {"ids"=> ids_json,"ids_all"=> ids_all_json,"data"=> entries_json, "webview"=>webviews}

  end

  # オートファシリテーション用メソッド
  def children_loop(entry, theme_id , dict, ids, ids_all)
    entry.thread_childrens.each do |child|
      child_hash = child.attributes
      child_likes = child.likes

      child_hash["like"] = child_likes
      child_hash["like_count"] = child_likes.count


      dict[child.id] = child_hash

      ids[entry.id] = ids.fetch(entry.id, []).push(child.id)
      ids_all.push(child.id)
      dict,ids,ids_all = children_loop(child, theme_id, dict, ids, ids_all)
    end
    return dict,ids,ids_all
  end


  def about
  end

  def admin
  end

  def statistic
  end

  def introduction
  end

  def intro_display
  end

  def intro_account
  end

  def intro_discuss
  end

  def intro_facilitation
  end

  def privacy
  end

  def agreement
  end

  def project
  end

  def load_test_api
    entry = Entry.new(entry_params)
    entry.save
    render json: entry.to_json
  end

  def destroy_theme_entries
    theme = Theme.find(params[:theme_id])
    theme.entries.delete_all
    theme.activities.delete_all
    theme.point_histories.delete_all
    Notice.delete_all
    redirect_to '/'
  end

  private

   def entry_params
     params.permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation)
   end

end
