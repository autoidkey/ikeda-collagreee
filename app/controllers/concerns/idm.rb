module idm

  @idm_result = []
  @idm_link = 0
  @idm_n = 0
  @idm_F = []
  @idm_K = []

  def new_idm()
    logger.info @idm_result
    logger.info @idm_F

    count = 0
   for num1 in 0..@idm_result.length-1 do
      #頻度を探す fに入れておく！！
      f = 0
      for num2 in 0..@idm_F.length-1 do
        if @idm_result[num1][0] == @idm_F[num2][0]
          f = @idm_F[num2][1]
          break
        end
      end

      #期待値を計算する eに入れておく
      e = 0
      if f != 1
        e = 0.0
        logger.info f
        logger.info "ss"
        for num in 2..f do
          logger.info num
          e = e + (num-1)*((f.quo(@idm_n))*(@idm_link.quo(@idm_n-1)))**(num-1)
        end
      end
      logger.info "eノ答えaaaaaaaaaaa"
      logger.info e
      logger.info f
      logger.info @idm_result[num1][1]

      #乖離度を計算する kとする
      k = 0.0

      k = ((@idm_result[num1][1] - e)**2).quo(e)

      @idm_K[count] = [@idm_result[num1][0],k.round(4),e]
      count = count + 1
    end

    return @idm_K

  end

  def idm
    entry_all = Entry.all.where(:theme_id => params[:id])
    word_array = []
    # { :name => "k-sato", :email => "k-sato@foo.xx.jp",:address => "Tokyo" }
    entry_all.each do |entry|
      if search_child(entry["id"]).length != 0
        if entry["title"] != nil
          title = norm_connection2(entry["title"]).uniq
          body = norm_connection2(entry["body"]).uniq
          words = title + body
          logger.info title + body
          com_idm([],entry["id"])

          #リンク数を計算する
          
        # else
        #   body = norm_connection2(entry["body"]).uniq
        #   logger.info body
        end
      end
    end
    return nil
    
  end

  def com_idm(word_array, id)
    @idm_n = @idm_n + 1
    entry = search_id(id)
    words = norm_connection2(entry["body"]).uniq
    idm_f(words)
    children = search_child(id)
    logger.info "チェックするワード配列"
    logger.info word_array
    logger.info words

    word_array.each do |word|
      if words.include?(word) && word.length>1
        num = words.count(word)
        # ここで計算して結果の配列を成形する
        idm_result(word)
        words.push(word)
      end
    end
    
    logger.info "次に渡すワードのわい列"
    logger.info words
    
    if children.length != 0
      children.each do |child|
        @idm_link = @idm_link + 1
        com_idm(words,child)
      end
    end
  end

  def idm_f(words)
    words.each do |word|
      flag = 0
      count = 0
      for f in @idm_F do
        if f[0] == word
          @idm_F[count][1] = @idm_F[count][1] + 1
          flag = 1
          break
        end
        count = count + 1
      end
      if flag == 0
        @idm_F.push([word,1])
      end
    end
  end

  def idm_result(word)
    #result配列に追加するwordがを登録されているか[["蠣久",2],["ピンク",4]]
    flag = 0
    count = 0
    for result in @idm_result do
      if result[0]==word
        @idm_result[count][1] = @idm_result[count][1] + 1
        flag = 1
        break
      end
      count = count + 1
    end
    if flag == 0
      @idm_result.push([word,1])
    end
  end



  def search_child(id)
    entry_all = Entry.all.where(:theme_id => params[:id])
    child_id = []
    entry_all.each do |entry|
      if entry["parent_id"] == id
        child_id.push(entry["id"])
      end
    end
    return child_id
  end

  def search_id(id)
    entry_all = Entry.all.where(:theme_id => params[:id])
    entry_all.each do |entry|
      if entry["id"] == id
        return entry
      end
    end
    return nil
  end

end