import { identifierForContextKey } from "@hotwired/stimulus-webpack-helpers"

import SuperchartController from "./superchart_controller"

export const controllerDefinitions = [
  [SuperchartController, "superchart_controller.js"],
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
}
