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
    if period_changed?(:week)
      periods = period_change(:week)
      WeeklyCallbackReport.update_all(['net=net-?, gross=gross-?, commission=commission-?', *rate_changes.first],
                                      {period: periods.first})
      found = WeeklyCallbackReport.update_all(['net=net+?, gross=gross+?, commission=commission+?', *rate_changes.last],
                                              {period: periods.last})
      WeeklyCallbackReport.create!(period: periods.last, gross: gross, net: net, commission: commission) if found.zero?
    elsif rate_changed?
      period = timestamp.beginning_of_week
      found = WeeklyCallbackReport.update_all(rate_change, {period: period})
      WeeklyCallbackReport.create!(period: period, gross: gross, net: net, commission: commission) if found.zero?
    elsif !WeeklyCallbackReport.find_by_period(timestamp.beginning_of_week)
      WeeklyCallbackReport.create!(period: timestamp.beginning_of_week, gross: gross, net: net, commission: commission)
    end
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

  def rate_changes
    net_change.zip(gross_change, commission_change)
  end

  def period_changed?(granularity)
    truncator = "beginning_of_#{granularity}"
    timestamp_changed? && timestamp_change.first.send(truncator) != timestamp_change.last.send(truncator)
  end

  def period_change(granularity)
    if period_changed?(granularity)
      timestamp_change.map(&:"beginning_of_#{granularity}")
    end
  end
end
