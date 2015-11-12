use utf8;
package Mdm::DB::Result::UserStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::UserStatus

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user_status>

=cut

__PACKAGE__->table("user_status");

=head1 ACCESSORS

=head2 user_status_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 status

  data_type: 'char'
  is_nullable: 0
  size: 50

=cut

__PACKAGE__->add_columns(
  "user_status_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "status",
  { data_type => "char", is_nullable => 0, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_status_id>

=back

=cut

__PACKAGE__->set_primary_key("user_status_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<status_UNIQUE>

=over 4

=item * L</status>

=back

=cut

__PACKAGE__->add_unique_constraint("status_UNIQUE", ["status"]);

=head1 RELATIONS

=head2 users

Type: has_many

Related object: L<Mdm::DB::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "Mdm::DB::Result::User",
  { "foreign.user_status_id" => "self.user_status_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-11 16:39:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B2q6C6OcwFIjbzXuJztx7g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
