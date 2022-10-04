require "scaffolding/supercharts_transformer"

class Scaffolding::SuperchartsChartTransformer < Scaffolding::SuperchartsTransformer
  def scaffold_supercharts
    super
    
    # copy files over and do the appropriate string replace.
    files = [
      "./app/controllers/account/scaffolding/completely_concrete/tangible_things/tangible_things_chart_controller.rb",
      "./app/views/account/scaffolding/completely_concrete/tangible_things/tangible_things_chart",
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
        <div class="mt-4 [--chart-height:250px] md:[--chart-height:200px]">
          <%= turbo_frame_tag :charts_tangible_things, src: polymorphic_path([:account, @creative_concept, :tangible_things, :chart], timespan: "1m") do %>
            <%= render "shared/supercharts/chart_skeleton" do %>
              Tangible Things&hellip;
            <% end %>
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
    
    # add user permissions.
    add_ability_line_to_roles_yml
    
    # apply routes.
    # TODO this is a hack and should be in its own RouteFileManipulator class
    lines = File.read("config/routes.rb").lines.map(&:chomp)
    account_namespace_found = false
    
    lines.each_with_index do |line, index|
      if line.match?("namespace :account do")
        account_namespace_found = true
      elsif account_namespace_found && line.match?(transform_string("resources :tangible_things"))
        chart_resource_lines = transform_string("collection do\nresource :chart, only: :show, module: :tangible_things, as: :tangible_things_chart, controller: :tangible_things_chart\nend")
        if line.match? /do$/
          lines[index] = "#{line}\n#{chart_resource_lines}\n"
        else
          lines[index] = "#{line} do\n#{chart_resource_lines}\nend"
        end
      end
    end
    
    File.write("config/routes.rb", lines.join("\n"))
    
    puts `standardrb --fix ./config/routes.rb`
    
    restart_server unless ENV["CI"].present?
  end
  
  def parent_show_file
    @target_show_file ||= "./app/views/account/scaffolding/absolutely_abstract/creative_concepts/show.html.erb"
  end
  
  def transform_string(string)
    [
      "Scaffolding::CompletelyConcrete::TangibleThings::TangibleThingsChart",
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
    when "Scaffolding::CompletelyConcrete::TangibleThings::TangibleThingsChart"
      child.pluralize + "::" + child.pluralize + "Chart"
    else
      "🛑"
    end
  end
end