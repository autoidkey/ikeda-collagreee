require 'natto'

class ThemesController < ApplicationController
  add_template_helper(ApplicationHelper)
  include ApplicationHelper

  protect_from_forgery except: :auto_facilitation_test
  before_action :set_theme, only: [:point_graph, :user_point_ranking, :check_new_message_2015_1]
  before_action :authenticate_user!, only: %i(create, new)
  before_action :set_theme, :set_keyword, :set_point, :set_activity, :set_ranking, only: [:show, :only_timeline]
  load_and_authorize_resource

  include Bm25
  require 'time'

  def index
    @themes = Theme.all
  end

  def show
    NoticeMailer.delay.facilitate_join_notice("title","test title","test body") # メールの送信

    if params[:nodeId] then
        @entries = Entry.sort_time.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(Entry.all.length)
        @nodeId = params[:nodeId]
    else
        @entries = Entry.sort_time.all.includes(:user).includes(:issues).in_theme(@theme.id).root.page(params[:page]).per(10)
        @nodeId = 0
    end
    


    @entry = Entry.new

    @search_entry = SearchEntry.new
    @issue = Issue.new

    @facilitator = current_user.role == 'admin' || current_user.role == 'facilitator' if user_signed_in?

    @other_themes = Theme.others(@theme.id)
    @facilitations = Facilitations

    @theme.join!(current_user) if user_join?
    current_user.delete_notice(@theme) if user_signed_in?
    @gravatar = gravatar_icon(current_user)

    # ウェブアクセスをカウントアップ
    # TODO:該当グループ以外のテーマを閲覧した時は除外する
    user_id = user_signed_in? ? current_user.id : nil
    Webview.count_up(user_id,@theme.id)

    render 'show_no_point' unless @theme.point_function

    #議論ツリーで使用する
    @entry_tree = Entry.where("theme_id >= ?", @theme.id)
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
    perfect_matching = 0  # 完全一致用
    partial_matching = 0  # 部分一致用
    
    nword_flag = 0
    nword_bonus = 0       # 新規単語用

    # DBからキーワードとスコアを抽出してハッシュに入れる
    keywords_scores = Keyword.where(user_id: nil, theme_id: params[:id]).map do |key| 
      {id: key.id, word: key.word, score: key.score}
    end

    # こっちはファシリテーターが手動で設定したキーワード用
    facilitation_keywords_scores = FacilitationKeyword.where(theme_id: params[:id]).map do |key| 
      {id: key.id, word: key.word, score: key.score}
    end

    # 書き込みの内容を取得
    text = entry_params["body"]

    # MeCabによる投稿内容の形態素解析 
    # lib/bm25.rbのモジュールを使って形態素解析、単語抽出を行う
    # 同一の単語は1回のみカウント(.uniqにより、重複を許さない)
    word = norm_connection2(text).uniq
    print "\n 抽出したワードは、#{word}です。\n"
    
    # 抽出したワードを1つずつ読み込んでいく
    word.each do |w|

      puts "読めてるよ:#{w}"   # デバッグ用

      # そのワードが新規ワードかを判定するフラグ
      nword_flag = 1

      # 通常のキーワードとの一致判定
      keywords_scores.each do |key|

        # 完全一致ならスコア*10pt
        if w == key[:word]
          perfect_bonus = key[:score] * 10
          perfect_matching += perfect_bonus
          puts "「#{w}」が「#{key[:word]}」と完全に一致!! #{perfect_bonus}ポイント獲得!!"
          nword_flag = 0
        # 部分一致ならスコア*5pt
        elsif key[:word].include?(w) 
          partial_bonus = key[:score] * 5
          partial_matching += partial_bonus
          puts "「#{w}」が「#{key[:word]}」と部分的に一致!! #{partial_bonus}ポイント獲得!!"
          nword_flag = 0
        end
      end

      # ファシリテーターによる手動キーワードとの一致判定
      facilitation_keywords_scores.each do |key|

        # 完全一致ならスコア*10pt
        if w == key[:word]
          perfect_bonus = key[:score] * 10
          perfect_matching += perfect_bonus
          puts "「#{w}」が「#{key[:word]}」と完全に一致!! #{perfect_bonus}ポイント獲得!!"
          nword_flag = 0
        # 部分一致ならスコア*5pt
        elsif key[:word].include?(w) 
          partial_bonus = key[:score] * 5
          partial_matching += partial_bonus
          puts "「#{w}」が「#{key[:word]}」と部分的に一致!! #{partial_bonus}ポイント獲得!!"
          nword_flag = 0
        end
      end

      # 新規単語投稿によるポイント付与(0.1pt)
      if nword_flag == 1
        nword_bonus += 0.1
        puts "「#{w}」は新規単語!! 0.1ポイント獲得!!"
      end

    end

    # 完全一致と部分一致を足した値を追加ポイントとする(小数点第2位以下は切り捨て)
    @dynamicpoint = cut_decimal_point(perfect_matching + partial_matching + nword_bonus)
    puts "獲得した追加ポイント = #{@dynamicpoint}"

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
    params.require(:theme).permit(:title, :body, :color, :admin_id, :image, :point_function, :nodeId)
  end

  def entry_params
    params.require(:entry).permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation)
  end
end
