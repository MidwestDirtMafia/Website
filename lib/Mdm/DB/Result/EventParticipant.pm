use utf8;
package Mdm::DB::Result::EventParticipant;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::EventParticipant

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<event_participant>

=cut

__PACKAGE__->table("event_participant");

=head1 ACCESSORS

=head2 event_participant_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 first_name

  data_type: 'char'
  is_nullable: 0
  size: 100

=head2 last_name

  data_type: 'char'
  is_nullable: 0
  size: 100

=head2 emergency_contact_name

  data_type: 'char'
  is_nullable: 0
  size: 200

=head2 emergency_contact_phone

  data_type: 'char'
  is_nullable: 0
  size: 10

=head2 medical_info

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "event_participant_id",
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
  "first_name",
  { data_type => "char", is_nullable => 0, size => 100 },
  "last_name",
  { data_type => "char", is_nullable => 0, size => 100 },
  "emergency_contact_name",
  { data_type => "char", is_nullable => 0, size => 200 },
  "emergency_contact_phone",
  { data_type => "char", is_nullable => 0, size => 10 },
  "medical_info",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</event_participant_id>

=back

=cut

__PACKAGE__->set_primary_key("event_participant_id");

=head1 RELATIONS

=head2 lk_event_participant_future_events

Type: has_many

Related object: L<Mdm::DB::Result::LkEventParticipantFutureEvent>

=cut

__PACKAGE__->has_many(
  "lk_event_participant_future_events",
  "Mdm::DB::Result::LkEventParticipantFutureEvent",
  { "foreign.event_participant_id" => "self.event_participant_id" },
  { cascade_copy => 0, cascade_delete => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-16 22:08:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IWgDOjo+OiOaO3aMxw2f/A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
