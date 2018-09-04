module app.component.user.controller.UserController;

import hunt;
import app.component.user.model.User;
import app.component.user.repository.UserRepository;
import app.component.forum.repository.ThreadRepository;
import app.component.forum.repository.PostRepository;
import app.component.forum.helper.Password;
import std.digest.md;
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
        int userislogin = checkuser()?1:0;
        view.assign("userislogin", userislogin);
        view.assign("title", thisuser.name~"的个人主页 - D语言中文社区");

        return view.render("user/profile");
    }

    @Action 
    Response login()
    {
        if(request.method() == HttpMethod.Post)
        {
            string name = request.post("username","");
            string password = request.post("password","");
            auto find = (new UserRepository).findByName(name)?(new UserRepository).findByName(name):(new UserRepository).findByEmail(name);

            if(find){
                if(find.password == generateUserPassword(password, find.salt))
                {
                    request.session.set("USER",cast(string) serialize!User(find));
                    // (new Cookie).set("USER",cast(string) serialize!User(find));
                    return new RedirectResponse("/");
                }else{
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
        if(request.method() == HttpMethod.Post){
            string name = request.post("username","");
            string password = request.post("password","");
            string email = request.post("email","");
            auto find = (new UserRepository).findByName(name)?(new UserRepository).findByName(name):((new UserRepository).findByEmail(email)?(new UserRepository).findByEmail(email):null);
            if(find){
                return new RedirectResponse("/join");
            }
            else{
                User user = new User();
                user.name = name;
                user.salt = generateSalt();
                user.password = generateUserPassword(password, user.salt);
                user.email = email;
                user.status = 1;
                user.created = to!int(Clock.currStdTime.stdTimeToUnixTime()); //Clock.currStdTime();
                (new UserRepository).save(user);

                return new RedirectResponse("/login");
            }
        }

        view.assign("title","加入 - D语言中文社区");
        return request.createResponse().setContent(view.render("user/register"));
    }

    @Action 
    Response logout()
    {
        if(request.session.has("USER")){
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
