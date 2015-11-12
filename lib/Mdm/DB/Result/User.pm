use utf8;
package Mdm::DB::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 first_name

  data_type: 'char'
  is_nullable: 0
  size: 100

=head2 last_name

  data_type: 'char'
  is_nullable: 0
  size: 100

=head2 email

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 password

  data_type: 'char'
  is_nullable: 0
  size: 57

=head2 token

  data_type: 'char'
  is_nullable: 1
  size: 36

=head2 user_status_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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

=head2 admin

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "first_name",
  { data_type => "char", is_nullable => 0, size => 100 },
  "last_name",
  { data_type => "char", is_nullable => 0, size => 100 },
  "email",
  { data_type => "char", is_nullable => 0, size => 255 },
  "password",
  { data_type => "char", is_nullable => 0, size => 57 },
  "token",
  { data_type => "char", is_nullable => 1, size => 36 },
  "user_status_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
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
  "admin",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<email_UNIQUE>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("email_UNIQUE", ["email"]);

=head2 C<token_UNIQUE>

=over 4

=item * L</token>

=back

=cut

__PACKAGE__->add_unique_constraint("token_UNIQUE", ["token"]);

=head1 RELATIONS

=head2 past_events

Type: has_many

Related object: L<Mdm::DB::Result::PastEvent>

=cut

__PACKAGE__->has_many(
  "past_events",
  "Mdm::DB::Result::PastEvent",
  { "foreign.user_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 upcomming_events

Type: has_many

Related object: L<Mdm::DB::Result::UpcommingEvent>

=cut

__PACKAGE__->has_many(
  "upcomming_events",
  "Mdm::DB::Result::UpcommingEvent",
  { "foreign.user_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_status

Type: belongs_to

Related object: L<Mdm::DB::Result::UserStatus>

=cut

__PACKAGE__->belongs_to(
  "user_status",
  "Mdm::DB::Result::UserStatus",
  { user_status_id => "user_status_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-12 02:07:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M8OsnEmvZZe3lcDN7ExB3A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
