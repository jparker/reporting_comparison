class CreateTriggerReports < ActiveRecord::Migration
  def self.up
    create_table :trigger_reports do |t|
      t.string :type, null: false
      t.datetime :period, null: false
      t.decimal :gross, null: false, precision: 12, scale: 2, default: 0
      t.decimal :net, null: false, precision: 12, scale: 2, default: 0
      t.decimal :commission, null: false, precision: 12, scale: 2, default: 0
    end
    add_index :trigger_reports, [:type, :period], unique: true
  end

  def self.down
    drop_table :trigger_reports
  end
end
