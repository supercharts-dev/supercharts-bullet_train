import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "overallDescription", "contextualDescription", "contextualDescriptionTemplate" ]
  static classes = [ "hideOverallDescription", "hideContextualDescription" ]
  
  showDescriptionWith(event) {
    if (!event?.detail?.show) {
      this.hideContextualDescription()
      this.showOverallDescription()
      return
    }
    
    this.hideOverallDescription()
    const value = event?.detail?.value
    const label = event?.detail?.label
    let newHTML = this.contextualDescriptionTemplateTarget.innerHTML
    this.contextualDescriptionTarget.innerHTML = newHTML
      .replaceAll("%value%", value)
      .replaceAll("%label%", label)
    this.showContextualDescription()
  }
  
  hideOverallDescription() {
    this.overallDescriptionTarget.classList.add(...this.hideOverallDescriptionClasses)
  }
  
  showOverallDescription() {
    this.overallDescriptionTarget.classList.remove(...this.hideOverallDescriptionClasses)
  }
  
  hideContextualDescription() {
    this.contextualDescriptionTarget.classList.add(...this.hideContextualDescriptionClasses)
  }
  
  showContextualDescription() {
    this.contextualDescriptionTarget.classList.remove(...this.hideContextualDescriptionClasses)
  }
}