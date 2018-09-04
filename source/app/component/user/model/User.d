module app.component.user.model.User;

import entity;
@Table("user_users")
class User
{
    mixin MakeEntity;
    
    @AutoIncrement
    @PrimaryKey
    int id;

    string name;

    string password;

    string salt;

    string email;

    string mobile;

    // @Column("role_id")
    // int roleId;

    short status;

    int created;

    int updated;
}
