module app.component.forum.model.Forum;

import hunt.entity;

@Table("forum_forums")
class Forum
{
    mixin MakeEntity;

    @AutoIncrement
    @PrimaryKey
    int id;

    string name;

    string discription;

    @Column("parent_id")
    int parentId;

    int threads;

    int posts;
    
    short status;

    int created;

    int updated;
}
