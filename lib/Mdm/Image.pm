package Mdm::Image;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use Data::Dumper;
use File::LibMagic;
use Mdm::Utils;

my $magic = File::LibMagic->new();

prefix '/image';

get '/:hash' => sub {
    my $hash = param 'hash';
    if (!defined($hash) || $hash !~ m/^[A-F0-9]{64}$/) {
        status 404;
        return;
    }
    if (!-e config->{public}."/image_data/".$hash) {
        status 404;
        return;
    }
    my $info = $magic->info_from_filename(config->{public}."/image_data/".$hash);
    send_file("image_data/".$hash, content_type => $info->{mime_type});
};

post '/' => sub {
    my $user = session('user');
    if (!defined($user) || $user->{admin} == 0) {
        flash error => "Access Denined";
        return redirect '/';
    }
    my $upload = upload('file');
    if (!defined($upload)) {
        flash error => "Access Denined";
        return redirect '/';
    }
    return handle_image_upload($upload);
};
1;
