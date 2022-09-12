import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "data" ]
  static values = {
    eventName: {
      type: String,
      default: "superchart:update-chart"
    }
  }
  
  connect() {
    this.element.dispatchEvent(
      new CustomEvent(this.eventNameValue, {
        detail: { dataElement: this.dataTarget },
        bubbles: true,
        cancelable: true
      })
    )
  }
}