class Scaffolding::SuperchartsTransformer < Scaffolding::Transformer
  def initialize(child, parents, cli_options = {})
    super(child, parents, cli_options)
  end

  def scaffold_supercharts
    # Update the routes to add the namespace and base resource
    routes_manipulator = Scaffolding::RoutesFileManipulator.new("config/routes.rb", transform_string("Scaffolding::CompletelyConcrete::TangibleThings"), transform_string("Scaffolding::AbsolutelyAbstract::CreativeConcept"))
    routes_manipulator.apply(["account"])
    Scaffolding::FileManipulator.write("config/routes.rb", routes_manipulator.lines)
  rescue BulletTrain::SuperScaffolding::CannotFindParentResourceException => exception
    # TODO It would be great if we could automatically generate whatever the structure of the route needs to be and
    # tell them where to try and inject it. Obviously we can't calculate the line number, otherwise the robots would
    # have already inserted the routes, but at least we can try to do some of the complicated work for them.
    add_additional_step :red, "We were not able to generate the routes for your Action Model automatically because: \"#{exception.message}\" You'll need to add them manually, which admittedly can be complicated. See https://blog.bullettrain.co/nested-namespaced-rails-routing-examples/ for guidance. 🙇🏻‍♂️"
  end
end
