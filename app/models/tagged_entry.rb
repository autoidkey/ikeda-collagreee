class TaggedEntry < ActiveRecord::Base
  belongs_to :issue
  belongs_to :entry
end
