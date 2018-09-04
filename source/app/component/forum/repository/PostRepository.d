module app.component.forum.repository.PostRepository;

import entity;

import app.component.forum.model.Post;

class PostRepository : EntityRepository!(Post, int)
{
    private EntityManager _entityManager;

    this(EntityManager manager = null) {
        super(manager);
        _entityManager = manager is null ? createEntityManager() : manager;
    }

    struct Objects
    {
        CriteriaBuilder builder;
        CriteriaQuery!Post criteriaQuery;
        Root!Post root;
    }

    Objects newObjects()
    {
        Objects objects;

        objects.builder = _entityManager.getCriteriaBuilder();
        objects.criteriaQuery = objects.builder.createQuery!Post;
        objects.root = objects.criteriaQuery.from();

        return objects;
    }

    Post[] findThreadposts(int id)
    {
        Post[] posts;
        auto objects = this.newObjects();
        auto p1 = objects.builder.equal(objects.root.Post.threadId, id);
        auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));
        posts = typedQuery.getResultList();
        return posts;
    }

    Post[] getPostsByUser(int user_id)
    {
        auto objects = this.newObjects();

        auto p1 = objects.builder.equal(objects.root.Post.userId, user_id);

        auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));

        Post[] posts = typedQuery.getResultList();
        if(posts.length > 0)
            return posts;
        return null;
    }
}
