class CreateCallbacks < ActiveRecord::Migration
  def self.up
    create_table :callbacks do |t|
      t.datetime :timestamp, null: false
      t.decimal :net, null: false, precision: 10, scale: 2, default: 0
      t.decimal :gross, null: false, precision: 10, scale: 2, default: 0
      t.decimal :commission, null: false, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end

  def self.down
    drop_table :callbacks
  end
end
