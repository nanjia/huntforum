module app.component.forum.controller.ThreadController;

import hunt.framework;
import app.component.user.model.User;
import app.component.forum.model.Post;
import app.component.forum.model.Thread;
import app.component.forum.repository.ForumRepository;
import app.component.forum.repository.PostRepository;
import app.component.forum.repository.ThreadRepository;
import app.component.user.repository.UserRepository;

import app.component.forum.helper.Paginate;
import app.component.forum.helper.Utils;
import std.datetime;
import kiss.logger;
class ThreadController : Controller
{
    mixin MakeController;

    @Action
    string thread(int id)
    {
        auto repository = new ThreadRepository;
        auto thread = repository.findById(id);
        if (thread is null)
        {
            return "Thread not found!";
        }

        thread.views = thread.views+1;
        repository.save(thread);

        view.assign("thread", thread);
        view.assign("title", thread.title);
        view.assign("user", checkuser());
        view.assign("userislogin", checkuser()?1:0);
        view.assign("posts", (new PostRepository).findThreadposts(id));
        view.assign("hotthreads", hotthreads());
        view.assign("title", thread.title~" - D语言中文社区");

        return view.render("forum/thread_view");
    }
    
    @Action
    string list()
    {
        uint page = request.get!uint("page" , 1);
        auto repository = new ThreadRepository;
        auto user = checkuser();
        int limit = 15 ;  // 每页显示多少条
        JSONValue alldata = pageToJson!Thread(repository.findAll(new Pageable((page-1 < 0 ? 0 : page-1 ) , limit, repository.Field.created , OrderBy.DESC)));
        int userislogin = user?1:0;
        view.assign("userislogin", userislogin);
        view.assign("user", user);
        logInfo(user);
        view.assign("threads", alldata);
        view.assign("title","D语言中文社区");
        // view.assign("topics", repository.findAll());
        int totalPages = cast(int)alldata["totalPages"].integer ;
        Paginate temPage = new Paginate("/?page={page}" , (cast(int) page <= 0 ? 1 : cast(int) page) , totalPages);
        view.assign("pageView", temPage.showPages());
        view.assign("hotthreads", hotthreads());

        return view.render("forum/threads");
    }
    
    @Action
    Response forum(int id)
    {
        return null;
    }

    @Action
    Response add()
    {
        if(!checkuser()) return new RedirectResponse("/login");
        if(request.method() == HttpMethod.Post)
        {
            string title = request.post("thread_title","");
            string content = request.post("thread_html_body","");
            string content_ = request.post("thread_body","");
            logInfo(content);
            string user_id = request.post("user_id","");
            string forum_id = request.post("forum_id","");
            string user_name = (new UserRepository).findById(to!int(user_id)).name;

            Thread thread = new Thread();
            Post post = new Post();
            thread.title = title;
            thread.userId = to!int(user_id);
            thread.user_name = user_name;
            thread.forumId = to!int(forum_id);
            thread.created = to!int(Clock.currStdTime.stdTimeToUnixTime());
            thread.updated = to!int(Clock.currStdTime.stdTimeToUnixTime());
            int threadId = ((new ThreadRepository).insert(thread)).id;
            
            post.threadId = threadId;
            post.content = content;
            post.isThread = 1;
            post.userId = to!int(user_id);
            post.user_name = user_name;
            post.created = to!int(Clock.currStdTime.stdTimeToUnixTime());

            auto forum = (new ForumRepository).findById(to!int(forum_id));
            forum.threads = forum.threads+1;
            forum.posts = forum.posts+1;
            forum.updated = to!int(Clock.currStdTime.stdTimeToUnixTime());
            (new ForumRepository).save(forum);
            // post.created = to!int(Clock.currStdTime.stdTimeToUnixTime()); //Clock.currStdTime();
            
            (new PostRepository).save(post);

            return new RedirectResponse("/thread/"~to!string(threadId));
        }
        int userislogin = checkuser()?1:0;
        view.assign("userislogin", userislogin);
        view.assign("user",checkuser());
        view.assign("title","添加主题 - D语言中文社区");
        view.assign("forums", (new ForumRepository).findAll());
        return response.setContent(view.render("forum/add_thread"));
    }

    @Action
    Response edit(id)
    {
        if(!checkuser()) return new RedirectResponse("/login");
        if(request.method() == HttpMethod.Post)
        {

        }
              int userislogin = checkuser()?1:0;
        view.assign("userislogin", userislogin);
        view.assign("user",checkuser());
        view.assign("thread", (new ThreadRepository).findById(id));
        view.assign("title","编辑主题 - D语言中文社区");
        view.assign("forums", (new ForumRepository).findAll());
        return response.setContent(view.render("forum/thread_edit"));
    }

    @Action 
    Response reply()
    {
        Post post = new Post();
        int thread_id = to!int(request.post("thread_id",""));
        string user_id = request.post("user_id","");
        string content = request.post("reply_html_body","");
        string content_ = request.post("reply_body","");
        string user_name = (new UserRepository).findById(to!int(user_id)).name;

        post.threadId = thread_id;
        post.userId = to!int(user_id);
        post.user_name = user_name;
        post.isThread = 0;
        post.content = content;
        post.created = to!int(Clock.currStdTime.stdTimeToUnixTime());

        auto thread = (new ThreadRepository).findById(thread_id);
        thread.posts = thread.posts+1;
        thread.updated = to!int(Clock.currStdTime.stdTimeToUnixTime());

        auto forum = (new ForumRepository).findById(to!int(thread.forumId));
        forum.posts = forum.posts+1;
        forum.updated = to!int(Clock.currStdTime.stdTimeToUnixTime());

        (new ForumRepository).save(forum);        
        (new ThreadRepository).save(thread);
        (new PostRepository).save(post);

        return new RedirectResponse("/thread/"~request.post("thread_id",""));
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
