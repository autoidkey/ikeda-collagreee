require 'natto'

class ThemesController < ApplicationController
  add_template_helper(ApplicationHelper)
  include ApplicationHelper

  protect_from_forgery except: :auto_facilitation_test
  before_action :set_theme, only: [:point_graph, :user_point_ranking, :check_new_message_2015_1]
  before_action :authenticate_user!, only: %i(create, new)
  before_action :set_theme, :set_keyword, :set_facilitation_keyword, :set_point, :set_activity, :set_ranking, only: [:show, :only_timeline]
  load_and_authorize_resource

  include Bm25
  include Stamp
  require 'time'

  def index
    @themes = Theme.all
  end

  def show
    #NoticeMailer.delay.facilitate_join_notice("title","test title","test body") # メールの送信


    @entry = Entry.new
    @entries = Entry.sort_time.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(10)


    @search_entry = SearchEntry.new
    @issue = Issue.new

    @facilitator = current_user.role == 'admin' || current_user.role == 'facilitator' if user_signed_in?

    @other_themes = Theme.others(@theme.id)
    @facilitations = Facilitations

    @theme.join!(current_user) if user_join?
    current_user.delete_notice(@theme) if user_signed_in?
    @gravatar = gravatar_icon(current_user)

    @stamps = stamp_list

    # ファシリテータからのお知らせコーナー
    comment = FacilitationInfomation.where(:theme_id => params[:id]).last
    if comment != nil
      @f_comment = comment[:body]
    else
      @f_comment = "こんにちは。今回、議論のファシリテータを務めさせていただきます。よろしくお願いします！"
    end
    puts "ファシリテータからのコメントは = #{@f_comment}です！！"

    # ウェブアクセスをカウントアップ
    # TODO:該当グループ以外のテーマを閲覧した時は除外する
    user_id = user_signed_in? ? current_user.id : nil
    Webview.count_up(user_id,@theme.id)

    render 'show_no_point' unless @theme.point_function

    #以下議論ツリーで使用する投稿一覧
    @entry_tree = Entry.all.where(:theme_id => params[:id])

    #他のでも使用できるファシリテータが選んだフェーズナンバー
    @tree_type = Phase.all.where(:theme_id => params[:id]).order(:created_at).reverse_order
    if @tree_type[0] == nil then
      @tree_type = 1
    else 
      @tree_type = @tree_type[0][:phase_id]
    end

    #idmの実装
    # @idm_result = []
    # @idm_link = 0
    # @idm_n = 0
    # @idm_F = []
    # @idm_K = []
    # idm  
    # new_idm
    # logger.info @idm_K

    #要約で必要になるpythonの実行処理が下に記述
    s = ""
    youyakuId = []
    for entry in @entry_tree
      str = entry.body.gsub(/(\s)/,"")
      str = str.gsub(/《[^》]+》/, "")
      str = str.gsub(/　/, "  ")
      str = str.gsub('(', '（') 
      str = str.gsub(')', '）') 
      str = str.gsub('!', '！') 
      str = str.gsub('&', '＆') 
      s = s+str+" "
      youyakuId.push(entry.id)
    end

    count = 0
    @youyaku = []
    IO.popen("python ./python/youyakutest/test.py #{s}").each do |line|
       @youyaku << {"id" => youyakuId[count] , "text" => line.chomp}
       count = count + 1
    end

  end

  # def new_idm
  # count = 0
  #  for num1 in 0..@idm_result.length-1 do
  #     #頻度を探す fに入れておく！！
  #     f = 0
  #     for num2 in 0..@idm_F.length-1 do
  #       if @idm_result[num1][0] == @idm_F[num2][0]
  #         f = @idm_F[num2][1]
  #         break
  #       end
  #     end

  #     #期待値を計算する eに入れておく
  #     e = 0
  #     if f != 1
  #       e = 0.0
  #       for num in 2..f do
  #         e = e + (num-1)*((f.quo(@idm_n))*(@idm_link.quo(@idm_n-1)))**(num-1)
  #       end
  #     end

  #     #乖離度を計算する kとする
  #     k = 0.0

  #     k = ((@idm_result[num1][1] - e)**2).quo(e)

  #     @idm_K[count] = [@idm_result[num1][0],k.round(4),e]
  #     count = count + 1
  #   end

  # end

  # def idm
  #   entry_all = Entry.all.where(:theme_id => params[:id])
  #   word_array = []
  #   # { :name => "k-sato", :email => "k-sato@foo.xx.jp",:address => "Tokyo" }
  #   entry_all.each do |entry|
  #     if search_child(entry["id"]).length != 0
  #       if entry["title"] != nil
  #         title = norm_connection2(entry["title"]).uniq
  #         body = norm_connection2(entry["body"]).uniq
  #         words = title + body
  #         com_idm([],entry["id"])

  #         #リンク数を計算する
          
  #       # else
  #       #   body = norm_connection2(entry["body"]).uniq
  #       #   logger.info body
  #       end
  #     end
  #   end
  #   return nil
    
  # end

  # def com_idm(word_array, id)
  #   @idm_n = @idm_n + 1
  #   entry = search_id(id)
  #   words = norm_connection2(entry["body"]).uniq
  #   idm_f(words)
  #   children = search_child(id)

  #   word_array.each do |word|
  #     if words.include?(word) && word.length>1
  #       num = words.count(word)
  #       # ここで計算して結果の配列を成形する
  #       idm_result(word)
  #       words.push(word)
  #     end
  #   end
    
  #   if children.length != 0
  #     children.each do |child|
  #       @idm_link = @idm_link + 1
  #       com_idm(words,child)
  #     end
  #   end
  # end

  # def idm_f(words)
  #   words.each do |word|
  #     flag = 0
  #     count = 0
  #     for f in @idm_F do
  #       if f[0] == word
  #         @idm_F[count][1] = @idm_F[count][1] + 1
  #         flag = 1
  #         break
  #       end
  #       count = count + 1
  #     end
  #     if flag == 0
  #       @idm_F.push([word,1])
  #     end
  #   end
  # end

  # def idm_result(word)
  #   #result配列に追加するwordがを登録されているか[["蠣久",2],["ピンク",4]]
  #   flag = 0
  #   count = 0
  #   for result in @idm_result do
  #     if result[0]==word
  #       @idm_result[count][1] = @idm_result[count][1] + 1
  #       flag = 1
  #       break
  #     end
  #     count = count + 1
  #   end
  #   if flag == 0
  #     @idm_result.push([word,1])
  #   end
  # end



  # def search_child(id)
  #   entry_all = Entry.all.where(:theme_id => params[:id])
  #   child_id = []
  #   entry_all.each do |entry|
  #     if entry["parent_id"] == id
  #       child_id.push(entry["id"])
  #     end
  #   end
  #   return child_id
  # end

  # def search_id(id)
  #   entry_all = Entry.all.where(:theme_id => params[:id])
  #   entry_all.each do |entry|
  #     if entry["id"] == id
  #       return entry
  #     end
  #   end
  #   return nil
  # end





  def discussion_data
    @entries = Entry.all.includes(:user).includes(:issues).in_theme(@theme.id).asc
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "theme-#{@theme.id}-#{Time.now.to_date.to_s}.csv", type: :csv
      end
    end
  end

  def point_data
    @point_histories = @theme.point_histories.includes(entry: [:user]).includes(like: [:user]).includes(reply: [:user])
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "point-theme#{@theme.id}-#{Time.now.to_date.to_s}.csv", type: :csv
      end
    end
  end


  # オートファシリテーション用メソッド
  def auto_facilitation_test
    # Modelのtimestampの更新を無効に
    # Entry.record_timestamps = false

    theme = Theme.find(params[:id])
    theme.entries.delete_all
    theme.point_histories.delete_all

    seed_theme_id = 2 # 元となる議論テーマのIDを指定
    @entries = Entry.all.includes(:user).includes(:issues).in_theme(seed_theme_id).root

    @entries.each do |entry|
      copy_entry = entry.copy(nil, params[:id])
      children_copy(entry, copy_entry, params[:id])
    end

    # Modelのtimestampの更新を有効に
    Entry.record_timestamps = true

    redirect_to theme
  end

  # オートファシリテーション用メソッド
  def children_copy(entry, copy_entry, theme_id)
    require 'time'
    entry.thread_childrens.each do |child|
      copy_child = child.copy(copy_entry, theme_id)
      # ここにオートファシリテーション用の条件を付与

      strTime = Time.now.strftime("%Y-%m-%d %H-%M-%S")
      now_timestamp   = Time.parse(strTime).to_i
      entry_timestamp =  Time.parse(entry.created_at.to_s).to_i
      child_timestamp =  Time.parse(child.created_at.to_s).to_i
      is_entry_pn = entry.np.to_i >= 50 ? true :  false
      is_entry_pn = entry.parent_id.nil? ? true : is_entry_pn
      is_child_pn = child.np.to_i >= 50 ? true :  false
      ignore_same_user = entry.user_id == child.user_id ? false : true

      if now_timestamp - child_timestamp > 60*60 and ignore_same_user
        body = "議論が停滞しています。何か意見のある人は居ませんか？"
        Entry.post_facilitation(copy_child, theme_id , body)

      elsif not (is_entry_pn and is_child_pn) and ignore_same_user
        body = "メリットとデメリットを挙げてみましょう。"
        Entry.post_facilitation(copy_child, theme_id , body)
      end
      children_copy(child, copy_child, theme_id)
    end
  end

  def only_timeline
    @entry = Entry.new
    @entries = Entry.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(10)
    @facilitator = current_user.role == 'admin' || current_user.role == 'facilitator' if user_signed_in?
    @other_themes = Theme.others(@theme.id)
    @facilitations = Facilitations
    @theme.join!(current_user) if user_join?
    current_user.delete_notice(@theme) if user_signed_in?
  end

  def check_new_message_2015_1
    @entry = @theme.entries.latest.first
    render 'check_new_message_2015_1', formats: [:json], handlers: [:jbuilder]
  end

  def  update_phase
    @phase = Phase.new(:phase_id => params[:phase],:theme_id => params[:id])
    respond_to do |format|
      if @phase.save
        format.html { redirect_to @theme, notice: 'フェーズを変更しました' }
        format.json { render action: 'show', status: :created, location: @theme }
      else
        format.html { render action: 'new' }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def search_entry
    @entry = Entry.new
    @issue = Issue.new
    @facilitations = Facilitations
    @page = params[:page] || 1

    if params[:search_entry][:order] == 'time'
      @entries = @theme.sort_by_new(params[:search_entry][:issues])
    elsif params[:search_entry][:order] == 'popular'
      @entries = @theme.sort_by_reply(params[:search_entry][:issues])
    elsif params[:search_entry][:order] == 'point'
      @entries = @theme.sort_by_points(params[:search_entry][:issues])
    end

    @entries = Kaminari.paginate_array(@entries).page(params[:page]).per(10)

    respond_to do |format|
      format.js
    end
  end

  # 小数点第2位以下を切り捨てるメソッド
  def cut_decimal_point(float)
    BigDecimal((float).to_s).floor(1).to_f
  end

  # 投稿を反映する時の処理
  def create_entry
    @entry = Entry.new
    @new_entry = Entry.new(entry_params)
    @theme = Theme.find(params[:id])

    @dynamicpoint = 0
    matching_bonus = 0    # キーワードとの一致ボーナス用
    
    nword_flag = 0
    nword_bonus = 0       # 新規単語ボーナス用

    time_bonus = 0        # 投稿時間ボーナス用

    # 最後に投稿されたスレッドの時間
    lastpost = Entry.where(theme_id: params[:id]).where.not(title: nil).reverse_order.last  #なぜか逆順になるので・・・要検証
    if lastpost != nil
      @lastpost_time = lastpost[:created_at]
    else
      @lastpost_time = -1
    end
    puts "最後の書き込みは#{@lastpost_time}です！！"

    # 現在時刻
    @newpost_time = Time.now

    # 最後に投稿されたスレッドからの時間
    @sub_time = (@newpost_time - @lastpost_time).floor / 60
    puts "現在の時刻は#{@newpost_time}です！！最後の書き込みから#{@sub_time}分です！！"

    # フェイズidの判別
    phase = Phase.where(theme_id: params[:id]).last
    if phase != nil
      @phase_now = phase[:phase_id]
    else
      @phase_now = 1
    end
    puts "現在のフェイズは#{@phase_now}です！！"

    # 追加ポイント用の係数
    # 3〜4行程度の書き込みで30pt前後になるように調整すること
    nword_coefficient = 0       # M1 キーワードに不一致（発散）のワードに対しての係数
    matching_coefficient = 0    # M2 キーワードに一致（収束）のワードに対しての係数

    # フェイズによるインセンティブパラメータの変化
    # M1,M2の値は要調整
    if @phase_now == 1
      puts "発散フェイズだよ"
      nword_coefficient = 0.7
      matching_coefficient = 20

    elsif @phase_now == 2
      puts "収束フェイズだよ"
      nword_coefficient = 0.5
      matching_coefficient = 25

    elsif @phase_now == 3
      puts "合意フェイズだよ"
      nword_coefficient = 0.3
      matching_coefficient = 30
    end

    # DBからキーワードとスコアを抽出してハッシュに入れる
    keywords_scores = Keyword.where(user_id: nil, theme_id: params[:id]).map do |key| 
      {id: key.id, word: key.word, score: key.score}
    end

    # こっちはファシリテーターが手動で設定したキーワード用
    # facilitation_keywords_scores = FacilitationKeyword.where(theme_id: params[:id]).map do |key| 
    #   {id: key.id, word: key.word, score: key.score}
    # end

    # 書き込みの内容を取得
    text = entry_params["body"]

    # MeCabによる投稿内容の形態素解析 
    # lib/bm25.rbのモジュールを使って形態素解析、単語抽出を行う
    # 同一の単語は1回のみカウント(.uniqにより、重複を許さない)
    word = norm_connection2(text).uniq
    print "\n 抽出したワードは、#{word}です。\n"
    
    # 抽出したワードを1つずつ読み込んでいく
    word.each do |w|

      puts "----------------------------------------------------------"
      puts "判定中の単語:#{w}"   # デバッグ用

      # そのワードが新規ワードかを判定するフラグ
      nword_flag = 1

      puts "通常のキーワードとの一致判定"
      keywords_scores.each do |key|

        if key[:word].include?(w)

          word_len = w.length
          keyword_len = key[:word].length
          puts "「#{w}」が「#{key[:word]}」と、#{w.length} / #{key[:word].length} 一致!!"

          matching_rate = word_len.to_f / keyword_len.to_f
          matching_point = key[:score] * 20 * matching_rate
          puts "#{matching_point}ポイント獲得!!"

          matching_bonus += matching_point
          nword_flag = 0
        end
      end

      # puts "ファシリテーターによる手動キーワードとの一致判定"
      # facilitation_keywords_scores.each do |key|

      #   if key[:word].include?(w)

      #     word_len = w.length
      #     keyword_len = key[:word].length
      #     puts "「#{w}」が「#{key[:word]}」と、#{w.length} / #{key[:word].length} 一致!!"

      #     matching_rate = word_len.to_f / keyword_len.to_f
      #     matching_point = key[:score] * matching_coefficient * matching_rate
      #     puts "#{matching_point}ポイント獲得!!"

      #     matching_bonus += matching_point
      #     nword_flag = 0
      #   end
      # end

      # 新規単語投稿によるポイント付与(0.1pt)
      if nword_flag == 1
        nword_bonus += nword_coefficient
        puts "「#{w}」は新規単語!! #{nword_coefficient}ポイント獲得!!"
      end

    end

    # 完全一致と部分一致を足した値を追加ポイントとする(小数点第2位以下は切り捨て)
    @dynamicpoint = cut_decimal_point(matching_bonus + nword_bonus)

    # 投稿内容に応じたポイント付与をやめる場合の処理
    puts "テーマ番号は#{params[:id]}"
    if params[:id] == "4" # ここを適当に変える
      @dynamicpoint = 20
    end
    
    puts "----------------------------------------------------------"
    puts "獲得した追加ポイント = #{@dynamicpoint}!!"
    puts "----------------------------------------------------------"

    @facilitations = Facilitations
    @count = @theme.entries.root.count
    
    respond_to do |format|
      if @new_entry.save
        print "#エントリーをセーブ"
        # after_saveの方を消して、こっちを追加
        @new_entry.logging_point(@dynamicpoint)  # インスタンスメソッドだからこうやって書くべき
        print "#ポイントが保存された"
        tags = Issue.checked(params[:issues])
        @new_entry.tagging!(Issue.to_object(tags)) unless tags.empty?
        format.js
      else
        format.json { render json: 'json error' }
      end
    end


  end

  def render_new
    @new_entry = Entry.find(params[:entry_id])
    @entry = Entry.new

    @theme = Theme.find(params[:id])
    @facilitations = Facilitations

    respond_to do |format|
      format.js
    end
  end


  def new
    @theme = Theme.new
  end

  def create
    @theme = Theme.new(theme_params)

    respond_to do |format|
      if @theme.save
        format.html { redirect_to @theme, notice: 'テーマを作成しました' }
        format.json { render action: 'show', status: :created, location: @theme }
      else
        format.html { render action: 'new' }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def check_new
    notice = Notice.new_notice(current_user, params[:id])
    data = {
      entry: notice.select { |n| n.ntype == 0 },
      reply: notice.select { |n| n.ntype == 1 }.map { |n| { notice: n, entry: n.point_history.entry.body, reply: n.point_history.reply.body } },
      like: notice.select { |n| n.ntype == 2 }.map { |n| { notice: n, entry: n.point_history.entry.body } }
    }
    render json: data.to_json
  end

  def point_graph
    @user = current_user if user_signed_in?
    # @points = Point.user_all_point(@user, @theme).take(40)
    render 'point_graph', formats: [:json], handlers: [:jbuilder]
  end

  def user_point_ranking
    @ranking = @theme.point_ranking
    render 'user_point_ranking', formats: [:json], handlers: [:jbuilder]
  end

  def json_user_point
    @point_history = current_user.point_history(@theme).includes(entry: [:user]).includes(like: [:user]).includes(reply: [:user])
    @point_sum =
      render 'json_user_point', formats: [:json], handlers: [:jbuilder]
  end


  private

  def user_join?
    user_signed_in? && !@theme.join?(current_user) && !current_user.facilitator?
  end

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def set_keyword
    @keyword = @theme.keywords.select { |k| k.user_id.nil? }.sort_by { |k| -k.score }.group_by(&:score)
  end

  def set_facilitation_keyword
    @facilitation_keyword = FacilitationKeyword.where(theme_id: params[:id]).map do |key| 
      {id: key.id, word: key.word, score: key.score}
    end
  end

  def set_point
    if user_signed_in?
      @point_history = current_user.point_history(@theme).includes(entry: [:user]).includes(like: [:user]).includes(reply: [:user])
      @point_list = {
        # 小数点第1位までで切り捨て
        sum: cut_decimal_point(@theme.score(current_user)),
        entry: cut_decimal_point(current_user.redis_entry_point(@theme)),
        reply: cut_decimal_point(current_user.redis_reply_point(@theme)),
        like: current_user.redis_like_point(@theme),
        replied: current_user.redis_replied_point(@theme),
        liked: current_user.redis_liked_point(@theme)
      }
    end
  end



  def set_activity
    @activities = current_user.acitivities_in_theme(@theme) if user_signed_in?
  end

  def set_ranking
    @users_entry = @theme.joins.includes(:user).map(&:user).sort_by { |u| -u.entries.where(theme_id: @theme, facilitation: false).count }
    @user_ranking = @theme.point_ranking
    @user_ranking_before_0130 = @theme.point_ranking_before_0130
    @user_ranking_after_0130 = @theme.point_ranking_after_0130
  end

  def theme_params
    params.require(:theme).permit(:title, :body, :color, :admin_id, :image, :point_function)
  end

  def entry_params
    params.require(:entry).permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation, :stamp)
  end

end
