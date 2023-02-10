require "scaffolding/supercharts_chart_transformer"
require "scaffolding/supercharts_routes_file_manipulator"

module BulletTrain
  module Supercharts
    module Scaffolders
      class ChartScaffolder < SuperScaffolding::Scaffolder
        def run
          unless argv.count >= 2
            puts ""
            puts "🚅  usage: bin/super-scaffold supercharts:chart <TargetModel> <ParentModel[s]>"
            puts ""
            puts "E.g. a chart on the team dashboard showing click-throughs per day"
            puts "This is assuming that you've already got a ClickThrough model, capturing each campaign click-through as a separate record. The chart will default to group by day derived by the :created_at"
            puts ""
            puts "  bin/super-scaffold supercharts:chart ClickThrough Team"
            puts ""
            standard_protip
            puts ""
            exit
          end

          target_model, parent_models = argv
          parent_models = parent_models.split(",")
          parent_models += ["Team"]
          parent_models = parent_models.map(&:classify).uniq

          transformer = Scaffolding::SuperchartsChartTransformer.new(target_model, parent_models)

          transformer.scaffold_supercharts
        end
      end
    end
  end
end
