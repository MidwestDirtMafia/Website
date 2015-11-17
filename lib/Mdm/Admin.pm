package Mdm::Admin;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use Data::Dumper;

use Mdm::Utils;

prefix '/admin';
hook 'before' => sub {
    return if (request->path_info !~ m{^/admin});
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    my $user_id = param 'id';
    if (defined($user_id)) {
        if ($user_id !~ m/^\d+$/) {
            flash error => "Invlid User";
            return redirect '/admin/users';
        }
        my $u = schema->resultset("User")->find({ user_id => $user_id });
        if (!defined($user)) {
            flash error => "Invlid User";
            return redirect '/admin/users';
        }
        var user => $u;
    }
};
get '/' => sub {
     template 'admin/index';
};

get '/users' => sub {
    template 'admin/users';
};
get '/user/list' => sub {
    my $offset = param 'offset';
    $offset //= 0;
    my $limit = param 'limit';
    my $filter = {};
    my $email = param 'search';
    if (defined($email)) {
        $filter->{email} = $email;
    }

    my $c = schema->resultset("User")->search($filter)->count;
    my $rs = schema->resultset("User")->search(
        $filter,
        {
            prefetch => [ 'user_status' ],
            order_by => { -desc => "email" },
            rows => $limit,
            offset => $offset,
        }
    );
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $users = [];
    while (my $u = $rs->next) {
        delete $u->{password};
        delete $u->{token};
        push @$users, $u;
    }
    return to_json({ total => $c, rows => $users });
};

get '/users/:id' => sub {
    template 'admin/user', { user => vars->{user} };
};

get '/users/:id/enable' => sub {
    vars->{user}->update({ user_status_id => 2 });
    redirect "/admin/users/".vars->{user}->id;
};
get '/users/:id/disable' => sub {
    vars->{user}->update({ user_status_id => 4 });
    redirect "/admin/users/".vars->{user}->id;
};

get '/users/:id/admin/enable' => sub {
    vars->{user}->update({ admin => 1 });
    redirect "/admin/users/".vars->{user}->id;
};
get '/users/:id/admin/disable' => sub {
    vars->{user}->update({ admin => 0 });
    redirect "/admin/users/".vars->{user}->id;
};
get '/users/:id/support/enable' => sub {
    vars->{user}->update({ support => 1 });
    redirect "/admin/users/".vars->{user}->id;
};
get '/users/:id/support/disable' => sub {
    vars->{user}->update({ support => 0 });
    redirect "/admin/users/".vars->{user}->id;
};

get '/news' => sub {
    template 'admin/news/index';
};
get '/news/create' => sub {
    template 'admin/news/create';
};

post '/news/create' => sub {
    my $data = {
        title => param('title'),
        content => param('content'),
    };
    if (!defined($data->{title}) || $data->{title} !~ m/^.{2,255}$/) {
        flash error => "Invalid title";
        return template 'admin/news/create', $data;
    };
    if (!defined($data->{content}) || $data->{content} eq "") {
        flash error => "Invalid content";
        return template 'admin/news/create', $data;
    }
    $data->{user_id} = session('user')->{id};
    my $a = schema->resultset("News")->create($data);
    $a->insert;
    flash info => "New artical added";
    redirect '/admin/news/create';
};

get '/news/list' => sub {
    my $offset = param 'offset';
    $offset //= 0;
    my $limit = param 'limit';
    my $filter = {};
    my $title = param 'search';
    if (defined($title) && $title ne "") {
        $filter->{title} = { like => "%$title%" };
    }

    my $c = schema->resultset("News")->search($filter)->count;
    my $rs = schema->resultset("News")->search(
        $filter,
        {
            prefetch => [ 'user' ],
            order_by => { -desc => "date" },
            rows => $limit,
            offset => $offset,
        }
    );
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $articals = [];
    while (my $u = $rs->next) {
        push @$articals, $u;
    }
    return to_json({ total => $c, rows => $articals });
};

get '/news/:id/edit' => sub {
    my $id = param 'id';
    if (!defined($id) || $id !~ m/^\d+$/) {
        flash error => "Invalid news artical";
        return redirect '/admin/news';
    }
    my $a = schema->resultset("News")->find({ news_id => $id });
    if (!defined($a)) {
        flash error => "Invalid news artical";
        return redirect '/admin/news';
    }
    template 'admin/news/create', $a->{_column_data};
};
post '/news/:id/edit' => sub {
    my $id = param 'id';
    if (!defined($id) || $id !~ m/^\d+$/) {
        flash error => "Invalid news artical";
        return redirect '/admin/news';
    }
    my $a = schema->resultset("News")->find({ news_id => $id });
    if (!defined($a)) {
        flash error => "Invalid news artical";
        return redirect '/admin/news';
    }
    my $data = {
        title => param('title'),
        content => param('content'),
    };
    if (!defined($data->{title}) || $data->{title} !~ m/^.{2,255}$/) {
        flash error => "Invalid title";
        return template 'admin/news/create', $data;
    };
    if (!defined($data->{content}) || $data->{content} eq "") {
        flash error => "Invalid content";
        return template 'admin/news/create', $data;
    }
    $a->update($data);
    flash info => "News artical updated";
    redirect '/admin/news';
};
get '/news/:id/delete' => sub {
    my $id = param 'id';
    if (!defined($id) || $id !~ m/^\d+$/) {
        flash error => "Invalid news artical";
        return redirect '/admin/news';
    }
    my $a = schema->resultset("News")->find({ news_id => $id });
    if (!defined($a)) {
        flash error => "Invalid news artical";
        return redirect '/admin/news';
    }
    $a->delete();
    flash info => "News artical deleted";
    redirect '/admin/news';
};


