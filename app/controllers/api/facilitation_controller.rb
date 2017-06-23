module Api
  class FacilitationController < ApplicationController
    require 'csv'
    require 'spreadsheet'

    def reload_graph
      # row = 24
      # @row = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
      # @col = [1,2,3,4,5,6]
      # CSV.open("public/log/entries.tsv", "w", :col_sep => "\t") do |io|
      #   io.puts(["day","hour","value"]) # 見出し
      #   User.all.each_with_index do |u, i|
      #     a = i / row + 1
      #   b = i % row + 1
      #   c = u.entries.count
      #     io.puts([a,b,c])
      #   end
      # end

      # render json: "success"

    end

  end
end