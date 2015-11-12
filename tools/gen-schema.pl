#!/usr/bin/env perl
use File::Basename;
use Config::General;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my $install_root = dirname(dirname(__FILE__));

my $config_file = "gen-schema.conf";
my %conf = Config::General::ParseConfig($config_file);

make_schema_at(
    $conf{Database}->{Module},
    { 
        debug => 1,
        dump_directory => "$install_root/../lib/",
    },
    [ 
        $conf{Database}->{DSN},
        $conf{Database}->{User},
        $conf{Database}->{Password},
        {
            loader_class => "DBIx::Class::Schema::Loader::DBI::mysql",
            components => [ 
                "InflateColumn::DateTime",
                "TimeStamp",
            ],
        },
    ],
);
