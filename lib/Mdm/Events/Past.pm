package Mdm::Events::Past;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use UUID::Tiny ':std';
use Data::Dumper;
use Mdm::Utils;
use Clone 'clone';

prefix '/events/past';
hook 'before' => sub {
    return if (request->path_info !~ m{^/events/past});

    my $uuid = param('uuid');
    if (defined($uuid)) {
        if (!is_uuid_string($uuid)) {
            flash error => "Invalid event ID.";
            return redirect '/events/past';
        }
        my $event = schema->resultset("PastEvent")->find({ uuid => $uuid });
        if (!defined($event)) {
            flash error => "Invalid Event ID";
            return redirect '/events/past';
        }
        var 'event' => $event;
    }
};
get '/' => sub {
    my $events = [];
    my $filter = {
        published => 1,
    };
    my $user = session('user');
    if (defined($user) && $user->{admin} == 1) {
        $filter = {};
    }

    my $rs = schema->resultset("PastEvent")->search($filter);
    while (my $event = $rs->next) {
        push @$events, $event->{_column_data};
    }
    template 'past/events', { nav_current => "past", events => $events };
};


get '/create' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    template 'past/create', { submit => "Create", filesRequired => "required" };
};


post '/create' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    my $title = param 'title';
    my $start_date = param 'start_date';
    my $end_date = param 'end_date';
    my $published = param 'published';
    my $byline = param 'byline';
    my $summary = param 'summary';
    my $desc = param 'description';
    my $logoUpload = upload('logoFile');
    my $bannerUpload = upload('bannerFile');
    if (!defined($title)) {
        flash error => "Title not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($start_date)) {
        flash error => "Start _date not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($end_date)) {
        flash error => "End _date not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($desc) ) {
        flash error => "Description not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($summary) ) {
        flash error => "Description not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($logoUpload)) {
        flash error => "Logo file not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($bannerUpload)  ) {
        flash error => "Banner file not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }

    my $logoHash = handle_image_upload($logoUpload);
    my $bannerHash = handle_image_upload($bannerUpload);
    my $uuid = create_uuid_as_string(UUID_RANDOM);

    my $insertData = {
        uuid        => $uuid,
        title       => $title,
        start_date  => $start_date,
        end_date     => $end_date,
        published   => $published ? 1 :  0,
        user_id     => session('user')->{id},
        description => $desc,
        logo_image  => $logoHash,
        banner_image=> $bannerHash,
        summary     => $summary,
        byline      => $byline,
    };
    my $event = schema->resultset("PastEvent")->create($insertData);
    $event->insert;
    redirect "/events/past/$uuid";
};

get '/:uuid' => sub {
    template 'past/event', { event => vars->{event}};
};

get '/:uuid/edit' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    
    my $data = clone(vars->{event}->{_column_data});
    $data->{published} = $data->{published} ? 'checked' : '';
    $data->{filesRequired} = '';
    $data->{submit} = "Save";
    template 'past/create', $data;
};

post '/:uuid/edit' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $event = vars->{event};
    my $title = param 'title';
    my $start_date = param 'start_date';
    my $end_date = param 'end_date';
    my $published = param 'published';
    my $byline = param 'byline';
    my $summary = param 'summary';
    my $desc = param 'description';
    my $logoUpload = upload('logoFile');
    my $bannerUpload = upload('bannerFile');
    if (!defined($title)) {
        flash error => "Title not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($start_date)) {
        flash error => "Start _date not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($end_date)) {
        flash error => "End _date not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($desc) ) {
        flash error => "Description not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($summary) ) {
        flash error => "Description not defined";
        return template 'past/create', { title => $title, start_date => $start_date, end_date => $end_date, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    $event->update({
        title       => $title,
        start_date  => $start_date,
        end_date     => $end_date,
        published   => $published ? 1 :  0,
        description => $desc,
        summary     => $summary,
        byline      => $byline,
    });
    if (defined($logoUpload)) {
        my $logoHash = handle_image_upload($logoUpload);
        $event->update({ logo_image => $logoHash });
    }
    if (defined($bannerUpload)) {
        my $bannerHash = handle_image_upload($bannerUpload);
        $event->update({ banner_image => $bannerHash });
    }

    redirect "/events/past/".vars->{event}->uuid;
};


get '/:uuid/publish' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ published => 1});
    redirect "/events/past/".vars->{event}->uuid;
};

get '/:uuid/unpublish' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ published => 0});
    redirect "/events/past/".vars->{event}->uuid;
};

get '/:uuid/delete' => sub {
    my $user = session('user');
    vars->{event}->delete();
    redirect "/events/past";
};
1;
