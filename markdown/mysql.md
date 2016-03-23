Hi future me. Just leaving this here as a reminder, but the MySql commands to
setup a new database are...  

    # mysql -p  
    create database my_db;  
    grant usage on my_db.* to my_user@localhost   
         identified by 'my_passwd';  
    grant all privileges on my_db.* to my_user@localhost;

