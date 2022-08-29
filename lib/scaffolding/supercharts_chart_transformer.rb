require "scaffolding/supercharts_transformer"

class Scaffolding::SuperchartsChartTransformer < Scaffolding::SuperchartsTransformer
  def scaffold_chart
    puts "scaffold_chart: This will scaffold a #{child} chart on a #{parents.join(' dashboard of a ')}. Super!"
  end
end