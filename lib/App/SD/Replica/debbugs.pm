package App::SD::Replica::debbugs;
use Moose;
extends qw/Prophet::ForeignReplica/;

use Params::Validate qw(:all);
use Memoize;

use Prophet::ChangeSet;

use constant scheme => 'debbugs';

# FIXME: what should this actually be?
has debbugs => ( isa => 'Net::Debbugs', is => 'rw');
has debbugs_url => ( isa => 'Str', is => 'rw');
has debbugs_query => ( isa => 'Str', is => 'rw');

sub setup {
    my $self = shift;

    # require any specific libs needed by this foreign replica

    # parse the given url
    # my ($foo, $bar, $baz) = $self->{url} =~ m/regex-here/

    # ...
}

sub prophet_has_seen_transaction {
    goto \&App::SD::Replica::RT::prophet_has_seen_transaction;
}

sub record_pushed_transaction {
    goto \&App::SD::Replica::RT::record_pushed_transaction;
}

sub record_pushed_transactions {}

sub remote_id_for_uuid {
    my ( $self, $uuid_for_remote_id ) = @_;


    # XXX: should not access CLI handle
    my $ticket = Prophet::Record->new(
        handle => Prophet::CLI->new->app_handle->handle,
        type   => 'ticket'
    );
    $ticket->load( uuid => $uuid_for_remote_id );
    my $id =  $ticket->prop( $self->uuid . '-id' );
    return $id;
}

sub uuid_for_remote_id {
    my ( $self, $id ) = @_;
    return $self->_lookup_uuid_for_remote_id($id) ||
        $self->uuid_for_url( $self->rt_url . "/ticket/$id" );
}

sub record_pushed_ticket {
    my $self = shift;
    my %args = validate(
        @_,
        {   uuid      => 1,
            remote_id => 1,
        }
    );
    $self->_set_uuid_for_remote_id(%args);
    $self->_set_remote_id_for_uuid(%args);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
