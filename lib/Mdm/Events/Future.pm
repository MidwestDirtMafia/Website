package Mdm::Events::Future;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use UUID::Tiny ':std';
use Data::Dumper;
use Mdm::Utils;
use Clone 'clone';

prefix '/events/future';

hook 'before' => sub {
    return if (request->path_info !~ m{^/events/future});

    my $uuid = param('uuid');
    if (defined($uuid)) {
        if (!is_uuid_string($uuid)) {
            flash error => "Invalid event ID.";
            return redirect '/events/future';
        }
        my $event = schema->resultset("FutureEvent")->find({ uuid => $uuid },
            {
                prefetch => [
                    'user',
                    'future_event_type',
                ]
            }
        );
        if (!defined($event)) {
            flash error => "Invalid Event ID";
            return redirect '/events/future';
        }
        var 'event' => $event;
    }
};

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

    my $rs = schema->resultset("FutureEvent")->search($filter, 
        {
            prefetch => [
                'user',
                'future_event_type',
            ]
        }
    );
    while (my $event = $rs->next) {
        push @$events, $event;
    }
    template 'future/events', { nav_current => "future", events => $events };
};
get '/create' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    template 'future/create', { submit => "Create", filesRequired => "required" };
};

sub getData {
    my $data = {
        title => param('title'),
        type => param('type'),
        partner_link => param('partner_link'),
        start_date => param('start_date'),
        end_date => param('end_date'),
        participant_limit => param('participant_limit'),
        published => param('published'),
        reg_open => param('reg_open'),
        private_registration => param('private_registration'),
        byline => param('byline'),
        summary => param('summary'),
        description => param('description'),
    };
    my $logoUpload = upload('logoFile');
    my $bannerUpload = upload('bannerFile');
    if (defined($logoUpload)) {
        $data->{logo_image} = handle_image_upload($logoUpload);
    }
    if (defined($bannerUpload)) {
        $data->{banner_image} = handle_image_upload($bannerUpload);
    }
    return $data;
}

sub validateData {
    my $data = shift;
    if (!defined($data->{title})) {
        flash error => "Title not defined";
        return template 'future/create', $data;
    }
    if (!defined($data->{type})) {
        flash error => "Event type not defined";
        return template 'future/create', $data;
    }
    if ($data->{type} eq "normal") {
        if (!defined($data->{start_date})) {
            flash error => "Start date not defined";
            return template 'future/create', $data;
        }
        if (!defined($data->{end_date})) {
            flash error => "End date not defined";
            return template 'future/create', $data;
        }
    }
    if ($data->{type} eq "partner") {
        if (!defined($data->{partner_link})) {
            flash error => "Partner Link not defined";
            return template 'future/create', $data;
        }
    }
    if (!defined($data->{description}) ) {
        flash error => "Description not defined";
        return template 'future/create', $data;
    }
    if (!defined($data->{summary}) ) {
        flash error => "Description not defined";
        return template 'future/create', $data;
    }
    if ($data->{submit} eq "Create") {
        if (!defined($data->{logo_image})) {
            flash error => "Logo file not defined";
            return template 'future/create', $data;
        }
        if (!defined($data->{banner_image})) {
            flash error => "Banner file not defined";
            return template 'future/create', $data;
        }
    }
    return undef;
}

post '/create' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    my $data = getData();
    $data->{submit} = "Create";
    $data->{filesRequired} = "required";
    my $invalid = validateData($data);
    if (defined($invalid)) {
        return $invalid;
    }

    delete $data->{submit};
    delete $data->{filesRequired};
    $data->{future_event_type}->{type} = delete $data->{type};
    $data->{uuid} = create_uuid_as_string(UUID_RANDOM);
    $data->{published} = $data->{published} ? 1 :  0;
    $data->{reg_open} = $data->{reg_open} ? 1 : 0;
    $data->{private_registration} = $data->{private_registration} ? 1 : 0;
    $data->{user_id} = session('user')->{id};


    my $event = schema->resultset("FutureEvent")->create($data);
    $event->insert;
    redirect "/events/future/".$data->{uuid};
};

