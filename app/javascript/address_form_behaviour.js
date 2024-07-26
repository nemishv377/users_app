  $(document).ready(function() {
      let destroies = $(".destroy");
      console.log(destroies);
      for(var destroy of destroies){
        console.log(destroy);
        destroy.style.display = 'none';
      }
  });
