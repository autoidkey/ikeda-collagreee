require 'clockwork'
require File.expand_path('../../../config/boot', __FILE__)
require File.expand_path('../../../config/environment', __FILE__)


require_relative 'youyaku_job'
require_relative 'keyword_job'
require_relative 'user_keyword_job'
require_relative 'point_job'
require_relative 'entry_point_job'
require_relative 'aichi_dl_job'

module Clockwork
  handler do |job|
    puts "====== #{job.class} start ======="
    job.execute
    puts "====== #{job.class} finish ======="
  end

  every(15.hours, YouyakuJob.new)
  every(5.minute, KeywordJob.new)
  every(5.minute, UserKeywordJob.new)
  every(5.minute, PointJob.new)
  every(5.minute, EntryPointJob.new)
  every(5.minute, AichiDlJob.new)
end
