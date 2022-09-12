module BulletTrain
  module Supercharts
    class Engine < ::Rails::Engine
      initializer "bullet_train.super_scaffolding.templates.register_template_path" do |app|
        # Register the base path of this package with the Super Scaffolding engine.
        BulletTrain::SuperScaffolding.template_paths << File.expand_path('../../../..', __FILE__)
        BulletTrain::SuperScaffolding.scaffolders.merge!({
          "supercharts:chart" => "BulletTrain::Supercharts::Scaffolders::ChartScaffolder",
        })
      end
    end
  end
end
