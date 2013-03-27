#########
# Author: rmp
# Maintainer: rmp
# Created: 2003-08-08
# Last Modified: 2003-08-08
# ExpressionBin class
#
package SPGE::ExpressionBin;
use strict;
use SPGE::Base;
use vars qw/@ISA/;
@ISA = qw/SPGE::Base/;

sub new {
  my ($class, $refs) = @_;
  my $self = {
	      'time' => 0,
	     };
  bless($self, $class);

  for my $k (qw(util id time_point_id bin_start bin_end)) {
    $self->{$k} = $refs->{$k} if(defined $refs->{$k});
  }

  $self->load() if(defined $self->id() && !defined $refs->{'_noload'});

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

sub bin_start {
  my ($self, $bin_start) = @_;
  $self->{'bin_start'} = $bin_start if(defined $bin_start);
  return $self->{'bin_start'};
}

sub bin_end {
  my ($self, $bin_end) = @_;
  $self->{'bin_end'} = $bin_end if(defined $bin_end);
  return $self->{'bin_end'};
}

sub load {
  my ($self) = @_;

  $self->id() or return;

  my $qid = $self->dbh->quote($self->id());
  my $sth = $self->dbh->prepare(qq(SELECT id,time_point_id,gene_id,data
				   FROM   expression
				   WHERE  id=$qid));
  $sth->execute();

  ($self->{'id'},$self->{'time_point_id'},$self->{'bin_start'},$self->{'bin_end'}) = $sth->fetchrow_array();
  $sth->finish();
}

1;
