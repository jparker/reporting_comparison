class CreateTriggerReportTriggers < ActiveRecord::Migration
  def self.up
    report_type = 'WeeklyTriggerReport'
    execute <<-SQL.squish
      CREATE OR REPLACE FUNCTION insert_into_report() RETURNS trigger AS $$
        DECLARE
          date TIMESTAMP WITHOUT TIME ZONE;
        BEGIN
          date = date_trunc('week', NEW.timestamp);
          LOOP
            UPDATE trigger_reports SET
              net = net+NEW.net,
              gross = gross+NEW.gross,
              commission = commission+NEW.commission
            WHERE type = '#{report_type}' AND period = date;
            EXIT WHEN found;
            INSERT INTO trigger_reports (type, period, net, gross, commission)
              VALUES('#{report_type}', date, NEW.net, NEW.gross, NEW.commission);
            EXIT;
          END LOOP;
          RETURN NULL;
        END;
      $$ LANGUAGE plpgsql;
    SQL
    execute <<-SQL.squish
      CREATE TRIGGER insert_into_report AFTER INSERT ON triggers FOR EACH ROW EXECUTE PROCEDURE insert_into_report();
    SQL

    execute <<-SQL.squish
      CREATE OR REPLACE FUNCTION update_in_report() RETURNS trigger AS $$
        DECLARE
          old_date TIMESTAMP WITHOUT TIME ZONE;
          new_date TIMESTAMP WITHOUT TIME ZONE;
        BEGIN
          old_date = date_trunc('week', OLD.timestamp);
          new_date = date_trunc('week', NEW.timestamp);
          LOOP
            IF (old_date != new_date) THEN
              UPDATE trigger_reports SET
                net = net-OLD.net,
                gross = gross-OLD.gross,
                commission = commission-OLD.commission
              WHERE type = '#{report_type}' AND period = old_date;
              UPDATE trigger_reports SET
                net = net+NEW.net,
                gross = gross+NEW.gross,
                commission = commission+NEW.commission
              WHERE type = '#{report_type}' AND period = new_date;
            ELSE
              UPDATE trigger_reports SET
                net = net-OLD.net+NEW.net,
                gross = gross-OLD.gross+NEW.gross,
                commission = commission-OLD.commission+NEW.commission
              WHERE type = '#{report_type}' AND period = new_date;
            END IF;
            EXIT WHEN found;
            INSERT INTO trigger_reports (type, period, net, gross, commission)
              VALUES('#{report_type}', new_date, NEW.net, NEW.gross, NEW.commission);
            EXIT;
          END LOOP;
          RETURN NULL;
        END;
      $$ LANGUAGE plpgsql;
    SQL
    execute <<-SQL.squish
      CREATE TRIGGER update_in_report AFTER UPDATE ON triggers FOR EACH ROW EXECUTE PROCEDURE update_in_report();
    SQL

    execute <<-SQL.squish
      CREATE OR REPLACE FUNCTION delete_from_report() RETURNS trigger AS $$
        DECLARE
          date TIMESTAMP WITHOUT TIME ZONE;
        BEGIN
          date = date_trunc('week', OLD.timestamp);
          UPDATE trigger_reports SET
            net = net-OLD.net,
            gross = gross-OLD.gross,
            commission = commission-OLD.commission
          WHERE type = '#{report_type}' AND period = date;
          RETURN NULL;
        END;
      $$ LANGUAGE plpgsql;
    SQL
    execute <<-SQL.squish
      CREATE TRIGGER delete_from_report AFTER DELETE ON triggers FOR EACH ROW EXECUTE PROCEDURE delete_from_report();
    SQL
  end

  def self.down
    execute "DROP TRIGGER delete_from_report ON triggers"
    execute "DROP FUNCTION delete_from_report()"
    execute "DROP TRIGGER update_in_report ON triggers"
    execute "DROP FUNCTION update_in_report()"
    execute "DROP TRIGGER insert_into_report ON triggers"
    execute "DROP FUNCTION insert_into_report()"
  end
end
