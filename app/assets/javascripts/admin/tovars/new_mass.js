$('#without_vendor_code').change(function(e){
   if(e.target.checked){
 $('.js__descr').text('');
   }
 else {
 
 $('.js__descr').text('Артикул - ');
   }
})
