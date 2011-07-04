require 'spec_helper'

describe Callback do
  it { should validate_presence_of(:timestamp) }
  it { should validate_numericality_of(:gross) }
  it { should validate_numericality_of(:net) }
  it { should validate_numericality_of(:commission) }

  describe 'reporting' do
    before { Timecop.freeze(Time.utc(2011, 5, 23, 18, 0)) }
    after  { Timecop.return }

    describe 'on create' do
      before { Factory(:weekly_callback_report, period: Time.now.utc.beginning_of_week, gross: 110, net: 100, commission: 10) }

      it 'updates the weekly report' do
        Factory(:callback, timestamp: Time.now.utc, gross: 220, net: 200, commission: 20)
        report = WeeklyCallbackReport.find_by_period!(Time.now.utc.beginning_of_week)
        report.gross.should == 330
        report.net.should == 300
        report.commission.should == 30
      end

      context 'when no weekly report exists' do
        before { WeeklyCallbackReport.delete_all }

        it 'creates a weekly report' do
          Factory(:callback, timestamp: Time.now.utc, gross: 220, net: 200, commission: 20)
          report = WeeklyCallbackReport.find_by_period!(Time.now.utc.beginning_of_week)
          report.gross.should == 220
          report.net.should == 200
          report.commission.should == 20
        end
      end
    end

    describe 'on update' do
      before do
        Factory(:weekly_callback_report, period: 1.week.ago.beginning_of_week, gross: 110, net: 100, commission: 10)
        Factory(:weekly_callback_report, period: 1.week.from_now.beginning_of_week, gross: 220, net: 200, commission: 20)
        Factory(:callback, timestamp: 1.week.ago, gross: 440, net: 400, commission: 40)
      end

      context 'when the period changes' do
        it 'updates the weekly report for the old period' do
          Callback.first.update_attributes!(timestamp: 1.week.from_now, gross: 880, net: 800, commission: 80)
          report = WeeklyCallbackReport.find_by_period!(1.week.ago.beginning_of_week)
          report.gross.should == 110
          report.net.should == 100
          report.commission.should == 10
        end

        it 'updates the weekly report for the new period' do
          Callback.first.update_attributes!(timestamp: 1.week.from_now, gross: 880, net: 800, commission: 80)
          report = WeeklyCallbackReport.find_by_period!(1.week.from_now.beginning_of_week)
          report.gross.should == 1100
          report.net.should == 1000
          report.commission.should == 100
        end

        context 'when only one rate is changed' do
          it 'updates the weekly report for the old period' do
            Callback.first.update_attributes!(timestamp: 1.week.from_now, commission: 44)
            report = WeeklyCallbackReport.find_by_period!(1.week.ago.beginning_of_week)
            report.gross.should == 110
            report.net.should == 100
            report.commission.should == 10
          end

          it 'updates the weekly report for the new period' do
            Callback.first.update_attributes!(timestamp: 1.week.from_now, commission: 44)
            report = WeeklyCallbackReport.find_by_period!(1.week.from_now.beginning_of_week)
            report.gross.should == 660
            report.net.should == 600
            report.commission.should == 64
          end
        end

        context 'when no weekly report exists for the old period' do
          before { WeeklyCallbackReport.delete_all(period: 1.week.ago.beginning_of_week) }

          it 'does not create an old weekly report' do
            Callback.first.update_attributes!(timestamp: 1.week.from_now, gross: 880, net: 800, commission: 80)
            report = WeeklyCallbackReport.find_by_period(1.week.ago.beginning_of_week)
            report.should be_nil
          end
        end

        context 'when no weekly report exists for the new period' do
          before { WeeklyCallbackReport.delete_all(period: 1.week.from_now.beginning_of_week) }

          it 'creates a weekly report' do
            Callback.first.update_attributes!(timestamp: 1.week.from_now, gross: 880, net: 800, commission: 80)
            report = WeeklyCallbackReport.find_by_period!(1.week.from_now.beginning_of_week)
            report.gross.should == 880
            report.net.should == 800
            report.commission.should == 80
          end
        end
      end

      context 'when the period is unchanged' do
        it 'updates the weekly report' do
          Callback.first.update_attributes!(gross: 880, net: 800, commission: 80)
          report = WeeklyCallbackReport.find_by_period!(1.week.ago.beginning_of_week)
          report.gross.should == 990
          report.net.should == 900
          report.commission.should == 90
        end

        context 'when no weekly report exists' do
          before { WeeklyCallbackReport.delete_all }

          it 'creates a weekly report' do
            Callback.first.update_attributes!(gross: 880, net: 800, commission: 80)
            report = WeeklyCallbackReport.find_by_period!(1.week.ago.beginning_of_week)
            report.gross.should == 880
            report.net.should == 800
            report.commission.should == 80
          end
        end
      end

      context 'when only one rate is changed' do
        it 'updates the one rate in the weekly report and leaves the others unchanged' do
          Callback.first.update_attributes!(commission: 44)
          report = WeeklyCallbackReport.find_by_period!(1.week.ago.beginning_of_week)
          report.gross.should == 550
          report.net.should == 500
          report.commission.should == 54
        end
      end

      context 'when the period and rates are unchanged' do
        it 'does not change the weekly report' do
          Callback.first.update_attributes!(updated_at: 1.week.from_now)
          report = WeeklyCallbackReport.find_by_period!(1.week.ago.beginning_of_week)
          report.gross.should == 550
          report.net.should == 500
          report.commission.should == 50
        end

        context 'when no weekly report exists' do
          before { WeeklyCallbackReport.delete_all }

          it 'creates a weekly report' do
            Callback.first.update_attributes!(updated_at: 1.week.from_now)
            report = WeeklyCallbackReport.find_by_period!(1.week.ago.beginning_of_week)
            report.gross.should == 440
            report.net.should == 400
            report.commission.should == 40
          end
        end
      end
    end

    describe 'on destroy' do
      before do
        Factory(:weekly_callback_report, period: Time.now.utc.beginning_of_week, gross: 110, net: 100, commission: 10)
        Factory(:callback, timestamp: Time.now.utc, gross: 220, net: 200, commission: 20)
      end

      it 'updates the weekly report' do
        Callback.first.destroy
        report = WeeklyCallbackReport.find_by_period!(Time.now.utc.beginning_of_week)
        report.gross.should == 110
        report.net.should == 100
        report.commission.should == 10
      end

      context 'when no weekly report exists' do
        before { WeeklyCallbackReport.delete_all }

        it 'does not create a weekly report' do
          Callback.first.destroy
          report = WeeklyCallbackReport.find_by_period(Time.now.utc.beginning_of_week)
          report.should be_nil
        end
      end
    end
  end
end
