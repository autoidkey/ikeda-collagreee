class HomesController < ApplicationController
  protect_from_forgery except: :load_test_api

  def collagree
  end

  # ファシリテーターポスト
  def auto_facilitation_post

    theme_id = params[:id]
    # フラグ管理
    file = File.read('app/assets/json/issues.json')
    data_hash = JSON.parse(file)
    p "="*100
    p data_hash
    data_hash["thread_ids"].each do |thread_id|

      issues = data_hash["issues"][thread_id.to_s]
      issues_str = ""
      issues.each do |issue|
        issues_str += "「"+ issue + "」"
      end
      post_body = "キーワードとして" + issues_str + "が上がっています。このキーワードを元に議論を進めていきましょう"

      p post_body

      # thread_entry = Entry.find(thread_id)
      Entry.post_facilitation_keyword(thread_id, theme_id , post_body)

    end

    render :json => {"count"=>  data_hash["thread_ids"].count}

  end

  # Python用に議論をjsonで返す
  def auto_facilitation_json
    # Modelのtimestampの更新を無効に
    Entry.record_timestamps = false

    theme_id = params[:id]
    theme = Theme.find(theme_id)
    theme.point_histories.delete_all

    entries = Entry.all.includes(:user).includes(:issues).in_theme(theme_id).root
    
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

    render :json => {"ids"=> ids_json,"ids_all"=> ids_all_json,"data"=> entries_json}

  end

  # オートファシリテーション用メソッド
  def children_loop(entry, theme_id , dict, ids, ids_all)
    entry.thread_childrens.each do |child|

      dict[child.id] = child
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

  private

   def entry_params
     params.permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation)
   end

end
