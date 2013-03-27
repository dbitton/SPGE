#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-06-25
# Last Modified: 2003-05-01
# Meiosis class
#
package SPGE::Meiosis;
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

  for my $k (qw(util id experiment_id time_start time_duration description)) {
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

sub experiment_id {
  my ($self, $experiment_id) = @_;
  $self->{'experiment_id'} = $experiment_id if(defined $experiment_id);
  return $self->{'experiment_id'};
}

sub time_start {
  my ($self, $time_start) = @_;
  $self->{'time_start'} = $time_start if(defined $time_start);
  return $self->{'time_start'};
}

sub time_duration {
  my ($self, $time_duration) = @_;
  $self->{'time_duration'} = $time_duration if(defined $time_duration);
  return $self->{'time_duration'};
}

sub time_end {
  my ($self)   = @_;
  my $start    = $self->time_start() || 0;
  my $duration = $self->time_duration() || 0;
  return $start+$duration;
}

sub description {
  my ($self, $description) = @_;
  $self->{'description'} = $description if(defined $description);
  return $self->{'description'};
}

sub load {
  my ($self) = @_;

  my $qid = $self->dbh->quote($self->id());

  my $sth = $self->dbh->prepare(qq(SELECT id,experiment_id,time_start,time_duration,description
				   FROM   meiosis_stage
				   WHERE  id=$qid LIMIT 1));
  $sth->execute();
  my $ref = $sth->fetchrow_hashref();
  $sth->finish();


  for my $f (qw(id experiment_id time_start time_duration description)) {
    $self->$f($ref->{$f});
  }
}

1;
