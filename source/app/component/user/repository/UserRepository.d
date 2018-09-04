module app.component.user.repository.UserRepository;

import app.component.user.model.User;

import entity;

class UserRepository : EntityRepository!(User, int)
{
    private EntityManager _entityManager;

    this(EntityManager manager = null) {
        super(manager);
        _entityManager = manager is null ? createEntityManager() : manager;
    }

    struct Objects
    {
        CriteriaBuilder builder;
        CriteriaQuery!User criteriaQuery;
        Root!User root;
     }

    Objects newObjects()
    {
        Objects objects;

 	objects.builder = _entityManager.getCriteriaBuilder();

	objects.criteriaQuery = objects.builder.createQuery!User;

	objects.root = objects.criteriaQuery.from();

	return objects;
     }

    User findByName(string name)
    {
	 auto objects = this.newObjects();

	 auto p1 = objects.builder.equal(objects.root.User.name, name);

	 auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));
	
       	 User[] User = typedQuery.getResultList();
         if(User.length > 0)
             return User[0];
         return null;	
    }

    User findByEmail(string email)
    {
	 auto objects = this.newObjects();

	 auto p1 = objects.builder.equal(objects.root.User.email, email);

	 auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));
	
       	 User[] User = typedQuery.getResultList();
         if(User.length > 0)
             return User[0];
         return null;	
    }
}
