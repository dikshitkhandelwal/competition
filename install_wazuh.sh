<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Read Cookie Example</title>
</head>
<body>

<div id="cookieValueBox">Cookie value will appear here.</div>

<script>
function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i < ca.length; i++) {
        var c = ca[i].trim();
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

// Display the cookie value in the div box
var cookieValue = readCookie('cookieName'); // Replace 'cookieName' with your actual cookie name
var cookieBox = document.getElementById('cookieValueBox');
if (cookieValue) {
    cookieBox.innerText = 'Cookie value: ' + cookieValue;
} else {
    cookieBox.innerText = 'Cookie not found';
}
</script>

</body>
</html>
