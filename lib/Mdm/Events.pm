package Mdm::Events;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::FlashMessage;
use UUID::Tiny ':std';
use Data::Dumper;
use Mdm::Utils;
use Clone 'clone';

use Mdm::Events::Future;
use Mdm::Events::Past;

prefix '/events';




1;
