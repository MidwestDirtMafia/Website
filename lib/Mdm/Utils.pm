package Mdm::Utils;
use strict;
use warnings;

use Dancer ':syntax';
use Digest::SHA;
use File::Copy;

use Exporter qw/import/;
our @EXPORT = qw/ handle_image_upload /;


sub handle_image_upload {
    my ($upload) = @_;
    debug 'user uploaded [' . ($upload->filename // 'no filename') . '] with type [' . ($upload->type // 'no type') . '] stored in [' . $upload->tempname . ']';
    my $uploaded_file = $upload->tempname;

    # Get the SHA256 of the file
    my $uploaded_sha256 = fileSHA256($uploaded_file);
    debug 'file sha256: ' . $uploaded_sha256;
    if (!-e config->{public}."/image_data/".$uploaded_sha256) {
        move ($uploaded_file, config->{public}."/image_data/".$uploaded_sha256);
    }
    return $uploaded_sha256;
}

sub fileSHA256 {
    my ($filename) = @_;
    return uc Digest::SHA->new(256)->addfile($filename)->hexdigest;
}

1;
