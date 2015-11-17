use utf8;
package Mdm::DB::Result::News;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mdm::DB::Result::News

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<news>

=cut

__PACKAGE__->table("news");

=head1 ACCESSORS

=head2 news_id

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
  size: 200

=head2 content

  data_type: 'text'
  is_nullable: 0

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "news_id",
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
  { data_type => "char", is_nullable => 0, size => 200 },
  "content",
  { data_type => "text", is_nullable => 0 },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</news_id>

=back

=cut

__PACKAGE__->set_primary_key("news_id");

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-16 23:50:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EpKuHXg5XMPL48YoSXSV1Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
