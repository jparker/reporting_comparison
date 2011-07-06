class CreateTriggers < ActiveRecord::Migration
  def self.up
    create_table :triggers do |t|
      t.datetime :timestamp, null: false
      t.decimal :net, null: false, precision: 10, scale: 2, default: 0
      t.decimal :gross, null: false, precision: 10, scale: 2, default: 0
      t.decimal :commission, null: false, precision: 10, scale: 2, default: 0

      t.timestamps
    end
    add_index :triggers, :timestamp
  end

  def self.down
    drop_table :triggers
  end
end
