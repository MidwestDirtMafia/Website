package Mdm;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use Dancer::Plugin::Email;
use Data::Dumper;
use Email::Valid;
use UUID::Tiny ':std';
use Crypt::SaltedHash;
use Authen::SASL;


our $VERSION = '0.1';

use Mdm::About;
use Mdm::Admin;
use Mdm::Events;
use Mdm::Image;
use Mdm::Profile;

hook 'after' => sub {
    return if (request->path_info =~ m/^\/login/);
    return if (request->path_info =~ m/^\/logout/);
    return if (request->path_info =~ m/^\/image/);
    return if (request->path_info =~ m/^image_data/);
    return if (request->path_info =~ m/^gps_data/);
    return if (request->path_info =~ m/^releases/);
    session last_path => (request->path_info);
};

prefix '/';

get '/' => sub {
    my $rs = schema->resultset("Sponsor")->search(undef, { order_by => { -desc => "name" } });
    my @sponsors;
    while (my $a = $rs->next) { push @sponsors, $a; }
    $rs = schema->resultset("News")->search(undef, { order_by => { -desc => "date" }, rows => 5 });
    my @articals;
    while (my $a = $rs->next) { push @articals, $a; }
    template 'index', { articals => \@articals, sponsors => \@sponsors };
};

get '/pwreset' => sub {
    if (session('user')) {
        redirect '/';
    }
    template 'pwreset';
};

post '/pwreset' => sub {
    if (session('user')) {
        redirect '/';
    }
    my $email = param 'email';
    if (!defined($email) || !Email::Valid->address($email)) {
        flash error => 'Invalid email address.';
        return template 'pwreset';
    }
    my $user = schema->resultset("User")->find({ email => $email });
    if (!defined($user)) {
        flash error => 'Reset password failure.';
        return redirect '/login';
    }
    my $token = create_uuid_as_string(UUID_RANDOM);
    $user->update({
        user_status_id => 5,
        token => $token,
    });
    email {
        from    => 'Midwest Dirt Mafia <webmaster@midwestdirtmafia.com>',
        to      => $user->first_name." ".$user->last_name." <".$user->email.">",
        subject => 'Midwest Dirt Mafia Password Reset',
        body    => "Dear ".$user->first_name.",\nPlease use the following link to reset your password: ".config->{baseurl}."/pwreset/".$token."\n\nThanks\nThe Midwest Dirt Mafia Team.",
    };
    flash info => 'Please check your email for instructions on how to reset your password.';
    return redirect '/login';

};

get '/pwreset/:uuid' => sub {
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Please check the link you used to reset your password.";
        return redirect '/';
    }
    my $user = schema->resultset("User")->find({ token => $uuid });
    if (!defined($user)) {
        flash error => "Please check the link you used to reset your password.";
        return redirect '/';
    }
    if ($user->user_status_id != 5) {
        flash error => "Invalid password reset link.";
        return redirect '/login';
    }
    template 'newpassword';
};
post '/pwreset/:uuid' => sub {
    my $uuid = param('uuid');
    my $password = param 'password';

    if (!is_uuid_string($uuid)) {
        flash error => "Please check the link you used to reset your password.";
        return redirect '/';
    }
    if (!defined($password) && $password ne "") {
        flash error => 'Invalid password';
        return template 'newpassword';
    }
    my $user = schema->resultset("User")->find({ token => $uuid });
    if (!defined($user)) {
        flash error => "Please check the link you used to reset your password.";
        return redirect '/';
    }
    if ($user->user_status_id != 5) {
        flash error => "Invalid password reset link.";
        return redirect '/login';
    }
    my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
    $csh->add($password);
    $user->update({
        password => $csh->generate,
        user_status_id => 2,
    });
    flash info => "Password reset please log in with your new password.";
    redirect '/login';
};


get '/login' => sub {
    if (session('user')) {
        redirect '/';
    }
    template 'login';
};

