require 'csv'

class Account::Scaffolding::CompletelyConcrete::TangibleThings::TangibleThingsChartController < Account::ApplicationController
  include ActionView::Helpers::NumberHelper
  account_load_and_authorize_resource :tangible_thing, through: :absolutely_abstract_creative_concept, through_association: :completely_concrete_tangible_things, collection_actions: [:show]

  # GET /account/scaffolding/absolutely_abstract/creative_concepts/:absolutely_abstract_creative_concept_id/completely_concrete/tangible_things/chart
  def show
    @tangible_things = @absolutely_abstract_creative_concept.completely_concrete_tangible_things
    
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
      series = @tangible_things.group_by_period(@period, :created_at, range: range, expand_range: true)
    when "1w"
      range = (1.weeks.ago.beginning_of_day)..Time.now
      @period = :day
      series = @tangible_things.group_by_period(@period, :created_at, range: range, expand_range: true)
    else
      range = (1.month.ago + 1.day).beginning_of_day..Time.now
      @period = :day
      series = @tangible_things.group_by_period(@period, :created_at, range: range)
    end
    
    counts = series.count
    @total = counts.values.reduce(:+)
    
    date_format_abbr = if @period == :day
      "%e"
    elsif @period == :week
      "Week of %b %e"
    elsif @period == :month
      "%b"
    end
    
    date_format_full = if @period == :day
      "%B %e"
    elsif @period == :week
      "week of %B %e"
    elsif @period == :month
      "%B, %Y"
    end
    
    @csv = CSV.generate(" ", headers: %w[date_abbr date_full count count_formatted], write_headers: true, encoding: "UTF-8") do |csv|
      counts.each do |date, count|
        csv.add_row [date.strftime(date_format_abbr), date.strftime(date_format_full), count, number_with_delimiter(count)]
      end
    end
  end
end
