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
    template 'past_events', { nav_current => "past", events => $events };
};


get '/create' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    template 'create_past_event', { submit => "Create", filesRequired => "required" };
};


post '/create' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $title = param 'title';
    my $startDate = param 'startDate';
    my $endDate = param 'endDate';
    my $published = param 'published';
    my $byline = param 'byline';
    my $summary = param 'summary';
    my $desc = param 'description';
    my $logoUpload = upload('logoFile');
    my $bannerUpload = upload('bannerFile');
    if (!defined($title)) {
        flash error => "Title not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($startDate)) {
        flash error => "Start Date not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($endDate)) {
        flash error => "End Date not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($desc) ) {
        flash error => "Description not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($summary) ) {
        flash error => "Description not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($logoUpload)) {
        flash error => "Logo file not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($bannerUpload)  ) {
        flash error => "Banner file not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }

    my $logoHash = handle_image_upload($logoUpload);
    my $bannerHash = handle_image_upload($bannerUpload);
    my $uuid = create_uuid_as_string(UUID_RANDOM);

    my $insertData = {
        uuid        => $uuid,
        title       => $title,
        start_date  => $startDate,
        end_date     => $endDate,
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
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Please check the link you used to activate your account";
        return template 'index';
    }
    my $event = schema->resultset("PastEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'past_events';
    }
    template 'past_event', { event => $event->{_column_data}};
};

get '/:uuid/edit' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'past_events';
    }
    my $event = schema->resultset("PastEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'past_events';
    }
    my $data = clone($event->{_column_data});
    $data->{startDate} = delete $data->{start_date};
    $data->{endDate} = delete $data->{end_date};
    $data->{published} = $data->{published} ? 'checked' : '';
    $data->{filesRequired} = '';
    $data->{submit} = "Save";
    template 'create_past_event', $data;
};

post '/:uuid/edit' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'past_events';
    }
    my $event = schema->resultset("PastEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'past_events';
    }
    my $title = param 'title';
    my $startDate = param 'startDate';
    my $endDate = param 'endDate';
    my $published = param 'published';
    my $byline = param 'byline';
    my $summary = param 'summary';
    my $desc = param 'description';
    my $logoUpload = upload('logoFile');
    my $bannerUpload = upload('bannerFile');
    if (!defined($title)) {
        flash error => "Title not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($startDate)) {
        flash error => "Start Date not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($endDate)) {
        flash error => "End Date not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($desc) ) {
        flash error => "Description not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($summary) ) {
        flash error => "Description not defined";
        return template 'create_past_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, description => $desc, summary => $summary, byline => $byline };
    }
    $event->update({
        title       => $title,
        start_date  => $startDate,
        end_date     => $endDate,
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

    redirect "/events/past/$uuid";
};


get '/:uuid/publish' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'past_events';
    }
    my $event = schema->resultset("PastEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'past_events';
    }
    $event->update({ published => 1});
    redirect "/events/past/$uuid";
};

get '/:uuid/unpublish' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'past_events';
    }
    my $event = schema->resultset("PastEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'past_events';
    }
    $event->update({ published => 0});
    redirect "/events/past/$uuid";
};

get '/:uuid/delete' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'past_events';
    }
    my $event = schema->resultset("PastEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'past_events';
    }
    $event->delete();
    redirect "/events/past";
};
1;
