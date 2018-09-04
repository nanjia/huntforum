module app.component.forum.model.Post;

import entity;
import app.component.user.model.User;

@Table("forum_posts")
class Post
{
    mixin MakeEntity;
    
    @AutoIncrement
    @PrimaryKey
    int id;

    @Column("user_id")
    int userId;

    string user_name;

    @Column("thread_id")
    int threadId;

    @Column("is_thread")
    short isThread;

    short status;

    int created;

    int updated;

    string content;

    string content_;

}
