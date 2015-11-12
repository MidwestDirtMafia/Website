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

use Mdm::Events;
use Mdm::Image;

prefix '/';

get '/' => sub {
    template 'index', { nav_current => "home" };
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
    redirect '/';
};

get '/logout' => sub {
    session->destroy;
    redirect '/';
};

get '/register' => sub {
    if (session('user')) {
        flash error => 'You are already registered and logged in.';
        return template 'index';
    }
    template 'register';
};

post '/register' => sub {
    my $email = param 'email';
    my $password = param 'password';
    my $fName = param 'firstName';
    my $lName = param 'lastName';

    if (!defined($email) || !Email::Valid->address($email)) {
        flash error => 'Invalid email address';
        return template 'register', { email => $email, firstName => $fName, lastName => $lName };
    }
    if (!defined($password)) {
        flash error => 'Invalid password';
        return template 'register', { email => $email, firstName => $fName, lastName => $lName };
    }
    if (!defined($fName) || $fName !~ m/^[A-Za-z]{2,50}$/) {
        flash error => 'Invalid first name';
        return template 'register', { email => $email, firstName => $fName, lastName => $lName };
    }
    if (!defined($lName) || $lName !~ m/^[A-Za-z]{2,50}$/) {
        flash error => 'Invalid last name';
        return template 'register', { email => $email, firstName => $fName, lastName => $lName };
    }

    my $user = schema->resultset("User")->find({ email => $email });
    if (defined($user)) {
        flash error => 'This email address is already registered.';
        return template 'register', { email => $email, firstName => $fName, lastName => $lName };
    }

    my $uuid = create_uuid_as_string(UUID_RANDOM);
    my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
    $csh->add($password);
    my $pass = $csh->generate;

    $user = schema->resultset('User')->create({
        first_name => $fName,
        last_name => $lName,
        email => $email,
        password => $pass,
        user_status_id => 1,
        token => $uuid,
    });
    $user->insert;
    email {
        from    => 'Midwest Dirt Mafia <webmaster@midwestdirtmafia.com>',
        to      => "$fName $lName <$email>",
        subject => 'Midwest Dirt Fafia Account Activation',
        body    => "Dear $fName,\nPlease use the following link to activate your account: ".config->{baseurl}."/activate/$uuid\n\nThanks\nThe Midwest Dirt Mafia Team.",
    };
    template 'registered';
};

get '/activate/:uuid' => sub {
    my $uuid = param('uuid');
    if (!is_uuid_string($uuid)) {
        flash error => "Please check the link you used to activate your account";
        return template 'index';
    }
    my $user = schema->resultset("User")->find({ token => $uuid });
    if (!defined($user)) {
        flash error => "Please check the link you used to activate your account";
        return template 'index';
    }
    if ($user->user_status_id != 1) {
        flash error => "Your account is already activated please login";
        return template 'index';
    }
    $user->update({ user_status_id => 2 });
    template 'activated';
};
1;
