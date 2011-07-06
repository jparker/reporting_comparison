require 'spec_helper'

describe WeeklyTriggerReport do
  it { should be_kind_of(TriggerReport) }

  context 'when reports exist' do
    before { Factory(:weekly_trigger_report) }

    it { should validate_uniqueness_of(:period).scoped_to(:type) }
  end
end
