package Mdm::Events::Future;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use Dancer::Plugin::Email;
use UUID::Tiny ':std';
use Data::Dumper;
use Mdm::Utils;
use Clone 'clone';
use File::Copy;
use File::Temp qw(tempdir tempfile);
use IO::Uncompress::Unzip qw(unzip $UnzipError) ;
use File::Path qw(remove_tree);
use OpenOffice::OODoc 2.101;
use Try::Tiny;

my $ENCODING = $OpenOffice::OODoc::XPath::LOCAL_CHARSET;

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
        start_date => { '>=' => \"CURRENT_DATE" },
        archived => 0,
    };
    my $user = session('user');
    if (defined($user) && $user->{admin} == 1) {
        $filter = { archived => 0 };
    }

    my $rs = schema->resultset("FutureEvent")->search($filter, 
        {
            prefetch => [
                'user',
                'future_event_type',
            ],
            order_by => { -DESC => 'start_date' }
        }
    );
    while (my $event = $rs->next) {
        push @$events, $event;
    }
    my $archive = [];
    if (defined($user) && $user->{admin} == 1) {
        $filter = { archived => 1 };
        my $rs = schema->resultset("FutureEvent")->search($filter, 
            {
                prefetch => [
                    'user',
                    'future_event_type',
                ]
            }
        );
        while (my $event = $rs->next) {
            push @$archive, $event;
        }
    }
    template 'future/events', { nav_current => "future", events => $events, archived_events => $archive };
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
    $data->{private_uuid} = create_uuid_as_string(UUID_RANDOM);
    $data->{published} = $data->{published} ? 1 :  0;
    $data->{reg_open} = $data->{reg_open} ? 1 : 0;
    $data->{private_registration} = $data->{private_registration} ? 1 : 0;
    $data->{user_id} = session('user')->{id};


    my $event = schema->resultset("FutureEvent")->create($data);
    $event->insert;
    redirect "/events/future/".$data->{uuid};
};

get '/:uuid' => sub {
    my $uuid = params->{uuid};
    my @gps_files;
    for my $type (qw(kmz gpx usr)) {
        if (-e config->{public}."/gps_data/$uuid.$type") {
            push @gps_files, $type;
        }
    }
    my $has_release = 0;
    if (-e config->{public}."/releases/$uuid.pdf") {
        $has_release = 1;
    }
    template 'future/event', { event => vars->{event}, gps_files => \@gps_files, has_release => $has_release };
};

get '/:uuid/gps/:type' => sub {
    my $uuid = params->{uuid};
    my $type = params->{type};
    if ($type !~ m/^(kmz|gpx|usr)$/) {
        flash error => "Invalid gps file type";
        return redirect "/events/future/$uuid";
    }
    my $ctype;
    if ($type eq "kmz") {
        $ctype = "application/vnd.google-earth.kmz";
    } elsif ($type eq "gpx") {
        $ctype = "application/gpx+xml";
    } elsif ($type eq "usr") {
        $ctype = "application/octet-stream";
    }
    send_file("gps_data/$uuid.$type", filename => "route.$type", content_type => $ctype);
};

get '/:uuid/email/:id' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $id = param('id');
    if (!defined($id) || $id !~ m/^\d+$/) {
        flash error => "Invalid email ID";
        return redirect "/events/future/".params->{uuid}."/email";
    }

    my $email = vars->{event}->find_related("event_communications", { event_communication_id => $id });
    if (!defined($email)) {
        flash error => "Invalid email ID";
        return redirect "/events/future/".params->{uuid}."/email";
    }

    template 'future/email-sent', { event => vars->{event}, email => $email };
};

get '/:uuid/release' => sub {
    my $uuid = params->{uuid};
    my $type = params->{type};
    send_file("releases/$uuid.pdf", filename => "release.pdf");
};


get '/:uuid/release/gen' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    template 'future/release', { event => vars->{event} };
};