post '/login' => sub {
    if (session('user')) {
        redirect '/';
    }
    my $email = param 'email';
    my $password = param 'password';

    if (!defined($email) || !Email::Valid->address($email)) {
        flash error => 'Invalid email address or password.';
        return template 'login';
    }
    if (!defined($password)) {
        flash error => 'Invalid email address or password.';
        return template 'login';
    }
    my $user = schema->resultset("User")->find({ email => $email });
    if (!defined($user)) {
        flash error => 'Invalid email address or password.';
        return template 'login';
    }
    if (!Crypt::SaltedHash->validate($user->password, $password)) {
        flash error => 'Invalid email address or password.';
        return template 'login';
    }
    if ($user->user_status_id == 1) {
        flash error => 'Account has not been activated please check your email for activation instructions.';
        return template 'login';
    }
    if ($user->user_status_id != 2) {
        flash error => 'Account disabled please email us to re-activate your account.';
        return template 'login';
    }
    session user => {
        first_name  => $user->first_name,
        last_name   => $user->last_name,
        email       => $user->email,
        admin       => $user->admin,
        id          => $user->id,
    };
    flash info => "Welcome back ".$user->first_name;
    if (session('last_path')) {
        return redirect session('last_path');
    } else {
        return redirect '/';
    }
};

get '/logout' => sub {
    session user => undef;
    if (session('last_path')) {
        return redirect session('last_path');
    } else {
        return redirect '/';
    }
};

get '/register' => sub {
    if (session('user')) {
        flash error => 'You are already registered and logged in.';
        return redirect '/';
    }
    template 'user/register';
};

post '/register' => sub {
    if (session('user')) {
        flash error => "You are already registered";
        redirect '/';
    }
    my $data = {
        email => param('email'),
        password => param('password'),
        first_name => param('first_name'),
        last_name => param('last_name'),
        emergency_contact_name  => param('emergency_contact_name'),
        emergency_contact_phone  => param('emergency_contact_phone'),
        medical_info => param('medical_info'),
    };

    if (!defined($data->{email}) || !Email::Valid->address($data->{email})) {
        flash error => 'Invalid email address';
        return template 'user/register', $data;
    }
    if (!defined($data->{password}) && $data->{password} ne "") {
        flash error => 'Invalid password';
        return template 'user/register', $data;
    }
    if (!defined($data->{first_name}) || $data->{first_name} !~ m/^[A-Za-z]{2,50}$/) {
        flash error => 'Invalid first name';
        return template 'user/register', $data;
    }
    if (!defined($data->{last_name}) || $data->{last_name} !~ m/^[A-Za-z]{2,50}$/) {
        flash error => 'Invalid last name';
        return template 'user/register', $data;
    }
    if (!defined($data->{emergency_contact_name}) || $data->{emergency_contact_name} !~ m/^[A-Za-z ]{2,200}$/) {
        flash error => 'Invalid emergency contact name';
        return template 'user/register', $data;
    }
    if (!defined($data->{emergency_contact_phone}) || $data->{emergency_contact_phone} !~ m/^\d{10}$/) {
        flash error => 'Invalid emergency contact phone';
        return template 'user/register', $data;
    }

    my $user = schema->resultset("User")->find({ email => $data->{email} });
    if (defined($user)) {
        flash error => 'This email address is already registered.';
        return template 'user/register', $data;
    }

    $data->{token} = create_uuid_as_string(UUID_RANDOM);
    my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
    $csh->add($data->{password});
    $data->{password} = $csh->generate;
    $data->{user_status_id} =1;

    $user = schema->resultset('User')->create($data);
    $user->insert;
    email {
        from    => 'Midwest Dirt Mafia <webmaster@midwestdirtmafia.com>',
        to      => $data->{first_name}." ".$data->{last_name}." <".$data->{email}.">",
        subject => 'Midwest Dirt Mafia Account Activation',
        body    => "Dear ".$data->{first_name}.",\nPlease use the following link to activate your account: ".config->{baseurl}."/activate/".$data->{token}."\n\nThanks\nThe Midwest Dirt Mafia Team.",
    };
    template 'user/registered';
};

get '/activate/:uuid' => sub {
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Please check the link you used to activate your account";
        return redirect '/';
    }
    my $user = schema->resultset("User")->find({ token => $uuid });
    if (!defined($user)) {
        flash error => "Please check the link you used to activate your account";
        return redirect '/';
    }
    if ($user->user_status_id != 1) {
        flash error => "Your account is already activated please login";
        return redirect '/login';
    }
    $user->update({ user_status_id => 2 });
    flash info => "Your account is now activated please login.";
    redirect '/login';
};
1;
