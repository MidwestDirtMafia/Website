package Mdm::About;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use Data::Dumper;


prefix '/about';

get '/' => sub {
    my $rs = schema->resultset("User")->search({ support => 1 }, { prefetch => [ 'support_profile' ] });
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $users = [];
    while (my $u = $rs->next) {
        delete $u->{password};
        delete $u->{token};
        push @$users, $u;
    }
    template 'about/index', { support => $users };
};

get '/support/:id' => sub {
    my $id = param 'id';
    if (!defined($id) || $id !~ m/^\d+$/) {
        flash error => "Invalid support driver";
        return redirect '/about';
    }
    my $user = schema->resultset("User")->search({ 'me.user_id' => $id, support => 1 }, { rows => 1, prefetch => [ 'support_profile' ] })->single();
    if (!defined($user)) {
        flash error => "Invalid support driver";
        return redirect '/about';
    }
    my @participants;
    my $rs = $user->event_participants;
    while (my $p = $rs->next) { push @participants, $p; }
    return template 'about/support', { user => $user, participants => \@participants };
};
1;
