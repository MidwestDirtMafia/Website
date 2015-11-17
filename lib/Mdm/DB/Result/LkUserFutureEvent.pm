use utf8;
package Mdm::DB::Result::LkUserFutureEvent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::LkUserFutureEvent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<LK_user_future_event>

=cut

__PACKAGE__->table("LK_user_future_event");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 future_event_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "future_event_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<uq_user_event>

=over 4

=item * L</user_id>

=item * L</future_event_id>

=back

=cut

__PACKAGE__->add_unique_constraint("uq_user_event", ["user_id", "future_event_id"]);

=head1 RELATIONS

=head2 future_event

Type: belongs_to

Related object: L<Mdm::DB::Result::FutureEvent>

=cut

__PACKAGE__->belongs_to(
  "future_event",
  "Mdm::DB::Result::FutureEvent",
  { future_event_id => "future_event_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-14 21:07:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jbABYOJz+UXAqU+AleUyVw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
