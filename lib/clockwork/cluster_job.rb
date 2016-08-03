# theme内のエントリーに出現する単語のtfidf
class ClusterJob
  include Bm25

  def execute
    # スレッドのクラスタリングも実行
    EntryClaster.destroy_all
    idAll = Theme.all
    idAll.each do |id|
      themes_claster = test_func(id)
      themes_claster.each do |clas|
         params = {
           entry_id: clas[:id],
           coaster: clas[:cla],
         }
         EntryClaster.new(params).save
       end
    end

    # 英語版のクラスタリング
    # Theme.all.each do |theme|
    #   clustering_en(theme.id)
    # end

  end
end
