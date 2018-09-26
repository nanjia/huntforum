module app.component.forum.controller.ForumController;

import hunt.framework;
import app.component.user.model.User;
import app.component.forum.model.Forum;
import app.component.forum.model.Post;
import app.component.forum.model.Thread;
import app.component.forum.repository.ForumRepository;
import app.component.forum.repository.PostRepository;
import app.component.forum.repository.ThreadRepository;

import app.component.forum.helper.Paginate;
import app.component.forum.helper.Utils;
import kiss.logger;

class ForumController : Controller
{
    mixin MakeController;
    @Action string index()
    {
        return "abs";
    }

    @Action
    string list()
    {
        auto repository = new ForumRepository;
        auto user = checkuser();
        view.assign("user", user);
        view.assign("forums", repository.findAll());
        view.assign("title","全部版面 - D语言中文社区");
        int userislogin = checkuser()?1:0;
        view.assign("userislogin", userislogin);
        view.assign("hotthreads", hotthreads());

        return view.render("forum/forums");
    }
    
    @Action
    Response threads(int id)
    {
        logInfo((new ForumRepository).findById(id));
        auto threads = (new ThreadRepository).findThreadsByForum(id);
        view.assign("threads", threads);
        view.assign("forum", (new ForumRepository).findById(id));
        view.assign("title", (new ForumRepository).findById(id).name);
        view.assign("user", checkuser());
        int userislogin = checkuser()?1:0;
        view.assign("userislogin", userislogin);
        view.assign("hotthreads", hotthreads());
        view.assign("title", (new ForumRepository).findById(id).name~" - D语言中文社区");

        return response.setContent(view.render("forum/forum"));
    }


    @Action 
    string search()
    {
        // uint page = request.get!uint("page" , 1);
        string keyword = request.get("q","").decode;
        auto repository = new ThreadRepository;
        auto threads = repository.findByKeyword(keyword);
        auto user = checkuser();
        int userislogin = checkuser()?1:0;
        view.assign("userislogin", userislogin);
        // int limit = 15 ;  // 每页显示多少条
        // JSONValue alldata = pageToJson!Post(repository.findByKeyword(new Pageable((page-1 < 0 ? 0 : page-1 ) , limit)));
        view.assign("user", user);
        view.assign("threads", threads);
        view.assign("title","搜索 - D语言中文社区");
        // int totalPages = cast(int)alldata["totalPages"].integer ;
        // Paginate temPage = new Paginate("/?page={page}" , (cast(int) page <= 0 ? 1 : cast(int) page) , totalPages);
        // view.assign("pageView", temPage.showPages());
        view.assign("hotthreads", hotthreads());

        return view.render("forum/search");
    }

    
    @Action 
    User checkuser()
    {
        // auto str = request.cookie("USER");
    	auto str = request.session.get("USER");
        if (str == null)
	    return null;
	    return unserialize!User(cast(byte[]) str);
    }

    @Action 
    JSONValue hotthreads()
    {
        auto repository = new ThreadRepository;
        JSONValue alldata = pageToJson!Thread(repository.findAll(new Pageable(0 , 10, repository.Field.posts , OrderBy.DESC)));
        return alldata;
    }
}
