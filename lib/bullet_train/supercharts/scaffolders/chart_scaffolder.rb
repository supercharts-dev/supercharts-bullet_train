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

          puts "This will scaffold a chart. Super!"
        end
      end
    end
  end
end