post '/:uuid/release/gen' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $title = param("title");
    my $organizers = param("organizers");
    if (!defined($title)) {
        flash error => "Title not defined";
        return template 'future/release';
    }
    if (!defined($organizers)) {
        flash error => "Organizers not defined";
        return template 'future/release';
    }
    debug config->{appdir}.'/data/LiabilityDisclaimerTemplate.odt';
    my $doc = odfDocument(file => config->{appdir}.'/data/LiabilityDisclaimerTemplate.odt', local_encoding => $ENCODING)
            or die "File unavailable or non-ODF file\n";

    my @list = $doc->selectElementsByContent("__TITLE__");
    foreach my $e (@list) {
        debug "__TITLE__";
        $doc->substituteText($e, "__TITLE__", $title);
    }
    @list = $doc->selectElementsByContent("__ORGANIZERS__");
    foreach my $e (@list) {
        debug "__ORGANIZERS__";
        $doc->substituteText($e, "__ORGANIZERS__", $organizers);
    }
    my ($fh, $filename) = tempfile();
    close($fh);
    unlink ($filename);
    try {
        $doc->save("$filename.odt");
        $ENV{HOME} = '/tmp';
        my @cmd = (
            config->{lowriter},
            '--headless', '--convert-to', 'pdf',
            "$filename.odt", '--outdir', '/tmp'
        );
        debug "Running convert command: ".join ' ', @cmd;
        system (@cmd);
        move("$filename.pdf", config->{public}."/releases/".params->{uuid}.".pdf");
#        unlink("$filename.odt");
    } catch {
        error $_;
    };
    redirect "/events/future/".params->{uuid};
};

get '/:uuid/email' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    template 'future/email', { event => vars->{event} };
};

post '/:uuid/email' => sub {
    my $user = session('user');
    my $uuid = param('uuid');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $data = {
        subject => param("subject"),
        content => param("body"),
    };
    my $gps_files = param('gps_files');
    my $release = param('release');
    if (!defined($data->{subject})) {
        flash error => "Subject not defined";
        return template 'future/email', $data;
    }
    if (!defined($data->{content})) {
        flash error => "Message not defined";
        return template 'future/email', $data;
    }
    my $event = vars->{event};
    my $com = $event->create_related("event_communications", $data);
    my $users = $event->users;
    while (my $user = $users->next) {
        my $email =  {
            from    => 'Midwest Dirt Mafia <webmaster@midwestdirtmafia.com>',
            to      => $user->first_name." ".$user->last_name." <".$user->email.">",
            subject => $data->{subject},
            body    => $data->{content},
            type    => 'html',
        };
        if (defined($gps_files) && $gps_files eq 'on') {
            $email->{attach} = [];
            for my $type (qw(kmz gpx usr)) {
                if (-e config->{public}."/gps_data/$uuid.$type") {
                    push @{$email->{attach}}, {
                        Path => config->{public}."/gps_data/$uuid.$type",
                        Filename => "route.$type",
                    };
                }
            }
        }
        if (defined($release) && $release eq 'on') {
            if (!defined($email->{attach})) {
                $email->{attach} = [];
            }
            if (-e config->{public}."/releases/$uuid.pdf") {
                push @{$email->{attach}}, {
                    Path => config->{public}."/releases/$uuid.pdf",
                    Filename => "release.pdf",
                };
            }
        }
        email $email;
        $com->create_related("lk_user_event_communications", { user_id => $user->id });
    }
    template 'future/email', { event => vars->{event} };
};

get '/:uuid/gps' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    template 'future/gps', { event => vars->{event} };
};

post '/:uuid/gps' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    my $upload = upload('gpsFile');
    debug 'user uploaded [' . ($upload->filename // 'no filename') . '] with type [' . ($upload->type // 'no type') . '] stored in [' . $upload->tempname . ']';
    my $uploaded_file = $upload->tempname;
    my $uploaded_sha256 = fileSHA256($uploaded_file);
    my $dir = tempdir();
    debug "Processing gps file in $dir";
    my $status = unzip $uploaded_file => "$dir/doc.kml", Name => 'doc.kml'
        or die "unzip failed: $UnzipError\n";
    my @gpx_cmd = (
        config->{gpsbabel},
        '-i', 'kml', '-o', 'gpx',
        '-f', "$dir/doc.kml",
        '-F', "$dir/doc.gpx",
    );
    my @usr_cmd = (
        config->{gpsbabel},
        '-i', 'kml', '-o', 'lowranceusr',
        '-f', "$dir/doc.kml",
        '-F', "$dir/doc.usr",
    );
    system(@gpx_cmd);
    system(@usr_cmd); 

    move ($uploaded_file, config->{public}."/gps_data/".params->{uuid}.".kmz");
    move ("$dir/doc.gpx", config->{public}."/gps_data/".params->{uuid}.".gpx");
    move ("$dir/doc.usr", config->{public}."/gps_data/".params->{uuid}.".usr");

    remove_tree($dir);

    redirect "/events/future/".params->{uuid};
};

get '/:uuid/participants' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return template 'index';
    }
    template 'future/participants', { event => vars->{event} };
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

get '/:uuid/archive' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ archived => 1});
    redirect "/events/future/".vars->{event}->uuid;
};

get '/:uuid/unarchive' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    vars->{event}->update({ archived => 0});
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
