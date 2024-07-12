import { Controller } from "@hotwired/stimulus"
// import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["state_id","city_id"]
  change(event) {

    let state = this.state_idTarget.value;
    let city = this.city_idTarget.value;
    console.log(state)
    console.log(this.state_idTarget)
    console.log(city)
    console.log(this.city_idTarget)
    
    // get(`/cities?state=${state}`, {
    //   contentType: 'application/json',
    //   hearders: 'application/json'
    // })
    // .then((response) => response.text())
    // .then(res => $('#stories').html(res))
  }

}
