#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-06-25
# Last Modified: 2003-05-01
# TimePoint class
#
package SPGE::TimePoint;
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

  for my $k (qw(util id experiment_id time)) {
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

sub time {
  my ($self, $time) = @_;
  $self->{'time'} = $time if(defined $time);
  return $self->{'time'};
}

sub bins {
  my ($self) = @_;

  my $qid = $self->dbh->quote($self->id());
  my $sth = $self->dbh->prepare(qq(SELECT id,time_point_id,bin_start,bin_end
                                   FROM   expression_bin
				   WHERE  time_point_id=$qid));
  $sth->execute();
  my @tmp = ();
  while (my $ref = $sth->fetchrow_arrayref()) {
    push @tmp, SPGE::ExpressionBin->new({
					 'id'            => $ref->[0],
					 'time_point_id' => $ref->[1],
					 'bin_start'     => $ref->[2],
					 'bin_end'       => $ref->[3],
					 '_noload'       => 1,
					 'util'          => $self->util(),
					});
  }
  return @tmp;

}

sub load {
  my ($self) = @_;

  my $qid = $self->dbh->quote($self->id());

  my $sth = $self->dbh->prepare(qq(SELECT id,experiment_id,time
				   FROM   time_point
				   WHERE  id=$qid LIMIT 1));
  $sth->execute();
  my $ref = $sth->fetchrow_hashref();
  $sth->finish();

  $self->id($ref->{'id'});
  $self->experiment_id($ref->{'experiment_id'});
  $self->time($ref->{'time'});
}

1;
