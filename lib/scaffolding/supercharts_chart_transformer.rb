require "scaffolding/supercharts_transformer"

class Scaffolding::SuperchartsChartTransformer < Scaffolding::SuperchartsTransformer
  RUBY_NEW_CHARTS_HOOK = "# 📈 super scaffolding will insert new charts above this line."

  def scaffold_supercharts
    super

    # copy files over and do the appropriate string replace.
    files = [
      "./lib/scaffolding/app/controllers/account/scaffolding/completely_concrete/tangible_things/tangible_things_chart_controller.rb",
      "./app/views/account/scaffolding/completely_concrete/tangible_things/tangible_things_chart",
      "./app/views/shared/supercharts"
    ].compact

    files.each do |name|
      if File.directory?(resolve_template_path(name))
        scaffold_directory(name)
      else
        scaffold_file(name)
      end
    end

    # locale
    locale_file = "./config/locales/en/scaffolding/completely_concrete/tangible_things.en.yml"

    # add locale file if missing
    unless File.file?(transform_string(locale_file))
      scaffold_file(locale_file)
      add_locale_helper_export_fix
    end

    # add locale strings for chart
    scaffold_add_line_to_file(locale_file, RUBY_NEW_CHARTS_HOOK, "  account:", prepend: true, increase_indent: true, exact_match: true)
    # ensure the right indentation
    scaffold_replace_line_in_file(locale_file, "    #{RUBY_NEW_CHARTS_HOOK}", "  #{RUBY_NEW_CHARTS_HOOK}")

    locale_yaml = <<~YAML
      chart:
        filters:
          1w: 
            abbr: 1w
            label: "last week"
          1m:
            abbr: 1m
            label: "last month"
          ytd:
            abbr: ytd
            label: "year to date"
        description:
          1w: Tangible Things last 7 days
          1m: Tangible Things last month
          ytd: Tangible Things since start of year
        contextual_description:
          1w: Tangible Things on <span class="whitespace-nowrap">%label%</span>
          1m: Tangible Things in <span class="whitespace-nowrap">%label%</span>
          ytd: Tangible Things in <span class="whitespace-nowrap">%label%</span>
        alt_description:
          1w: Chart of Tangible Things last 7 days
          1m: Chart of Tangible Things last month
          ytd: Chart of Tangible Things since start of year
        date_abbr:
          day: "%e"
          week: "Week of %b %e"
          month: "%b"
        date_full:
          day: "%B %e"
          week: "week of %B %e"
          month: "%B, %Y"
    YAML

    scaffold_add_line_to_file("./config/locales/en/scaffolding/completely_concrete/tangible_things.en.yml", locale_yaml, RUBY_NEW_CHARTS_HOOK, prepend: true)

    # add children to the show page of their parent.
    unless cli_options["skip-parent"] || parent == "None"
      lines_to_add = <<~RUBY
        <div class="mt-4 [--chart-height:150px] md:[--chart-height:200px]">
          <%= turbo_frame_tag :charts_tangible_things, src: polymorphic_path([:account, @creative_concept, :tangible_things, :chart], timespan: "1m") do %>
            <%= render "shared/supercharts/chart_skeleton" do %>
              <%= t('tangible_things.label') %>&hellip;
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
        lines[index] = if line.match?(/do$/)
          "#{line}\n#{chart_resource_lines}\n"
        else
          "#{line} do\n#{chart_resource_lines}\nend"
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
      "lib/scaffolding/app"
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
    when "lib/scaffolding/app"
      "app"
    else
      "🛑"
    end
  end
end
