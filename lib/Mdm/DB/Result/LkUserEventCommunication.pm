use utf8;
package Mdm::DB::Result::LkUserEventCommunication;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::LkUserEventCommunication

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<LK_user_event_communication>

=cut

__PACKAGE__->table("LK_user_event_communication");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 event_communication_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 sent

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
  "event_communication_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "sent",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=item * L</event_communication_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id", "event_communication_id");

=head1 RELATIONS

=head2 event_communication

Type: belongs_to

Related object: L<Mdm::DB::Result::EventCommunication>

=cut

__PACKAGE__->belongs_to(
  "event_communication",
  "Mdm::DB::Result::EventCommunication",
  { event_communication_id => "event_communication_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-04-05 19:23:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3SiPbZVFfpBCFW09WkfPWA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
