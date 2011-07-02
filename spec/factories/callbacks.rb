Factory.define(:callback) do |f|
  f.timestamp { Time.now }
  f.gross { rand(10_000) }
  f.net { |c| c.gross * 0.9 }
  f.commission { |c| c.gross * 0.1 }
end
