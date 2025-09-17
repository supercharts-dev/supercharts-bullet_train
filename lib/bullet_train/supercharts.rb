# Issue deprecation warning when this gem is loaded
unless defined?(BulletTrain::Supercharts::DEPRECATION_WARNING_SHOWN)
  warn "⚠️  DEPRECATION WARNING: The supercharts-bullet_train gem is deprecated. Please eject the files locally using `bin/rails supercharts:eject_all`. See README for details."
end

require "bullet_train/supercharts/version"
require "bullet_train/supercharts/engine"
require "scaffolding"
require "scaffolding/transformer"
require "scaffolding/block_manipulator"
require "scaffolding/routes_file_manipulator"
require "bullet_train/supercharts/scaffolders/chart_scaffolder"

module BulletTrain
  module Supercharts
    # Mark that the deprecation warning has been shown
    DEPRECATION_WARNING_SHOWN = true
    # Your code goes here...
  end
end
