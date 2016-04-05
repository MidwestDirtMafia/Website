use utf8;
package Mdm::DB::Result::EventCommunication;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::EventCommunication

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<event_communication>

=cut

__PACKAGE__->table("event_communication");

=head1 ACCESSORS

=head2 event_communication_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 future_event_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 subject

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 content

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_communication_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "future_event_id",
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
  "subject",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "content",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</event_communication_id>

=back

=cut

__PACKAGE__->set_primary_key("event_communication_id");

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

=head2 lk_user_event_communications

Type: has_many

Related object: L<Mdm::DB::Result::LkUserEventCommunication>

=cut

__PACKAGE__->has_many(
  "lk_user_event_communications",
  "Mdm::DB::Result::LkUserEventCommunication",
  {
    "foreign.event_communication_id" => "self.event_communication_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-04-05 19:23:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d8VJTOPIqynVFSBNEvE3xQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
