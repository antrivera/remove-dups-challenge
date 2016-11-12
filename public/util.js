function submitForm() {
  let jsonList = [];

  try {
    jsonList = JSON.parse($('#email-list').val());
  } catch(e) {
    return false;
  }
  let data = {emails: jsonList};

  $.ajax({
    method: 'POST',
    url: '/unique_emails',
    processData: false,
    data: JSON.stringify(data),
    dataType: 'json',
    contentType: 'application/json',
    success: function(res) { $('#results').html(JSON.stringify(res)); },
    error: function(res) {console.log('error');}
  });

  return false;
}
