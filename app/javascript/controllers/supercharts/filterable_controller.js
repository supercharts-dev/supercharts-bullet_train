import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "chartSourceData", "chart" ]
  static values = {
    eventName: {
      type: String,
      default: "update-chart"
    }
  }
  
  updateChart(event) {
    this.chartSourceDataTarget.innerHTML = event.detail.dataElement.innerHTML
    event.detail.dataElement.remove()
    this.chartTarget.dispatchEvent(new CustomEvent(this.eventNameValue))
  }
}