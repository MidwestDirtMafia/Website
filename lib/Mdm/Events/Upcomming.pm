package Mdm::Events::Upcomming;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use UUID::Tiny ':std';
use Data::Dumper;
use Mdm::Utils;
use Clone 'clone';

prefix '/events/upcomming';

get '/' => sub {
    my $events = [];
    my $filter = {
        published => 1,
        start_date => { '>=' => \"CURRENT_DATE" }
    };
    my $user = session('user');
    if (defined($user) && $user->{admin} == 1) {
        $filter = {};
    }

    my $rs = schema->resultset("UpcommingEvent")->search($filter);
    while (my $event = $rs->next) {
        push @$events, $event->{_column_data};
    }
    template 'upcomming_events', { nav_current => "upcomming", events => $events };
};
get '/create' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    template 'create_upcomming_event', { submit => "Create", filesRequired => "required" };
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
    my $open = param 'registrationOpen';
    my $private = param 'privateRegistration';
    my $byline = param 'byline';
    my $summary = param 'summary';
    my $desc = param 'description';
    my $logoUpload = upload('logoFile');
    my $bannerUpload = upload('bannerFile');
    if (!defined($title)) {
        flash error => "Title not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($startDate)) {
        flash error => "Start Date not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($endDate)) {
        flash error => "End Date not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($desc) ) {
        flash error => "Description not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($summary) ) {
        flash error => "Description not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($logoUpload)) {
        flash error => "Logo file not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($bannerUpload)  ) {
        flash error => "Banner file not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
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
        reg_open    => $open ? 1 : 0,
        private_registration => $private ? 1 : 0,
        user_id     => session('user')->{id},
        description => $desc,
        logo_image  => $logoHash,
        banner_image=> $bannerHash,
        summary     => $summary,
        byline      => $byline,
    };
    my $event = schema->resultset("UpcommingEvent")->create($insertData);
    $event->insert;
    redirect "/events/upcomming/$uuid";
};

get '/:uuid' => sub {
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Please check the link you used to activate your account";
        return template 'index';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    template 'upcomming_event', { event => $event->{_column_data}};
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
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    my $data = clone($event->{_column_data});
    $data->{startDate} = delete $data->{start_date};
    $data->{endDate} = delete $data->{end_date};
    $data->{published} = $data->{published} ? 'checked' : '';
    $data->{registrationOpen} = $data->{reg_open} ? 'checked' : '';
    $data->{privateRegistration} = $data->{private_registration} ? 'checked' : '';
    $data->{filesRequired} = '';
    $data->{submit} = "Save";
    template 'create_upcomming_event', $data;
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
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    my $title = param 'title';
    my $startDate = param 'startDate';
    my $endDate = param 'endDate';
    my $published = param 'published';
    my $open = param 'registrationOpen';
    my $private = param 'privateRegistration';
    my $byline = param 'byline';
    my $summary = param 'summary';
    my $desc = param 'description';
    my $logoUpload = upload('logoFile');
    my $bannerUpload = upload('bannerFile');
    if (!defined($title)) {
        flash error => "Title not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($startDate)) {
        flash error => "Start Date not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($endDate)) {
        flash error => "End Date not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($desc) ) {
        flash error => "Description not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    if (!defined($summary) ) {
        flash error => "Description not defined";
        return template 'create_upcomming_event', { title => $title, startDate => $startDate, endDate => $endDate, published => $published, registrationOpen => $open, privateRegistration => $private, description => $desc, summary => $summary, byline => $byline };
    }
    $event->update({
        title       => $title,
        start_date  => $startDate,
        end_date     => $endDate,
        published   => $published ? 1 :  0,
        reg_open    => $open ? 1 : 0,
        private_registration => $private ? 1 : 0,
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

    redirect "/events/upcomming/$uuid";
};

get '/:uuid/registration/open' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    $event->update({ reg_open => 1 });
    redirect "/events/upcomming/$uuid";
};
get '/:uuid/registration/close' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    $event->update({ reg_open => 0 });
    redirect "/events/upcomming/$uuid";
};
get '/:uuid/registration/private' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    $event->update({ private_registration => 1 });
    redirect "/events/upcomming/$uuid";
};
get '/:uuid/registration/public' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Invalid event";
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    $event->update({ private_registration => 0});
    redirect "/events/upcomming/$uuid";
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
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    $event->update({ published => 1});
    redirect "/events/upcomming/$uuid";
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
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    $event->update({ published => 0});
    redirect "/events/upcomming/$uuid";
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
        return template 'upcomming_events';
    }
    my $event = schema->resultset("UpcommingEvent")->find({ uuid => $uuid });
    if (!defined($event)) {
        flash error => "Invalid Event";
        return template 'upcomming_events';
    }
    $event->delete();
    redirect "/events/upcomming";
};
1;
