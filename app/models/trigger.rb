class Trigger < ActiveRecord::Base
  validates :timestamp, presence: true
  validates :gross, :net, :commission, numericality: true
end
