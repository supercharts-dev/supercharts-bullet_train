require 'csv'

class Account::Scaffolding::CompletelyConcrete::Charts::TangibleThingsController < Account::ApplicationController
  account_load_and_authorize_resource :tangible_thing, through: :absolutely_abstract_creative_concept, through_association: :completely_concrete_tangible_things

  # GET /account/scaffolding/absolutely_abstract/creative_concepts/:absolutely_abstract_creative_concept_id/completely_concrete/charts/tangible_things
  def index
    @timespan = params[:timespan]
    case @timespan
    when "ytd"
      range = Time.now.beginning_of_year..Time.now
      range_days = (range.max - range.min).seconds.in_days
      if range_days > 4.months.in_days
        @period = :month
      elsif range_days > 1.month.in_days
        @period = :week
      else
        @period = :day
      end
      data = @tangible_things.group_by_period(@period, :created_at, range: range, expand_range: true).count
    else
      @period = :day
      data = @tangible_things.group_by_period(@period, :created_at, last: 30).count
    end
    
    @total = data.values.reduce(:+)
    
    date_format = if @period == :day
      "%e"
    elsif @period == :week
      "%b %e"
    elsif @period == :month
      "%b"
    end
    
    @csv = CSV.generate(" ", headers: %w[date value], write_headers: true, encoding: "UTF-8") do |csv|
      data.each do |date, value|
        csv.add_row [date.strftime(date_format), value]
      end
    end
  end
end
