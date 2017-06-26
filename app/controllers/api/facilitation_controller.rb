module Api
  class FacilitationController < ApplicationController
    require 'csv'
    require 'spreadsheet'

    def reload_graph
      @hashmap = {"row" => User.maximum(:row), "col" => User.maximum(:col), "noroom" => [[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[1,8],[1,9],[2,2],[2,3],[2,4],[2,5],[2,6],[2,7],[2,8],[2,9],[3,2],[3,3],[3,4],[3,5],[3,6],[3,7],[3,8],[3,9],[4,2],[4,3],[4,4],[4,5],[4,6],[4,7],[4,8],[4,9]]}
      @row = []
      @col = []
      for c in 1..@hashmap["col"]
        @col.push(c)
      end
      for r in 1..@hashmap["row"]
        @row.push(r)
      end
      CSV.open("public/log/entries.tsv", "w", :col_sep => "\t") do |io|
        io.puts(["day","hour","value","username"]) # 見出し
        for c in 1..@hashmap["col"]
          for r in 1..@hashmap["row"]
            if User.exists?(:col => c, :row => r)
              user = User.where(:col => c, :row => r)[0]
              ran = rand(3) + r/3 + c%10 #とりあえず user.entries.count
              io.puts([c, r, ran, user.name])
            end
          end
        end
      end
      render json: "success"
    end

  end
end