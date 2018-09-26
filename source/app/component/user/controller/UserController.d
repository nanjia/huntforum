module app.component.user.controller.UserController;

import hunt.framework;

import app.component.user.model.User;
import app.component.user.repository.UserRepository;
import app.component.user.helper.Password;

import app.component.forum.repository.ThreadRepository;
import app.component.forum.repository.PostRepository;

import std.datetime;

class UserController : Controller
{
    mixin MakeController;

    @Action
    string profile(int id)
    {
        auto user = checkuser();
        auto thisuser = (new UserRepository).findById(id);

        view.assign("threads", (new ThreadRepository).getThreadByUser(id));
        view.assign("posts", (new PostRepository).getPostsByUser(id));
        view.assign("user",user); 
        view.assign("thisuser", thisuser);
        view.assign("userislogin", checkuser()?1:0);
        view.assign("title", thisuser.name ~ "的个人主页 - D语言中文社区");

        return view.render("user/profile");
    }

    @Action 
    Response login()
    {
        if(request.method() == HttpMethod.Post)
        {
            logInfo(12345);
            string name = request.post("username","");
            string password = request.post("password","");
            auto repository = new UserRepository;
            auto find = repository.findByName(name)?repository.findByName(name):repository.findByEmail(name);
            logInfo(name);
            if(find)
            {
                logInfo(generateUserPassword(password, find.salt));
                if(find.password == generateUserPassword(password, find.salt))
                {
                    request.session.set("USER",cast(string) serialize!User(find));
                    // (new Cookie).set("USER",cast(string) serialize!User(find));
                    return new RedirectResponse("/");
                }
                else
                {
                    return new RedirectResponse("/login");
                }
            }

            return new RedirectResponse("/login");
        }

        view.assign("title","登录 - D语言中文社区");
        return request.createResponse().setContent(view.render("user/login"));
    }

    @Action 
    Response register()
    {
        if(request.method() == HttpMethod.Post)
        {
            User user;
            string name = request.post("username","");
            string password = request.post("password","");
            string email = request.post("email","");

            auto repository = new UserRepository;

            user = repository.findByName(name) ? repository.findByName(name) : ( repository.findByEmail(email) ? repository.findByEmail(email) : null );

            if(user)
            {
                return new RedirectResponse("/join");
            }
            else
            {
                user = new User();
                user.name = name;
                user.salt = generateSalt();
                user.password = generateUserPassword(password, user.salt);
                user.email = email;
                user.status = 1;
                user.created = time();

                repository.save(user);

                return new RedirectResponse("/login");
            }
        }

        view.assign("title","加入 - D语言中文社区");
        return request.createResponse().setContent(view.render("user/register"));
    }

    @Action 
    Response logout()
    {
        if(request.session.has("USER"))
        {
            request.session.remove("USER");
        }
        
        return new RedirectResponse("/");
    }

    @Action 
    User checkuser()
    {
    	auto str = request.session.get("USER");
        // auto str = (new CookieManager).get("USER");
        if (str == null)
	    return null;
	    return unserialize!User(cast(byte[]) str);
    }

}
