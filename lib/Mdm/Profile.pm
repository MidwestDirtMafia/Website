package Mdm::Profile;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use Data::Dumper;


prefix '/profile';
hook 'before' => sub {
    return if (request->path_info !~ m{^/profile});
    my $user = session('user');
    if (!defined($user)) {
        flash error => "You must log in to access your profile";
        return redirect '/';
    }
    my $u = schema->resultset("User")->find({ user_id => $user->{id} });
    if (!defined($u)) {
        flash error => "Something went wrong we could not find your profile";
        return redirect '/';
    }
    var user => $u;
};

get '/' => sub {
    template 'user/profile', { user => vars->{user} };
};

post '/' => sub {
    my $u = vars->{user};
    my $reason = param 'reason';
    if (!defined($reason)) {
        flash error => "Unknown action requested";
        template 'user/profile', { user => $u };
    }
    if ($reason eq 'password') {
        my $curPass = param 'current';
        my $password = param 'password';
        if (!Crypt::SaltedHash->validate($u->password, $curPass)) {
            flash error => 'Invalid password.';
            return template 'user/profile', { user => $u };
        }
        my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
        $csh->add($password);
        my $pass = $csh->generate;
        $u->update({ password => $pass });
        flash info => "Password changed";
    } elsif ($reason eq "save") {
        my $first_name = param('firstName');
        my $last_name = param('lastName');
        my $email = param('email');
        my $emergency_contact_name = param('emergency_contact_name');
        my $emergency_contact_phone = param('emergency_contact_phone');
        my $medical_info = param('medical_info');
        if (!defined($first_name) || $first_name !~ m/^[A-Za-z]{2,50}$/) {
            flash error => 'Invalid first name';
            return template 'user/profile', { user => $u };
        }
        if (!defined($last_name) || $last_name !~ m/^[A-Za-z]{2,50}$/) {
            flash error => 'Invalid last name';
            return template 'user/profile', { user => $u };
        }
        if (!defined($email) || !Email::Valid->address($email)) {
            flash error => 'Invalid email address or password.';
            return template 'user/profile', { user => $u };
        }
        $u->update({
            first_name              => $first_name,
            last_name               => $last_name,
            email                   => $email,
            emergency_contact_name  => $emergency_contact_name,
            emergency_contact_phone => $emergency_contact_phone,
            medical_info            => $medical_info,
        });
        flash info => "Profile Updated";
    }
    template 'user/profile', { user => $u };
};

get '/support' => sub {
    my $u = vars->{user};
    if ($u->support == 0){
        flash error => "Access Denined";
        return redirect '/profile';
    }

    template 'user/support', { user => $u };
};
post '/support' => sub {
    my $u = vars->{user};
    if ($u->support == 0){
        flash error => "Access Denined";
        return redirect '/profile';
    }
    my $byline = param 'byline';
    my $bio = param 'bio';
    my $vehicle = param 'vehicle';
    my $vehicle_description = param 'vehicle_description';
    if (!defined($byline)) {
        flash error => "Bad Byline";
        return template 'user/support', { user => $u };
    }
    if (!defined($bio)) {
        flash error => "Bad Bio";
        return template 'user/support', { user => $u };
    }
    if (!defined($vehicle)) {
        flash error => "Bad Vehicle Info";
        return template 'user/support', { user => $u };
    }
    if (!defined($vehicle_description)) {
        flash error => "Bad Vehicle Description";
        return template 'user/support', { user => $u };
    }
    my $data = {
        byline => $byline,
        bio => $bio,
        vehicle => $vehicle,
        vehicle_description => $vehicle_description,
    };
    if (defined($u->support_profile)) {
        $u->support_profile->update($data);
    } else {
        $u->create_related("support_profile", $data);
    }
    template 'user/support', { user => $u };
};

post '/participant' => sub {
    my $participant_id = param 'event_participant_id';
    my $data = {
         first_name             => param('first_name'),
         last_name              => param('last_name'),
         emergency_contact_name => param('emergency_contact_name'),
         emergency_contact_phone=> param('emergency_contact_phone'),
         medical_info           => param('medical_info'),
    };

    if (defined($participant_id) && $participant_id ne "") {
        my $p = schema->resultset("EventParticipant")->search({ event_participant_id => $participant_id, user_id => vars->{user}->id }, { rows => 1 })->single();
        if (!defined($p)) {
            status 406;
            return;
        }
        $p->update($data);
    } else {
        $data->{user_id} = vars->{user}->id;
        my $p = schema->resultset("EventParticipant")->create($data);
        $p->insert;
    }
};
get '/participants' => sub {
    my $rs = schema->resultset("EventParticipant")->search(
        {
            user_id => vars->{user}->id,
        },
        {
            order => { first_name => "DESC" },
        }
    );
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $users = [];
    while (my $u = $rs->next) {
        push @$users, $u;
    }
    return to_json $users;
};

1;
