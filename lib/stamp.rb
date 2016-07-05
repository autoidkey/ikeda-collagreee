module Stamp

  # public/stamps以下に存在する画像パスをArrayに
  def stamp_list(locale)
    if locale != 'en'
      stamp_path = "#{Rails.root}/public/images/stamps/"
    else
      stamp_path = "#{Rails.root}/public/images/en_stamps/"
    end

    lines = (Dir.glob(stamp_path + "*.jpg") +
            Dir.glob(stamp_path + "*.gif") +
            Dir.glob(stamp_path + "*.png")).map{
              |line| line.gsub("#{Rails.root}/public", "")
            }
  end

end
