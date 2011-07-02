require 'spec_helper'

describe WeeklyCallbackReport do
  it { should be_kind_of(CallbackReport) }

  context 'when reports exist' do
    before { Factory(:weekly_callback_report) }

    it { should validate_uniqueness_of(:period).scoped_to(:type) }
  end
end
