class CommentsController < ApplicationController
  def index
    a = '今日はいい天気'
    nm = Natto::MeCab.new

    nm.parse(a) do |x|
      puts x
    end
  end

  def show
  end

  def create

  end
end
