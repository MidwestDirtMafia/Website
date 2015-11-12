use utf8;
package Mdm::DB::Result::PastEvent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::PastEvent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<past_event>

=cut

__PACKAGE__->table("past_event");

=head1 ACCESSORS

=head2 past_event_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 title

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 start_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 end_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 logo_image

  data_type: 'char'
  is_nullable: 0
  size: 64

=head2 banner_image

  data_type: 'char'
  is_nullable: 0
  size: 64

=head2 published

  data_type: 'tinyint'
  default_value: 0
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

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 36

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 byline

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 summary

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "past_event_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "title",
  { data_type => "char", is_nullable => 0, size => 255 },
  "start_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "end_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "logo_image",
  { data_type => "char", is_nullable => 0, size => 64 },
  "banner_image",
  { data_type => "char", is_nullable => 0, size => 64 },
  "published",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
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
  "uuid",
  { data_type => "char", is_nullable => 0, size => 36 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "byline",
  { data_type => "char", is_nullable => 0, size => 255 },
  "summary",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</past_event_id>

=back

=cut

__PACKAGE__->set_primary_key("past_event_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<title_UNIQUE>

=over 4

=item * L</title>

=back

=cut

__PACKAGE__->add_unique_constraint("title_UNIQUE", ["title"]);

=head2 C<uuid_UNIQUE>

=over 4

=item * L</uuid>

=back

=cut

__PACKAGE__->add_unique_constraint("uuid_UNIQUE", ["uuid"]);

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-12 02:07:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dAUDGbTEttCcPtfOQQAQ5w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
