use utf8;
package Mdm::DB::Result::FutureEvent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::FutureEvent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<future_event>

=cut

__PACKAGE__->table("future_event");

=head1 ACCESSORS

=head2 future_event_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 36

=head2 private_uuid

  data_type: 'char'
  is_nullable: 0
  size: 36

=head2 future_event_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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

=head2 byline

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

=head2 archived

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 reg_open

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 private_registration

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 participant_limit

  data_type: 'integer'
  is_nullable: 1

=head2 summary

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 partner_link

  data_type: 'text'
  is_nullable: 1

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
  "future_event_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 36 },
  "private_uuid",
  { data_type => "char", is_nullable => 0, size => 36 },
  "future_event_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
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
  "byline",
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
  "archived",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "reg_open",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "private_registration",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "participant_limit",
  { data_type => "integer", is_nullable => 1 },
  "summary",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "partner_link",
  { data_type => "text", is_nullable => 1 },
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

=item * L</future_event_id>

=back

=cut

__PACKAGE__->set_primary_key("future_event_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<private_uuid_UNIQUE>

=over 4

=item * L</private_uuid>

=back

=cut

__PACKAGE__->add_unique_constraint("private_uuid_UNIQUE", ["private_uuid"]);

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

=head2 event_communications

Type: has_many

Related object: L<Mdm::DB::Result::EventCommunication>

=cut

__PACKAGE__->has_many(
  "event_communications",
  "Mdm::DB::Result::EventCommunication",
  { "foreign.future_event_id" => "self.future_event_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 future_event_type

Type: belongs_to

Related object: L<Mdm::DB::Result::FutureEventType>

=cut

__PACKAGE__->belongs_to(
  "future_event_type",
  "Mdm::DB::Result::FutureEventType",
  { future_event_type_id => "future_event_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 lk_event_participant_future_events

Type: has_many

Related object: L<Mdm::DB::Result::LkEventParticipantFutureEvent>

=cut

__PACKAGE__->has_many(
  "lk_event_participant_future_events",
  "Mdm::DB::Result::LkEventParticipantFutureEvent",
  { "foreign.future_event_id" => "self.future_event_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 lk_user_future_events

Type: has_many

Related object: L<Mdm::DB::Result::LkUserFutureEvent>

=cut

__PACKAGE__->has_many(
  "lk_user_future_events",
  "Mdm::DB::Result::LkUserFutureEvent",
  { "foreign.future_event_id" => "self.future_event_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-04-05 19:23:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4Wvg04nherGwzt6xlpvueg

__PACKAGE__->many_to_many (
    users => "lk_user_future_events",
    'user'
);

sub registeredParticipants {
    my $self = shift;
    return $self->users->count();
}

sub isUserRegistered {
    my ($self, $user_id) = @_;
    return $self->search_related("lk_user_future_events", { user_id => $user_id })->count();
}

sub supportDrivers {
    my $self = shift;
    return $self->users->search({ support => 1 });
}
# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
