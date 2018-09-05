module app.component.forum.model.Thread;

import hunt.entity;
import app.component.user.model.User;

@Table("forum_threads")
class Thread
{
    mixin MakeEntity;
    
    @AutoIncrement
    @PrimaryKey
    int id;

    string title;

    @Column("user_id")
    int userId;

    string user_name;

    @Column("forum_id")
    int forumId;

    int posts;

    int views;
    
    short status;

    int created;

    int updated;
}
