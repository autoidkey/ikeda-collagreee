require 'natto'
require 'time'
require 'ots'
# require 'EnglishTokenizer'

class ThemesController < ApplicationController
  add_template_helper(ApplicationHelper)
  include ApplicationHelper

  protect_from_forgery except: :auto_facilitation_test
  before_action :set_theme, only: [:point_graph, :user_point_ranking, :check_new_message_2015_1, :search_entry]
  before_action :authenticate_user!, only: %i(create, new)
  before_action :set_theme, :set_keyword, :set_facilitation_keyword, :set_point, :set_activity, :set_ranking, only: [:show, :only_timeline, :vote_entry]
  # after_action  :test, only: [:show]

  # load_and_authorize_resource

  include Bm25
  include Stamp
  # include EnglishTokenizer
  # include call_test
  require 'time'

  def index
    @themes = Theme.all
  end

  # すぐにテストしたいときに使っている
  def test
    p @theme.vote_ranking
  end

  def show
    #NoticeMailer.delay.facilitate_join_notice("title","test title","test body") # メールの送信

    # if Time.now > Time.local(2016, 10, 28, 14, 30, 00)
    #   if current_user.age == "学生" && !Question.exists?(user_id: current_user.id)
    #     redirect_to new_question_path
    #   end
    # end

    @entry = Entry.new
    # @entries = Entry.sort_time.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(10)
    @entries = Entry.sort_time.all.includes(:user).includes(likes: :user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(90)

    @search_entry = SearchEntry.new
    @issue = Issue.new

    @facilitator = current_user.role == 'admin' || current_user.role == 'facilitator' if user_signed_in?

    @la = I18n.default_locale == :ja ? "ja" : "en"

    @other_themes = Theme.others(@theme.id)
    @facilitations =  I18n.default_locale == :ja ? Facilitations : Facilitations_en

    @theme.join!(current_user) if user_join?
    current_user.delete_notice(@theme) if user_signed_in?
    @gravatar = gravatar_icon(current_user)

    @stamps = stamp_list(params[:locale])

    # ファシリテータからのお知らせコーナー
    comment = FacilitationInfomation.where(:theme_id => params[:id]).last
    if comment != nil
      @f_comment = comment[:body]
    else
      @f_comment = t('controllers.greet')
    end

    # ウェブアクセスをカウントアップ
    # TODO:該当グループ以外のテーマを閲覧した時は除外する
    user_id = user_signed_in? ? current_user.id : nil
    Webview.count_up(user_id,@theme.id)

    @user_id = user_id


    render 'show_no_point' unless @theme.point_function

    #以下議論ツリーで使用する投稿一覧
    @entry_tree = Entry.where(:theme_id => @theme.id)
    @classes = ThreadClass.where(:theme_id => @theme.id)

    #他のでも使用できるファシリテータが選んだフェーズナンバー
    @tree_type = Phase.all.where(:theme_id => params[:id]).order(:created_at).reverse_order
    if @tree_type[0] == nil then
      @tree_type = 1
    else
      @tree_type = @tree_type[0][:phase_id]
      # 合意フェイズの最初に投票画面に遷移する
      if @tree_type == 3 && !VoteEntry.where(user_id: current_user.id, theme_id: @theme.id).exists?
        if !(@facilitator && VoteEntry.where(theme_id: @theme.id).exists?) #ファシリテータはすでに誰かが投稿してたら選択の変更はできない
          redirect_to vote_entry_path(@theme.id)
        end
      end
    
    end

    @entry_like_ranking = @theme.like_ranking
    

    #見出しデータの生成
    @youyaku = []
    youyakuDatas = Youyaku.where(:theme_id => @theme.id)
    youyakuDatas.each do |data|
      @youyaku << {"id" => data["target_id"] , "text" => data["body"]}
    end


    #クラスタリングのjsonを作成
    @themes_claster = []
    EntryClaster.all.each do |cla|
      @themes_claster.push({ :cla => cla["coaster"], :id => cla["entry_id"]})
    end


    #スレッド要約データの生成
    @youyaku_thread = []
    youyakuDatas = Youyakudata.where(:theme_id => params[:id])
    youyakuDatas.each do |data|
      @youyaku_thread << {"target_id" => data["target_id"] , "parent_id" => data["thread_id"] , "body" => data["body"]}
    end

  end

  def change_session_year
    puts "testyear"
    test = Treedata.new({user_id: params[:user_id], theme_id: params[:theme], out_flag: params[:flag]})
    test.save
  end

  def tree_log_get
    puts "test"
    test = TreeLog.new({user_id: params[:user_id],targer_id: params[:target], theme_id: params[:theme]})
    test.save
  end


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
    # @entries = Entry.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(10)
    @entries = Entry.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page])
    @facilitator = current_user.role == 'admin' || current_user.role == 'facilitator' if user_signed_in?
    @other_themes = Theme.others(@theme.id)
    @facilitations =  I18n.default_locale == :ja ? Facilitations : Facilitations_en
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
        format.html { redirect_to theme_path(params[:id]), notice: t('controllers.change_phase') }
        format.json { render action: 'show', status: :created, location: @theme }
      else
        format.html { render action: 'new' }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def search_entry
    @theme = Theme.includes(users: [:entries, :likes]).find(params[:search_entry][:theme_id])
    @stamps = stamp_list(params[:locale])
    @entry = Entry.new
    @issue = Issue.new
    @facilitations =  I18n.default_locale == :ja ? Facilitations : Facilitations_en
    @core_time = CoreTime.new

    @page = params[:page] || 1

    # if params[:search_entry][:order] == 'time'
    #   @entries = @theme.sort_by_new(params[:search_entry][:issues])
    # elsif params[:search_entry][:order] == 'popular'
    #   @entries = @theme.sort_by_reply(params[:search_entry][:issues])
    # elsif params[:search_entry][:order] == 'point'
    #   @entries = @theme.sort_by_points(params[:search_entry][:issues])
    # end
    @entries = @theme.sort_by_new(params[:search_entry][:issues])

    # @entries = Kaminari.paginate_array(@entries).page(params[:page]).per(10)
    @entries = Kaminari.paginate_array(@entries).page(params[:page])
    
    respond_to do |format|
      format.js
    end
  end

  # 小数点第2位以下を切り捨てるメソッド
  def cut_decimal_point(float)
    BigDecimal((float).to_s).floor(1).to_f
  end

  def change_text(tex)
    str = tex.gsub(/(\s)/,"")
    str = str.gsub(/《[^》]+》/, "")
    str = str.gsub(/　/, "  ")
    str = str.gsub('(', '（')
    str = str.gsub(')', '）')
    str = str.gsub('!', '！')
    str = str.gsub('&', '＆')
    str = str.gsub(/[\r\n]/,"")
    return str
  end

  # 投稿を反映する時の処理
  def create_entry
    @entry = Entry.new
    @new_entry = Entry.new(entry_params)
    @theme = Theme.find(params[:id])

    @stamps = stamp_list(params[:locale])


    @dynamicpoint = 0
    matching_bonus = 0    # キーワードとの一致ボーナス用

    nword_flag = 0
    nword_bonus = 0       # 新規単語ボーナス用

    reply_flag = 0
    reply_bonus = 0       # 返信時間ボーナス用

    time_flag = 0
    time_bonus = 0        # 投稿時間ボーナス用

    # 新規投稿についてスレッドか返信かを判定
    if entry_params["parent_id"].to_i > 0
      # 返信なら、素早い返信ならボーナスを与える
      puts "新規投稿の親スレは#{entry_params[:parent_id]}！！！"

      # 親投稿の投稿時間
      parentpost = Entry.where(id: entry_params[:parent_id]).last
      if parentpost != nil
        @parentpost_time = parentpost[:created_at]
      else
        @parentpost_time = -1
      end
      puts "親投稿の書き込み時間は#{@parentpost_time}です！！"

      if @parentpost_time != -1
        # 現在時刻
        @newpost_time = Time.now

        # 親投稿の投稿時間からの時間
        @sub_time = (@newpost_time - @parentpost_time).floor / 60
        puts "現在の時刻は#{@newpost_time}です！！最後の書き込みから#{@sub_time}分です！！"

        # 親投稿の投稿からxx分以内の返信ならボーナスフラグを立てる
        if @sub_time <= 30   # ここを変える
          reply_flag = 1
        end
      end
    else
      # スレッドなら，最後のスレ立てから時間が経っていればボーナスを与える
      puts "新規投稿はスレッド！！"

      # 最後に投稿されたスレッドの時間
      lastpost = Entry.where(theme_id: params[:id]).where.not(title: nil).reverse_order.last  #なぜか逆順になるので・・・要検証
      if lastpost != nil
        @lastpost_time = lastpost[:created_at]
      else
        @lastpost_time = -1
      end
      puts "最後の書き込みは#{@lastpost_time}です！！"

      if @lastpost_time != -1
        # 現在時刻
        @newpost_time = Time.now

        # 最後に投稿されたスレッドからの時間
        @sub_time = (@newpost_time - @lastpost_time).floor / 60
        puts "現在の時刻は#{@newpost_time}です！！最後の書き込みから#{@sub_time}分です！！"

        # 最後のスレ立てからxx分経っていればボーナスフラグを立てる
        if @sub_time >= 180   # ここを変える
          time_flag = 1
        end
      end
    end

    puts "返信ボーナス点はありますか？#{reply_flag}"
    if reply_flag == 1
      reply_bonus = 5
    end

    puts "投稿ボーナス点はありますか？#{time_flag}"
    if time_flag == 1
      time_bonus = 10
    end

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

    # print(get_nouns(text))

    # MeCabによる投稿内容の形態素解析
    # lib/bm25.rbのモジュールを使って形態素解析、単語抽出を行う
    # 同一の単語は1回のみカウント(.uniqにより、重複を許さない)
    if I18n.default_locale == :ja
      word = norm_connection2(text).uniq # 日本語の時はこっち
    else
      word = get_nouns(text) # 英語の時はこっち
    end
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

          # 一致度の計算
          matching_rate = word_len.to_f / keyword_len.to_f

          # キーワードのスコアが低すぎるときは底上げ
          if key[:score] < 0.1
            score = 0.1
          else
            score = key[:score]
          end

          # 投稿中の名詞に関するポイント
          matching_point = score * matching_coefficient * matching_rate
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

      # 新規単語投稿によるポイント付与
      if nword_flag == 1
        nword_bonus += nword_coefficient
        puts "「#{w}」は新規単語!! #{nword_coefficient}ポイント獲得!!"
      end

    end

    # 完全一致と部分一致を足した値を追加ポイントとする(小数点第2位以下は切り捨て)
    @dynamicpoint = cut_decimal_point(matching_bonus + nword_bonus + reply_bonus + time_bonus)

    # 投稿内容に応じたポイント付与をやめる場合の処理
    if false 
    # puts "テーマ番号は#{params[:id]}"
      if params[:id] == "4" # ここを適当に変える
        @dynamicpoint = 20
      end
    end 

    puts "----------------------------------------------------------"
    puts "獲得した追加ポイント = #{@dynamicpoint}!!"
    puts "----------------------------------------------------------"

    @facilitations =  I18n.default_locale == :ja ? Facilitations : Facilitations_en
    @count = @theme.entries.root.count

    respond_to do |format|
      if @new_entry.save

        #要約文の生成と保存
        #親の意見に対しては要約しない
        if @new_entry["parent_id"] != nil
          youyaku = Youyaku.new

          if I18n.default_locale == :ja

            #　日本語要約
            keywords = Keyword.where(:theme_id => @theme.id)
            entryies = Entry.where(:theme_id => @theme.id)

            s = ""
            parent_tex = change_text(search_id(@new_entry["parent_id"],entryies)["body"])
            midashi_tex = change_text(@new_entry["body"])
            s = midashi_tex+" "+parent_tex+" "

            keywords.each do |key|
              s = s + change_text(key["word"])+" "
              s = s + key["score"].to_s + " "
            end

            IO.popen("python #{Rails.root}/python/midashi/comment_manager.py #{s}").each do |line|
              p line
              youyaku = Youyaku.new(body: line, target_id: @new_entry["id"], theme_id: @theme.id)
            end

          else
            #  英語要約
            article = OTS.parse(@new_entry["body"])
            rate = 60 * 100 / @new_entry["body"].length
            youyaku = Youyaku.new(body: article.summarize(percent: rate)[0][:sentence], target_id: @new_entry["id"], theme_id: @theme.id)
          end

        else
          youyaku = Youyaku.new(body: nil, target_id: @new_entry["id"], theme_id: @theme.id)
        end

        youyaku.save
        # ここまで要約


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

  #タグの編集
  def add_entry_tag
    tags = Issue.checked(params[:issues])
    new_entry = Entry.find(params[:entry_id])
    new_entry.tagging!(Issue.to_object(tags))
    redirect_to theme_path(params[:theme_id])
  end

  def render_new
    @new_entry = Entry.find(params[:entry_id])
    @entry = Entry.new

    @theme = Theme.find(params[:id])
    @facilitations =  I18n.default_locale == :ja ? Facilitations : Facilitations_en

    respond_to do |format|
      format.js
    end
  end


  def new
    @theme = Theme.new
  end

  def edit
    set_theme
  end

  def create
    @theme = Theme.new(theme_params)

    respond_to do |format|
      if @theme.save
        Phase.create(:theme_id => @theme.id, :phase_id => 1)
        format.html { redirect_to @theme, notice: 'テーマを作成しました' }
        format.json { render action: 'show', status: :created, location: @theme }
      else
        format.html { render action: 'new' }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @theme = Theme.find(params[:id])
    respond_to do |format|
      if @theme.update(theme_params)
        format.html { redirect_to :root, notice: 'theme was successfully updated.' }
        format.json { render :root, status: :ok, location: @theme }
      else
        format.html { render :edit }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    set_theme
    @theme.destroy
    redirect_to :root, notice: 'Theme was successfully destroyed.' 
  end

  def change_secret
    set_theme
    if @theme.secret
      @theme.update(secret: false)
    else
      @theme.update(secret: true)
    end
    redirect_to users_path
  end

  #投票ページの表示
  def vote_entry
    @entry = Entry.new
    @entries = Entry.sort_time.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(50)
    @theme.nolink = true
    @entry_tree = Entry.where(:theme_id => @theme.id)
  end

  # 投票データの作成
  def vote_entry_create
    params["note"].each{|key, value|
      if value.to_i > 0
        VoteEntry.create(user_id: current_user.id, entry_id: key.to_i, point: value.to_i, theme_id: params[:theme_id]) 
      end
    }
    redirect_to theme_path(params[:theme_id]),notice: "投票が完了しました。"
  end

  # 投票データの作成
  def vote_entry_check
    params["entry"].each{|key, value|
        VoteEntry.create(user_id: current_user.id, entry_id: key.to_i, point: 0, theme_id: params[:theme_id], targer: true) 
    }
    redirect_to theme_path(params[:theme_id]),notice: "投票が完了しました。"
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

  # def user_point_ranking
  #   @ranking = @theme.point_ranking
  #   render 'user_point_ranking', formats: [:json], handlers: [:jbuilder]
  # end

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
    @theme = Theme.includes(users: [:entries, :likes]).find(params[:id])
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
    #@users_entry = @theme.joins.includes(:user).map(&:user).sort_by { |u| -u.entries.where(theme_id: @theme, facilitation: false).count }
    @user_ranking = @theme.point_ranking
    #@entry_like_ranking = @theme.like_ranking
    @user_ranking_before_0130 = @theme.point_ranking_before_0130
    @user_ranking_after_0130 = @theme.point_ranking_after_0130
  end

  def theme_params
    params.require(:theme).permit(:title, :body, :color, :admin_id, :image, :point_function, :secret, :body_text, :nolink, :start_at, :end_at, :group_id)
  end

  def entry_params
    params.require(:entry).permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation , :claster, :stamp)
  end

end
