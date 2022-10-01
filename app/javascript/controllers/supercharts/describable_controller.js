import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "overallDescription", "contextualDescription", "contextualDescriptionTemplate" ]
  
  showDescriptionWith(event) {
    const value = event?.detail?.value
    const label = event?.detail?.label
    let newHTML = this.contextualDescriptionTemplateTarget.innerHTML
    this.contextualDescriptionTarget.innerHTML = newHTML
      .replaceAll("%value%", value)
      .replaceAll("%label%", label)
  }
}