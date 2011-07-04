class Callback < ActiveRecord::Base
  validates :timestamp, presence: true
  validates :gross, :net, :commission, numericality: true

  after_create :insert_into_report
  after_update :update_in_report
  after_destroy :delete_from_report

  private
  def insert_into_report
    period = timestamp.beginning_of_week
    found = WeeklyCallbackReport.update_all(['net=net+?, gross=gross+?, commission=commission+?', net, gross, commission],
                                            {period: period})
    WeeklyCallbackReport.create!(period: period, gross: gross, net: net, commission: commission) if found.zero?
  end

  def update_in_report
    old_period, new_period = period_change(:week)
    found = if period_changed?(:week)
              WeeklyCallbackReport.update_all(['net=net-?, gross=gross-?, commission=commission-?', *old_rates],
                                              {period: old_period})
              WeeklyCallbackReport.update_all(['net=net+?, gross=gross+?, commission=commission+?', *new_rates],
                                              {period: new_period})
            elsif rate_changed?
              WeeklyCallbackReport.update_all(rate_change, {period: new_period})
            else
              WeeklyCallbackReport.where(period: new_period).count
            end
    WeeklyCallbackReport.create!(period: new_period, gross: gross, net: net, commission: commission) if found.zero?
  end

  def delete_from_report
    period = timestamp.beginning_of_week
    WeeklyCallbackReport.update_all(['net=net-?, gross=gross-?, commission=commission-?', net, gross, commission],
                                    {period: period})
  end

  def rate_changed?
    net_changed? || gross_changed? || commission_changed?
  end

  def rate_change
    clause, parameters = [], []
    %w(net gross commission).each do |rate|
      if send("#{rate}_changed?")
        clause << "#{rate}=#{rate}-?+?"
        parameters << send("#{rate}_change")
      end
    end
    [clause.join(', '), *parameters.flatten]
  end

  def old_rates
    [:net, :gross, :commission].inject([]) {|a,r| a << (send("#{r}_changed?") ? send("#{r}_change").first : send(r))}
  end

  def new_rates
    [:net, :gross, :commission].inject([]) {|a,r| a << (send("#{r}_changed?") ? send("#{r}_change").last : send(r))}
  end

  def period_changed?(granularity)
    truncator = "beginning_of_#{granularity}"
    timestamp_changed? && timestamp_change.first.send(truncator) != timestamp_change.last.send(truncator)
  end

  def period_change(granularity)
    if timestamp_changed?
      timestamp_change.map(&:"beginning_of_#{granularity}")
    else
      [timestamp.send("beginning_of_#{granularity}")] * 2
    end
  end
end
