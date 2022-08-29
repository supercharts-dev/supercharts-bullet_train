require "scaffolding/supercharts_transformer"

class Scaffolding::SuperchartsChartTransformer < Scaffolding::SuperchartsTransformer
  def scaffold_supercharts
    super
    
    # add children to the show page of their parent.
    unless cli_options["skip-parent"] || parent == "None"
      lines_to_add = <<~RUBY
        <div class="mt-4">
          Insert #{child} chart here
        </div>
      RUBY
      scaffold_add_line_to_file(
        parent_show_file,
        lines_to_add,
        "<%# 🚅 super scaffolding will insert new children above this line. %>",
        prepend: true
      )
    end
  end
  
  def parent_show_file
    @target_show_file ||= "./app/views/account/scaffolding/absolutely_abstract/creative_concepts/show.html.erb"
  end
end