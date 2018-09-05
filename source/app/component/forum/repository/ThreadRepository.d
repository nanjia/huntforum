module app.component.forum.repository.ThreadRepository;

import hunt.entity;

import app.component.forum.model.Thread;

class ThreadRepository : EntityRepository!(Thread, int)
{
    private EntityManager _entityManager;

    this(EntityManager manager = null) {
        super(manager);
        _entityManager = manager is null ? createEntityManager() : manager;
    }

    struct Objects
    {
        CriteriaBuilder builder;
        CriteriaQuery!Thread criteriaQuery;
        Root!Thread root;
    }

    Objects newObjects()
    {
        Objects objects;

        objects.builder = _entityManager.getCriteriaBuilder();
        objects.criteriaQuery = objects.builder.createQuery!Thread;
        objects.root = objects.criteriaQuery.from();

        return objects;
    }

    Thread[] findByKeyword(string keyword)
    {
        auto objects = this.newObjects();

        auto p1 = objects.builder.like(objects.root.Thread.title, "%"~keyword~"%");

        auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));

        Thread[] threads = typedQuery.getResultList();
        if(threads.length > 0)
            return threads;
        return null;
    }

    Thread[] getThreadByUser(int user_id)
    {

        auto objects = this.newObjects();

        auto p1 = objects.builder.equal(objects.root.Thread.userId, user_id);

        auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));

        Thread[] threads = typedQuery.getResultList();
        if(threads.length > 0)
            return threads;
        return null;
    }

    Thread[] findThreadsByForum(int forum_id)
    {
        auto objects = this.newObjects();

        auto p1 = objects.builder.equal(objects.root.Thread.forumId, forum_id);

        auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));

        Thread[] threads = typedQuery.getResultList();
        if(threads.length > 0)
            return threads;
        return null;
    }

    auto IncreField(string field)
    {
        
    }
}