get '/sponsors' => sub {
    template 'admin/sponsors/index';
};
get '/sponsors/create' => sub {
    template 'admin/sponsors/create', { title => "Create", filesRequired => "required" };
};

post '/sponsors/create' => sub {
    my $data = {
        name => param('name'),
        link => param('link'),
    };
    if (!defined($data->{name}) || $data->{name} !~ m/^.{2,255}$/) {
        flash error => "Invalid name";
        $data->{name} = "Create";
        $data->{filesRequired} = "required";
        return template 'admin/sponsors/create', $data;
    };
    if (!defined($data->{link}) || $data->{link} eq "") {
        flash error => "Invalid link";
        $data->{title} = "Create";
        $data->{filesRequired} = "required";
        return template 'admin/sponsors/create', $data;
    }
    my $logoUpload = upload('logoFile');
    if (!defined($logoUpload)) {
        flash error => "Invalid logo";
        $data->{title} = "Create";
        $data->{filesRequired} = "required";
        return template 'admin/sponsors/create', $data;
    }
    $data->{image} = handle_image_upload($logoUpload);
    my $a = schema->resultset("Sponsor")->create($data);
    $a->insert;
    flash info => "New sponsor added";
    redirect '/admin/sponsors';
};


get '/sponsors/list' => sub {
    my $offset = param 'offset';
    $offset //= 0;
    my $limit = param 'limit';
    my $filter = {};
    my $name = param 'search';
    if (defined($name) && $name ne "") {
        $filter->{name} = { like => "%$name%" };
    }

    my $c = schema->resultset("Sponsor")->search($filter)->count;
    my $rs = schema->resultset("Sponsor")->search(
        $filter,
        {
            order_by => { -desc => "name" },
            rows => $limit,
            offset => $offset,
        }
    );
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $articals = [];
    while (my $u = $rs->next) {
        push @$articals, $u;
    }
    return to_json({ total => $c, rows => $articals });
};

get '/sponsors/:id/edit' => sub {
    my $id = param 'id';
    if (!defined($id) || $id !~ m/^\d+$/) {
        flash error => "Invalid sponsors artical";
        return redirect '/admin/sponsors';
    }
    my $a = schema->resultset("Sponsor")->find({ sponsor_id => $id });
    if (!defined($a)) {
        flash error => "Invalid sponsors artical";
        return redirect '/admin/sponsors';
    }
    template 'admin/sponsors/create', { %{$a->{_column_data}}, title => "Edit" };
};
post '/sponsors/:id/edit' => sub {
    my $id = param 'id';
    if (!defined($id) || $id !~ m/^\d+$/) {
        flash error => "Invalid sponsors artical";
        return redirect '/admin/sponsors';
    }
    my $a = schema->resultset("Sponsor")->find({ sponsor_id => $id });
    if (!defined($a)) {
        flash error => "Invalid sponsors artical";
        return redirect '/admin/sponsors';
    }
    my $data = {
        name => param('name'),
        link => param('link'),
    };
    if (!defined($data->{name}) || $data->{name} !~ m/^.{2,255}$/) {
        flash error => "Invalid name";
        $data->{title} = "Edit";
        return template 'admin/sponsors/create', $data;
    };
    if (!defined($data->{link}) || $data->{link} eq "") {
        flash error => "Invalid link";
        $data->{title} = "Edit";
        return template 'admin/sponsors/create', $data;
    }
    my $logoUpload = upload('logoFile');
    if (defined($logoUpload)) {
        $data->{image} = handle_image_upload($logoUpload);
    }
    $a->update($data);
    flash info => "Sponsor  updated";
    redirect '/admin/sponsors';
};
get '/sponsors/:id/delete' => sub {
    my $id = param 'id';
    if (!defined($id) || $id !~ m/^\d+$/) {
        flash error => "Invalid sponsors";
        return redirect '/admin/sponsors';
    }
    my $a = schema->resultset("Sponsor")->find({ sponsor_id => $id });
    if (!defined($a)) {
        flash error => "Invalid sponsor artical";
        return redirect '/admin/sponsors';
    }
    $a->delete();
    flash info => "Sponsor deleted";
    redirect '/admin/sponsors';
};


1;
