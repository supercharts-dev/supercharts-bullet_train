import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "overallDescription", "contextualDescription", "contextualDescriptionTemplate" ]
  
  showDescriptionWith(event) {
    const index = event?.detail?.index
    const value = event?.detail?.value
    let newHTML = this.contextualDescriptionTemplateTarget.innerHTML
    this.contextualDescriptionTarget.innerHTML = newHTML
      .replaceAll("%value%", value)
      .replaceAll("%label%", `Whatever is at index ${index}`)
  }
}