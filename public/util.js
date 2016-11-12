function submitForm() {
  const data = {emails: JSON.parse($('#email-list').val())};
  $.ajax({
    method: 'POST',
    url: '/unique_emails',
    processData: false,
    data: JSON.stringify(data),
    dataType: 'json',
    contentType: 'application/json',
    success: function(res) { console.log(res);},
    error: function(res) {console.log('error');}
  });

  return false;
}
