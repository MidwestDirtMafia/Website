use utf8;
package Mdm::DB::Result::LkEventParticipantFutureEvent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::LkEventParticipantFutureEvent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<LK_event_participant_future_event>

=cut

__PACKAGE__->table("LK_event_participant_future_event");

=head1 ACCESSORS

=head2 event_participant_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 future_event_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_participant_id",
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
);

=head1 UNIQUE CONSTRAINTS

=head2 C<uq_event_part>

=over 4

=item * L</event_participant_id>

=item * L</future_event_id>

=back

=cut

__PACKAGE__->add_unique_constraint("uq_event_part", ["event_participant_id", "future_event_id"]);

=head1 RELATIONS

=head2 event_participant

Type: belongs_to

Related object: L<Mdm::DB::Result::EventParticipant>

=cut

__PACKAGE__->belongs_to(
  "event_participant",
  "Mdm::DB::Result::EventParticipant",
  { event_participant_id => "event_participant_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-16 22:08:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:q9a77yLc27jtlAlYbPkSPQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
