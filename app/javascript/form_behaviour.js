  // =========================== Nested form ========================================
document.addEventListener('DOMContentLoaded', function() {
  document.addEventListener('click', function(event) {
    const destroy_address = event.target
    if (destroy_address.classList.contains('destroy')) {
      if (destroy_address.id=="user_addresses_attributes_0__destroy"){
        destroy_address.value = 0;
        alert("You should not remove your address!");
      }
      else{
        destroy_address.value = 1;
        destroy_add = destroy_address.parentNode.parentNode;
        destroy_add.style.display = 'none';
      }
    }

// =========================== Nested state and city ========================================
    document.querySelectorAll('.states').forEach(stateSelecet => {
      stateSelecet.addEventListener("change", (event) => {
        const state = event.target
        const stateId = state.value;
        let nested_city = state.parentNode.nextElementSibling.getElementsByClassName('cities')[0];
        let nested_city_error = state.parentNode.parentNode.nextElementSibling.getElementsByClassName('cities')[0];
        if (typeof nested_city == 'undefined')
          set_city(stateId,nested_city_error);
        else
          set_city(stateId,nested_city);                    
      });
    });
    
// ========================= Default address checkbox ==========================================

    const default_addresses = document.querySelectorAll('.set-default-checkbox');
    default_addresses.forEach(default_address => {
      default_address.addEventListener('change',()=>{
        default_addresses.forEach(address => {
          if (default_address!==address)
            address.checked = false            
        });
        default_address.checked = true;
      })
    });

  });
});

  // ========================= Set City =============================

function set_city(stateId,nested_city)
{
  if(stateId)
  {
    fetch(`/states/${stateId}/cities`)
      .then(response => response.json())
      .then(cities => {
        nested_city.innerHTML = '<option value="" read-only >Select a City</option>';
        cities.forEach(city => {
          const option = document.createElement('option');
          option.value = city.id;
          option.textContent = city.name;
          nested_city.appendChild(option);
        });
      })
  }
  else{
    nested_city.innerHTML = '<option value="" read-only >Select a City</option>';
  }
}