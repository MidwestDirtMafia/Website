use utf8;
package Mdm::DB::Result::SupportProfile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::SupportProfile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<support_profile>

=cut

__PACKAGE__->table("support_profile");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 byline

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 bio

  data_type: 'text'
  is_nullable: 0

=head2 vehicle

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 vehicle_description

  data_type: 'text'
  is_nullable: 0

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "byline",
  { data_type => "char", is_nullable => 0, size => 255 },
  "bio",
  { data_type => "text", is_nullable => 0 },
  "vehicle",
  { data_type => "char", is_nullable => 0, size => 255 },
  "vehicle_description",
  { data_type => "text", is_nullable => 0 },
  "created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Mdm::DB::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Mdm::DB::Result::User",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-12 22:56:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2ihoRGRRWSdbQ8+Bq3otVg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
