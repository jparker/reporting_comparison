Factory.define(:trigger) do |f|
  f.timestamp { Time.now }
  f.gross { rand(10_000) }
  f.net { |t| t.gross * 0.9 }
  f.commission { |t| t.gross * 0.1 }
end
