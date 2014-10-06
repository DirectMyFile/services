$("#form").on("submit", function() {
  var username = $("#username").val();
  var password = $("#password").val();
  var email = $("#email").val();

  event.preventDefault();

  $.ajax({
    type: "POST",
    url: "/api/users/register",
    data: JSON.stringify({
      username: username,
      password: password,
      email: email
    }),
    headers: {
      "X-DirectCode-Token": "abcdefg",
      "Content-Type": "application/json"
    },
    success: function(data) {
      if (data.message) {
        alert(data.message);
      } else {
        alert("Success! You have been registered with DirectCode.");
      }
    },
    error: function (data) {
      var message = data.message;
      
      alert(message);
    },
    dataType: "json"
  });
});