# app/views/addresses/_address.json.jbuilder
json.id address.id
json.plot_no address.plot_no
json.street_name address.society_name
json.city address.city.name
json.state address.state.name
