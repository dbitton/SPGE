#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-06-25
# Last Modified: 2003-05-01
# Expression class
#
package SPGE::Expression;
use strict;
use SPGE::Base;
use SPGE::ExpressionBin;
use vars qw/@ISA/;
@ISA = qw/SPGE::Base/;

sub new {
  my ($class, $refs) = @_;
  my $self = {
	      'time' => 0,
	     };
  bless($self, $class);

  for my $k (qw(util id time_point_id gene_id data bin_id)) {
    $self->{$k} = $refs->{$k} if(defined $refs->{$k});
  }

  $self->load() if((defined $self->id() || (defined $self->time_point_id() && defined $self->gene_id())) && !defined $refs->{'_noload'});

  return $self;
}

sub id {
  my ($self, $id) = @_;
  $self->{'id'} = $id if(defined $id);
  return $self->{'id'};
}

sub time_point_id {
  my ($self, $time_point_id) = @_;
  $self->{'time_point_id'} = $time_point_id if(defined $time_point_id);
  return $self->{'time_point_id'};
}

sub gene_id {
  my ($self, $gene_id) = @_;
  $self->{'gene_id'} = $gene_id if(defined $gene_id);
  return $self->{'gene_id'};
}

sub data {
  my ($self, $data) = @_;
  $self->{'data'} = $data if(defined $data);
  return $self->{'data'};
}

sub bin_id {
  my ($self, $bin_id) = @_;
  $self->{'bin_id'} = $bin_id if(defined $bin_id);
  return $self->{'bin_id'};
}

sub bin {
  my $self = shift;
  $self->bin_id() or return;
  return SPGE::ExpressionBin->new({
				   'util' => $self->util(),
				   'id'   => $self->bin_id(),
				  });
}

sub load {
  my ($self) = @_;

  my $query = undef;

  if(defined $self->id()) {
    my $qid = $self->dbh->quote($self->id());
    $query = qq(id=$qid);

  } elsif(defined $self->time_point_id() && defined $self->gene_id()) {
    my $qtpid = $self->dbh->quote($self->time_point_id());
    my $qgid  = $self->dbh->quote($self->gene_id());
    $query = qq(time_point_id=$qtpid AND gene_id=$qgid);
  }

  return if(!defined $query);

  my $sth = $self->dbh->prepare(qq(SELECT id,time_point_id,gene_id,data,bin_id
				   FROM   expression
				   WHERE  $query LIMIT 1));
  $sth->execute();

  my $ref = $sth->fetchrow_hashref();
  $sth->finish();

  $self->id($ref->{'id'});
  $self->time_point_id($ref->{'time_point_id'});
  $self->gene_id($ref->{'gene_id'});
  $self->data($ref->{'data'});
  $self->bin_id($ref->{'bin_id'});
}

1;
