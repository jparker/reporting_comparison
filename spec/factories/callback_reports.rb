Factory.define(:callback_report) do |f|
  # This is an "abstract" factory in so far as it can not actually create valid
  # records - the :type and :period columns are only set by the child factories.
  f.gross { rand(1_000_000) }
  f.net { |r| r.gross * 0.9 }
  f.commission { |r| r.gross * 0.1 }
end

Factory.define(:weekly_callback_report, :parent => :callback_report) do |f|
  f.type 'WeeklyCallbackReport'
  f.sequence(:period) { |n| n.weeks.from_now.beginning_of_week }
end
