class CallbackReport < ActiveRecord::Base
  validates_uniqueness_of :period, scope: :type
end
