  // =========================== Nested form ========================================
  document.addEventListener('DOMContentLoaded', function() {
    document.addEventListener('click', function(event) {
      
      if (event.target.classList.contains('destroy')) {
        console.log(event.target.id)
        if (event.target.id=="user_addresses_attributes_0__destroy"){
          event.target.value = 0;
          alert("You should not remove your Permanent address!");
        }
        else{
          event.target.value = 1;
          destroy_add = event.target.parentNode.parentNode;
          destroy_add.style.display = 'none';
        }
      }

// =========================== Nested state and city ========================================
      for(var stateSelecet of document.querySelectorAll('.states')){
        stateSelecet.addEventListener("change", (event) => {
          
          const stateId = event.target.value;
          let nested_city = event.target.parentNode.nextElementSibling.getElementsByClassName('cities')[0];
          let nested_city_error = event.target.parentNode.parentNode.nextElementSibling.getElementsByClassName('cities')[0];
          if (typeof nested_city == 'undefined')
            set_city(stateId,nested_city_error);
          else
            set_city(stateId,nested_city);                    
        });
      }
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