use utf8;
package Mdm::DB::Result::Sponsor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::Sponsor

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sponsor>

=cut

__PACKAGE__->table("sponsor");

=head1 ACCESSORS

=head2 sponsor_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 100

=head2 image

  data_type: 'char'
  is_nullable: 0
  size: 64

=head2 link

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "sponsor_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "char", is_nullable => 0, size => 100 },
  "image",
  { data_type => "char", is_nullable => 0, size => 64 },
  "link",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</sponsor_id>

=back

=cut

__PACKAGE__->set_primary_key("sponsor_id");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-17 00:33:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cZPhciZGiZ5u/DGBQd/yUw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
