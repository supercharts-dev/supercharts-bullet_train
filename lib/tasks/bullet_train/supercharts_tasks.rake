# frozen_string_literal: true

# Rake task to remove supercharts dependencies from a Bullet Train application.
# 
# This task:
# 1. Ejects all view partials from supercharts gems to local app/views/ unless 
#    a local variant already exists using the shared/path abstraction for Bullet Train
# 2. Ejects the @supercharts/supercharts-bullet-train npm package, then inventories 
#    which files require @supercharts/stimulus-base and ejects those dependencies
# 3. Includes any missing npm dependencies that these packages require by merging
#    their dependencies from their package.json files
# 4. Removes the supercharts gem and npm packages from Gemfile and package.json
#
# Usage: bundle exec rake supercharts:eject_all
#
# After running this task:
# - Run `bundle install` to update Gemfile.lock
# - Run `yarn install` to update yarn.lock  
# - Test your application thoroughly
# - Commit your changes

require 'json'
require 'fileutils'

namespace :supercharts do
  desc "Remove supercharts dependencies by ejecting views and npm packages"
  task eject_all: :environment do
    puts "🚀 Starting removal of supercharts dependencies...".blue

    # Step 1: Eject view partials that don't have local variants
    eject_supercharts_view_partials

    # Step 2: Eject JavaScript packages and update imports
    eject_supercharts_js_packages

    # Step 3: Remove gem and npm dependencies
    remove_supercharts_from_dependencies

    puts "✅ Supercharts dependency removal completed successfully!".green
    puts ""
    puts "Next steps:".yellow
    puts "1. Run 'bundle install' to update Gemfile.lock"
    puts "2. Run 'yarn install' to update yarn.lock"
    puts "3. Test your application to ensure everything works correctly"
    puts "4. Commit your changes"
  end

  private

  def eject_supercharts_view_partials
    puts "\n📂 Ejecting supercharts view partials...".blue
    
    # Find the installed supercharts gem path
    supercharts_gem_path = find_supercharts_gem_path
    
    if supercharts_gem_path
      puts "  Found supercharts gem at: #{supercharts_gem_path}"
      
      # Discover all view partials in the gem
      supercharts_partials = discover_supercharts_partials(supercharts_gem_path)
      
      if supercharts_partials.any?
        puts "  Found #{supercharts_partials.size} view partials to eject"
        
        supercharts_partials.each do |partial_info|
          partial_path = partial_info[:resolve_path]
          gem_file_path = partial_info[:gem_file_path]
          relative_path = partial_info[:relative_path]
          local_path = Rails.root.join("app/views/#{relative_path}")
          
          unless File.exist?(local_path)
            puts "  Ejecting #{relative_path}..."
            
            # Create the local directory structure
            FileUtils.mkdir_p(File.dirname(local_path))
            
            # Copy the file from gem to local app
            if File.exist?(gem_file_path)
              # Add ejection comment to the top of the file
              original_content = File.read(gem_file_path)
              ejected_content = "<% # Ejected from supercharts-bullet_train gem %>\n\n#{original_content}"
              
              File.write(local_path, ejected_content)
              puts "    ✅ Successfully ejected #{relative_path}".green
            else
              puts "    ❌ Could not find source file: #{gem_file_path}".red
            end
          else
            puts "    ✅ #{relative_path} already exists locally, skipping".green
          end
        end
      else
        puts "  ℹ️  No view partials found in supercharts gem".blue
      end
    else
      puts "  ⚠️  supercharts-bullet_train gem not found - skipping view partial ejection".yellow
    end
  end

  def eject_supercharts_js_packages
    puts "\n📦 Ejecting supercharts JavaScript packages...".blue
    
    # Check if @supercharts/supercharts-bullet-train is imported
    js_files = Dir.glob(Rails.root.join("app/javascript/**/*.js"))
    supercharts_imported = js_files.any? do |file|
      File.read(file).include?("@supercharts/supercharts-bullet-train")
    end

    if supercharts_imported
      eject_supercharts_bullet_train_package
      eject_stimulus_base_package
    else
      puts "  ℹ️  No @supercharts imports found in JavaScript files".blue
    end
  end

  def eject_supercharts_bullet_train_package
    puts "    Ejecting @supercharts/supercharts-bullet-train package..."
    
    # Find the installed supercharts gem path
    supercharts_gem_path = find_supercharts_gem_path
    
    if supercharts_gem_path
      # Create local directory for the ejected package
      local_js_dir = Rails.root.join("app/javascript/supercharts")
      FileUtils.mkdir_p(local_js_dir)

      # Copy JavaScript files from the gem's JavaScript directory
      source_js_dir = File.join(supercharts_gem_path, "app/javascript")
      
      if Dir.exist?(source_js_dir)
        FileUtils.cp_r("#{source_js_dir}/.", local_js_dir)
        puts "      ✅ Copied JavaScript files to app/javascript/supercharts/".green
        
        # Update the import in app/javascript/controllers/index.js
        update_supercharts_import
        
        # Copy package.json dependencies from gem
        merge_supercharts_dependencies(supercharts_gem_path)
      else
        puts "      ❌ Could not find JavaScript files in supercharts gem".red
      end
    else
      puts "      ❌ Could not find supercharts-bullet_train gem".red
    end
  end

  def eject_stimulus_base_package
    puts "    Inventorying files that require @supercharts/stimulus-base..."
    
    # Find all files that import from @supercharts/stimulus-base
    all_js_files = Dir.glob(Rails.root.join("app/javascript/**/*.js"))
    files_requiring_stimulus_base = []
    
    all_js_files.each do |file|
      content = File.read(file)
      if content.include?("@supercharts/stimulus-base")
        files_requiring_stimulus_base << file
        puts "      📋 Found dependency: #{File.basename(file)}"
      end
    end
    
    if files_requiring_stimulus_base.any?
      puts "    Ejecting @supercharts/stimulus-base controllers..."
      
      # Find the actual stimulus-base package
      stimulus_base_path = find_stimulus_base_package
      
      if stimulus_base_path
        copy_stimulus_base_controllers(stimulus_base_path)
        update_stimulus_base_imports(files_requiring_stimulus_base)
      else
        puts "      ❌ Could not find @supercharts/stimulus-base package".red
        puts "      Please install it first: yarn add @supercharts/stimulus-base"
      end
    else
      puts "    ℹ️  No files require @supercharts/stimulus-base, skipping".blue
    end
  end
  
  def find_stimulus_base_package
    # Look for the package in node_modules
    node_modules_path = Rails.root.join("node_modules/@supercharts/stimulus-base")
    return node_modules_path if Dir.exist?(node_modules_path)
    
    # Look for it in yarn cache or other locations
    yarn_cache_output = `yarn cache dir 2>/dev/null`.chomp rescue nil
    if yarn_cache_output && !yarn_cache_output.empty?
      cached_package = Dir.glob("#{yarn_cache_output}/**/stimulus-base*").first
      return cached_package if cached_package && Dir.exist?(cached_package)
    end
    
    nil
  end
  
  def copy_stimulus_base_controllers(source_path)
    target_dir = Rails.root.join("app/javascript/stimulus-base")
    FileUtils.mkdir_p(target_dir)
    
    puts "      Copying stimulus-base controllers from #{source_path}..."
    
    # Look for src directory first, fall back to root level JS files
    src_path = File.join(source_path, "src")
    
    if Dir.exist?(src_path)
      # Copy only the src files, but flatten them to the target directory
      js_files = Dir.glob("#{src_path}/**/*.js")
      
      if js_files.any?
        js_files.each do |source_file|
          # Calculate relative path within src directory
          relative_path = source_file.sub("#{src_path}/", "")
          target_file = File.join(target_dir, relative_path)
          
          # Create target directory if needed
          FileUtils.mkdir_p(File.dirname(target_file))
          
          # Copy the file
          FileUtils.cp(source_file, target_file)
          
          # Fix common JavaScript syntax issues in ejected files
          fix_javascript_syntax(target_file)
          
          puts "        ✅ Copied #{relative_path}".green
        end
      else
        puts "        ⚠️  No JavaScript files found in src directory".yellow
      end
    else
      # Fall back to copying root level JS files (excluding dist)
      js_files = Dir.glob("#{source_path}/*.js").reject { |f| f.include?('/dist/') }
      
      if js_files.any?
        js_files.each do |source_file|
          filename = File.basename(source_file)
          target_file = File.join(target_dir, filename)
          
          # Copy the file
          FileUtils.cp(source_file, target_file)
          
          # Fix common JavaScript syntax issues in ejected files
          fix_javascript_syntax(target_file)
          
          puts "        ✅ Copied #{filename}".green
        end
      else
        puts "        ⚠️  No JavaScript files found in stimulus-base package".yellow
      end
    end
  end
  
  def find_supercharts_gem_path
    # Use bundler to find the gem path
    begin
      gem_path = `bundle show supercharts-bullet_train 2>/dev/null`.chomp
      return gem_path if $?.success? && !gem_path.empty? && Dir.exist?(gem_path)
    rescue
      # Fall back to trying with gem command
    end
    
    # Fall back to using gem command
    begin
      gem_path = `gem which supercharts-bullet_train 2>/dev/null`.chomp
      if !gem_path.empty?
        # gem which returns path to a file, we want the gem root
        gem_root = gem_path.split('/lib/').first
        return gem_root if Dir.exist?(gem_root)
      end
    rescue
      # Ignore errors
    end
    
    nil
  end
  
  def discover_supercharts_partials(gem_path)
    partials = []
    
    # Look for view files in the gem
    views_path = File.join(gem_path, "app/views")
    
    if Dir.exist?(views_path)
      # Find all .erb files (both partials and regular views)
      Dir.glob("#{views_path}/**/*.html.erb").each do |view_file|
        # Convert absolute path to relative path
        relative_path = view_file.sub("#{views_path}/", "")
        
        # Skip super scaffolding partials - these are templates for code generation
        next if relative_path.include?('/scaffolding/')
        
        # For partials (files starting with _), remove the underscore for the resolve path
        # For regular views, keep the name as is
        if File.basename(view_file).start_with?('_')
          # e.g., "shared/supercharts/_chart_skeleton.html.erb" becomes "shared/supercharts/chart_skeleton"
          resolve_path = relative_path.gsub(/\/_([^\/]+)\.html\.erb$/, '/\1')
        else
          # e.g., "shared/supercharts/show.html.erb" becomes "shared/supercharts/show"
          resolve_path = relative_path.gsub(/\.html\.erb$/, '')
        end
        
        partials << {
          resolve_path: resolve_path,
          gem_file_path: view_file,
          relative_path: relative_path
        }
      end
    end
    
    partials.sort_by { |p| p[:resolve_path] }
  end

  def fix_javascript_syntax(file_path)

    return unless File.extname(file_path) == '.js'
    
    content = File.read(file_path)
    
    # Fix incorrect export syntax like "export Chartjs from" to "export { default as Chartjs } from"
    updated_content = content.gsub(
      /^export\s+([A-Z][a-zA-Z0-9]*)\s+from\s+/,
      'export { default as \1 } from '
    )
    
    # Only write if content changed
    if content != updated_content
      File.write(file_path, updated_content)
    end
  end

  def update_supercharts_import
    index_file = Rails.root.join("app/javascript/controllers/index.js")
    return unless File.exist?(index_file)
    
    content = File.read(index_file)
    updated_content = content.gsub(
      'import { controllerDefinitions as superchartsControllers } from "@supercharts/supercharts-bullet-train"',
      'import { controllerDefinitions as superchartsControllers } from "../supercharts"'
    )
    
    if content != updated_content
      File.write(index_file, updated_content)
      puts "      ✅ Updated import in app/javascript/controllers/index.js".green
    end
  end

  def update_stimulus_base_imports(files_requiring_stimulus_base)
    files_requiring_stimulus_base.each do |controller_file|
      content = File.read(controller_file)
      
      # Calculate relative path from this file to the stimulus-base directory
      file_dir = File.dirname(controller_file)
      relative_path = Pathname.new(Rails.root.join("app/javascript/stimulus-base")).relative_path_from(Pathname.new(file_dir))
      
      # Replace the npm package import with local relative path
      updated_content = content.gsub(
        '@supercharts/stimulus-base',
        relative_path.to_s
      )
      
      if content != updated_content
        File.write(controller_file, updated_content)
        puts "      ✅ Updated stimulus-base import to local path in #{File.basename(controller_file)}".green
      end
    end
  end

  def merge_supercharts_dependencies(gem_path)
    # Use gem path if provided, otherwise fall back to local directory for backward compatibility
    supercharts_package_json = File.join(gem_path, "package.json")
    
    app_package_json = Rails.root.join("package.json")
    
    return unless File.exist?(supercharts_package_json) && File.exist?(app_package_json)
    
    supercharts_deps = JSON.parse(File.read(supercharts_package_json))
    app_deps = JSON.parse(File.read(app_package_json))
    
    # Merge dependencies from supercharts package, excluding @supercharts packages
    deps_to_merge = supercharts_deps["dependencies"]&.reject { |name, _| name.start_with?("@supercharts") } || {}
    
    # Add Chart.js if we're creating stubs that need it
    unless app_deps["dependencies"]&.key?("chart.js")
      deps_to_merge["chart.js"] = "^4.0.0"
    end
    
    deps_to_merge.each do |dep_name, version|
      unless app_deps["dependencies"]&.key?(dep_name)
        app_deps["dependencies"] ||= {}
        app_deps["dependencies"][dep_name] = version
        puts "      ✅ Added dependency: #{dep_name}@#{version}".green
      end
    end
    
    File.write(app_package_json, JSON.pretty_generate(app_deps))
    puts "      ✅ Updated package.json with supercharts dependencies".green
  end

  def remove_supercharts_from_dependencies
    puts "\n🗑️  Removing supercharts from dependencies...".blue
    
    # Remove from Gemfile
    remove_supercharts_gem
    
    # Remove from package.json
    remove_supercharts_npm_packages
  end

  def remove_supercharts_gem
    gemfile_path = Rails.root.join("Gemfile")
    return unless File.exist?(gemfile_path)
    
    lines = File.readlines(gemfile_path)
    updated_lines = lines.reject { |line| line.match?(/gem\s+["']supercharts-bullet_train["']/) }
    
    if lines.size != updated_lines.size
      File.write(gemfile_path, updated_lines.join)
      puts "    ✅ Removed supercharts-bullet_train gem from Gemfile".green
    else
      puts "    ℹ️  supercharts-bullet_train gem not found in Gemfile".blue
    end
  end

  def remove_supercharts_npm_packages
    package_json_path = Rails.root.join("package.json")
    return unless File.exist?(package_json_path)
    
    package_data = JSON.parse(File.read(package_json_path))
    
    # Remove @supercharts packages
    supercharts_packages = ["@supercharts/supercharts-bullet-train", "@supercharts/stimulus-base"]
    removed_packages = []
    
    supercharts_packages.each do |package|
      if package_data["dependencies"]&.delete(package)
        removed_packages << package
      end
      if package_data["devDependencies"]&.delete(package)
        removed_packages << package
      end
    end
    
    if removed_packages.any?
      File.write(package_json_path, JSON.pretty_generate(package_data))
      puts "    ✅ Removed npm packages: #{removed_packages.join(', ')}".green
    else
      puts "    ℹ️  No @supercharts npm packages found to remove".blue
    end
  end
end
