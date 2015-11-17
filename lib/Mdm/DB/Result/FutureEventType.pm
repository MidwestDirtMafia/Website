use utf8;
package Mdm::DB::Result::FutureEventType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::FutureEventType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<future_event_type>

=cut

__PACKAGE__->table("future_event_type");

=head1 ACCESSORS

=head2 future_event_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 type

  data_type: 'char'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "future_event_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "type",
  { data_type => "char", is_nullable => 0, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</future_event_type_id>

=back

=cut

__PACKAGE__->set_primary_key("future_event_type_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<type_UNIQUE>

=over 4

=item * L</type>

=back

=cut

__PACKAGE__->add_unique_constraint("type_UNIQUE", ["type"]);

=head1 RELATIONS

=head2 future_events

Type: has_many

Related object: L<Mdm::DB::Result::FutureEvent>

=cut

__PACKAGE__->has_many(
  "future_events",
  "Mdm::DB::Result::FutureEvent",
  { "foreign.future_event_type_id" => "self.future_event_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-14 16:41:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0Nnd+2GxQkdK0nwCPG6jag


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