get '/:uuid' => sub {
    template 'future/event', { event => vars->{event} };
};

get '/:uuid/edit' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $data = clone(vars->{event}->{_column_data});
    $data->{published} = $data->{published} ? 'checked' : '';
    $data->{reg_open} = $data->{reg_open} ? 'checked' : '';
    $data->{private_registration} = $data->{private_registration} ? 'checked' : '';
    $data->{filesRequired} = '';
    $data->{type} = vars->{event}->future_event_type->type;

    $data->{submit} = "Save";
    template 'future/create', $data;
};

post '/:uuid/edit' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $event = vars->{event};
    my $data = getData();
    $data->{submit} = "Save";
    my $invalid = validateData($data);
    if (defined($invalid)) {
        return $invalid;
    }
    my $type = schema->resultset("FutureEventType")->find({ type => delete $data->{type} });
    if (!defined($type)) {
        flash error => "Invalid event type";
        return template 'future/create', $data;
    }

    delete $data->{submit};
    $data->{published} = $data->{published} ? 1 :  0;
    $data->{reg_open} = $data->{reg_open} ? 1 : 0;
    $data->{private_registration} = $data->{private_registration} ? 1 : 0;
    $data->{future_event_type} = $type;


    debug Dumper($data);

    $event->update($data);

    redirect "/events/future/".$event->uuid;
};

get '/:uuid/registration/open' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ reg_open => 1 });
    redirect "/events/future/".vars->{event}->uuid;
};

get '/:uuid/registration/close' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ reg_open => 0 });
    redirect "/events/future/".vars->{event}->uuid;
};

get '/:uuid/registration/private' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ private_registration => 1 });
    redirect "/events/future/".vars->{event}->uuid;
};

get '/:uuid/registration/public' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ private_registration => 0});
    redirect "/events/future/".vars->{event}->uuid;
};

get '/:uuid/publish' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ published => 1});
    redirect "/events/future/".vars->{event}->uuid;
};

get '/:uuid/unpublish' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ published => 0});
    redirect "/events/future/".vars->{event}->uuid;
};

get '/:uuid/delete' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->delete();
    redirect "/events/future";
};

get '/:uuid/register' => sub {
    my $user = session('user');
    if (!defined($user)) {
        flash error => "Access Denined";
        return redirect '/';
    }
    template 'future/register', { event => vars->{event} };
};

post '/:uuid/register' => sub {
    my $user = session('user');
    if (!defined($user)) {
        flash error => "Access Denined";
        return redirect '/';
    }
    my $event = vars->{event};
    my $parts = param 'participants';
    my @participants;
    if (defined($parts) && $parts ne "") {
        foreach my $p (split /,/, $parts) {
            if ($p !~ m/^\d+$/) {
                flash error => "Invalid participant";
                return template 'future/register', { event => vars->{event} };
            }
            my $pa = schema->resultset("EventParticipant")->search({ event_participant_id => $p, user_id => $user->{id} }, { rows => 1 })->single();
            if (!defined($pa)) {
                flash error => "Invalid participant";
                return template 'future/register', { event => vars->{event} };
            }
            push @participants, $pa;
        }
    }
    $event->create_related("lk_user_future_events", { user_id => $user->{id} });
    foreach my $p (@participants) {
        $event->create_related("lk_event_participant_future_events", { event_participant_id => $p->id });
    }
    flash info => "Thank you for registering for this event, event updates will be sent via email";
    redirect '/events/future/'.vars->{event}->uuid;
};

get '/:uuid/unregister' => sub {
    my $user = session('user');
    if (!defined($user)) {
        flash error => "Access Denined";
        return redirect '/';
    }
    my $event = vars->{event};
    $event->search_related('lk_user_future_events', { user_id => $user->{id} })->delete();
    $event->search_related('lk_event_participant_future_events', { user_id => $user->{id} }, { join => 'event_participant' })->delete();
    flash info => "Sorry to see you go, hopefully you will attend one of our other events in the future.";
    redirect '/events/future/'.vars->{event}->uuid;
};

1;
