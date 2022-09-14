require "scaffolding/supercharts_transformer"

class Scaffolding::SuperchartsChartTransformer < Scaffolding::SuperchartsTransformer
  def scaffold_supercharts
    super
    
    # copy files over and do the appropriate string replace.
    files = [
      "./app/controllers/account/scaffolding/completely_concrete/charts/tangible_things_controller.rb",
      "./app/views/account/scaffolding/completely_concrete/charts/tangible_things",
      "./app/views/shared/supercharts",
    ].compact
    
    files.each do |name|
      if File.directory?(resolve_template_path(name))
        scaffold_directory(name)
      else
        scaffold_file(name)
      end
    end
    
    # add children to the show page of their parent.
    unless cli_options["skip-parent"] || parent == "None"
      lines_to_add = <<~RUBY
        <div class="mt-4">
          <%= turbo_frame_tag :charts_tangible_things, src: polymorphic_path([:account, @creative_concept, :charts, :tangible_things], timespan: "1m") do %>
          <% end %>
        </div>
      RUBY
      scaffold_add_line_to_file(
        parent_show_file,
        lines_to_add,
        "<%# 🚅 super scaffolding will insert new children above this line. %>",
        prepend: true
      )
    end
    
    # apply routes.
    unless cli_options["skip-routes"]
      routes_namespace = cli_options["namespace"] || "account"
    
      begin
        routes_path = if routes_namespace == "account"
          "config/routes.rb"
        else
          "config/routes/#{routes_namespace}.rb"
        end
        routes_manipulator = Scaffolding::SuperchartsRoutesFileManipulator.new(routes_path, child, parent, cli_options)
      rescue Errno::ENOENT => _
        puts "Creating '#{routes_path}'.".green
    
        unless File.directory?("config/routes")
          FileUtils.mkdir_p("config/routes")
        end
    
        File.write(routes_path, <<~RUBY)
          collection_actions = [:index, :new, :create]
    
          # 🚅 Don't remove this block, it will break Super Scaffolding.
          begin do
            namespace :#{routes_namespace} do
              shallow do
                resources :teams do
                end
              end
            end
          end
        RUBY
    
        retry
      end
    
      begin
        routes_manipulator.apply([routes_namespace], prepend_namespace_to_child: "charts")
      rescue StandardError => e
        p e
        add_additional_step :yellow, "We weren't able to automatically add your `#{routes_namespace}` routes for you. In theory this should be very rare, so if you could reach out on Slack, you could probably provide context that will help us fix whatever the problem was. In the meantime, to add the routes manually, we've got a guide at https://blog.bullettrain.co/nested-namespaced-rails-routing-examples/ ."
      end
      
      Scaffolding::FileManipulator.write("config/routes.rb", routes_manipulator.lines)
    end
    
    restart_server unless ENV["CI"].present?
  end
  
  def parent_show_file
    @target_show_file ||= "./app/views/account/scaffolding/absolutely_abstract/creative_concepts/show.html.erb"
  end
  
  def transform_string(string)
    [
      "Scaffolding::CompletelyConcrete::Charts::TangibleThings",
      "scaffolding/completely_concrete/charts/tangible_things",
    ].each do |needle|
      # TODO There might be more to do here?
      # What method is this calling?
      string = string.gsub(needle, encode_double_replacement_fix(replacement_for(needle)))
    end
    
    string = super(string)
    decode_double_replacement_fix(string)
  end
  
  def replacement_for(string)
    case string
    when "Scaffolding::CompletelyConcrete::Charts::TangibleThings"
      "Charts::" + child.pluralize
    when "scaffolding/completely_concrete/charts/tangible_things"
      "charts/" + child.underscore.pluralize
    else
      "🛑"
    end
  end
end