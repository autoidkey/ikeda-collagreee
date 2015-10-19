module Stamp

  # public/stamps以下に存在する画像パスをArrayに
  def stamp_list
    stamp_path = "#{Rails.root}/public/images/stamps/"
    lines = (Dir.glob(stamp_path + "*.jpg") +
            Dir.glob(stamp_path + "*.gif") +
            Dir.glob(stamp_path + "*.png")).map{
              |line| line.gsub("#{Rails.root}/public", "")
            }
  end

end
