class Scaffolding::SuperchartsRoutesFileManipulator < Scaffolding::RoutesFileManipulator
  def apply(base_namespaces, prepend_namespace_to_child: nil)
    child_namespaces, child_resource, parent_namespaces, parent_resource = divergent_parts

    within = find_or_create_namespaces(base_namespaces)

    # e.g. Project and Projects::Deliverable
    if parent_namespaces.empty? && child_namespaces.one? && parent_resource == child_namespaces.first

      # resources :projects do
      #   scope module: 'projects' do
      #     resources :deliverables, only: collection_actions
      #   end
      # end

      parent_within = find_or_convert_resource_block(parent_resource, within: within)

      # add the new resource within that namespace.
      line = "scope module: '#{parent_resource}' do"
      # TODO you haven't tested this yet.
      unless (scope_within = find(/#{line}/, parent_within))
        scope_within = insert([line, "end"], parent_within)
      end

      find_or_create_resource([child_resource], options: "only: collection_actions", within: scope_within)

      # namespace :projects do
      #   resources :deliverables, except: collection_actions
      # end

      # We want to see if there are any namespaces one level above the parent itself,
      # because namespaces with the same name as the resource can exist on the same level.
      parent_block_start = find_block_parent(parent_within)
      namespace_line_within = find_or_create_namespaces(child_namespaces, parent_block_start)

      if prepend_namespace_to_child.present?
        namespace_line_within = find_or_create_namespaces([prepend_namespace_to_child], namespace_line_within)
      end

      find_or_create_resource([child_resource], options: "except: collection_actions", within: namespace_line_within)
      unless find_namespaces(child_namespaces, within)[child_namespaces.last]
        raise "tried to insert `namespace :#{child_namespaces.last}` but it seems we failed"
      end

    # e.g. Projects::Deliverable and Objective Under It, Abstract::Concept and Concrete::Thing
    elsif parent_namespaces.any?

      # namespace :projects do
      #   resources :deliverables
      # end
      top_parent_namespace = find_namespaces(parent_namespaces, within)[parent_namespaces.first]

      find_or_create_resource(child_namespaces + [child_resource], within: top_parent_namespace)

      # resources :projects_deliverables, path: 'projects/deliverables' do
      #   resources :objectives
      # end
      block_parent_within = find_block_parent(top_parent_namespace)
      parent_namespaces_and_resource = (parent_namespaces + [parent_resource]).join("_")
      parent_within = find_or_create_resource_block([parent_namespaces_and_resource], options: "path: '#{parent_namespaces_and_resource.tr("_", "/")}'", within: block_parent_within)

      if prepend_namespace_to_child.present?
        parent_within = find_or_create_namespaces([prepend_namespace_to_child], parent_within)
      end

      find_or_create_resource(child_namespaces + [child_resource], within: parent_within)
    else

      begin
        within = find_or_convert_resource_block(parent_resource, within: within)
      rescue
        within = find_or_convert_resource_block(parent_resource, options: "except: collection_actions", within: within)
      end

      if prepend_namespace_to_child.present?
        within = find_or_create_namespaces([prepend_namespace_to_child], within)
      end

      find_or_create_resource(child_namespaces + [child_resource], options: define_concerns, within: within)

    end
  end
end
