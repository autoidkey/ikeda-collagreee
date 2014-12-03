require 'clockwork'
require File.expand_path('../../../config/boot', __FILE__)
require File.expand_path('../../../config/environment', __FILE__)

require_relative 'keyword_job'
require_relative 'user_keyword_job'
require_relative 'point_job'

module Clockwork
  handler do |job|
    puts "====== #{job.class} start ======="
    job.execute
    puts "====== #{job.class} finish ======="
  end

  # every(5.minute, KeywordJob.new)
  # every(5.minute, UserKeywordJob.new)
  every(1.minute, PointJob.new)
end
