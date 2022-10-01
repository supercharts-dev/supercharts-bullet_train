import { identifierForContextKey } from "@hotwired/stimulus-webpack-helpers"

import SuperchartController from "./superchart_controller"
import DescribableController from "./supercharts/describable_controller"
import FilterableController from "./supercharts/filterable_controller"
import FiltersController from "./supercharts/filters_controller"

export const controllerDefinitions = [
  [SuperchartController, "superchart_controller.js"],
  [DescribableController, "supercharts/describable_controller.js"],
  [FilterableController, "supercharts/filterable_controller.js"],
  [FiltersController, "supercharts/filters_controller.js"],
].map(function(d) {
  const key = d[1]
  const controller = d[0]
  return {
    identifier: identifierForContextKey(key),
    controllerConstructor: controller
  }
})

export {
  SuperchartController,
  DescribableController,
  FilterableController,
  FiltersController,
}
