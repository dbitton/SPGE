#########
# Author: rmp
# Maintainer: rmp
# Created: 2002
# Last Modified: 2003-05-01
# SPGE viewer data container for groups of experiments
#
package SPGE::ExperimentGroup;
use strict;
use SPGE::Base;
use vars qw/@ISA/;
@ISA = qw/SPGE::Base/;

sub new {
  my ($class, $refs) = @_;
  my $self = {
	     };
  bless($self, $class);

  for my $k (qw(util id description time_scale groupstyle gene_names)) {
    $self->{$k} = $refs->{$k} if(defined $refs->{$k});
  }

  $self->load() unless(defined $refs->{'_noload'});

  return $self;
}

sub id {
  my ($self, $id) = @_;
  $self->{'id'} = $id if(defined $id);
  return $self->{'id'};
}

sub description {
  my ($self, $description) = @_;
  $self->{'description'} = $description if(defined $description);
  return $self->{'description'};
}

sub time_scale {
  my ($self, $time_scale) = @_;
  $self->{'time_scale'} = $time_scale if(defined $time_scale);
  return $self->{'time_scale'};
}

sub groupstyle {
  my ($self, $groupstyle) = @_;
  $self->{'groupstyle'} = $groupstyle if(defined $groupstyle);
  return $self->{'groupstyle'};
}

sub load {
  my ($self) = @_;
  my $qid = $self->dbh->quote($self->id());
  my $sth = $self->dbh->prepare(qq(SELECT id,description,time_scale,groupstyle
				   FROM   experiment_group
				   WHERE  id=$qid));
  $sth->execute();
  my $tmp = $sth->fetchrow_arrayref();
  $self->id($tmp->[0]);
  $self->description($tmp->[1]);
  $self->time_scale($tmp->[2]);
  $self->groupstyle($tmp->[3]);
  $sth->finish();
}

sub groups {
  my ($self) = @_;
  $self      = $self->new() if(!ref($self));
  my $sth    = $self->dbh->prepare(qq(SELECT id,description
				      FROM   experiment_group
				      ORDER BY id DESC));
  $sth->execute();
  my @tmp = ();
  while (my $ref = $sth->fetchrow_arrayref()) {
    push @tmp, SPGE::ExperimentGroup->new({
					   'id'          => $ref->[0],
					   'description' => $ref->[1],
					   '_noload'     => 1,
					   'util'        => $self->util(),
					  });
  }
  return @tmp;
}

sub experiments {
  my ($self) = @_;
  $self      = $self->new() if(!ref($self));


  if(!exists $self->{'experiments'}) {
    my $qid = $self->dbh->quote($self->id());
    my $sth = $self->dbh->prepare(qq(SELECT id,name,experiment_group_id
				     FROM   experiment
				     WHERE  experiment_group_id=$qid
				     ORDER BY id));
    $sth->execute();
    my @tmp = ();
    while (my $ref = $sth->fetchrow_arrayref()) {
      push @tmp, SPGE::Experiment->new({
					'id'                  => $ref->[0],
					'name'                => $ref->[1],
					'experiment_group_id' => $ref->[2],
					'_noload'             => 1,
					'util'                => $self->util(),
					'gene_names'          => $self->{'gene_names'},
				       });
    }
    $self->{'experiments'} = \@tmp;
  }

  return @{$self->{'experiments'}};
}

sub length {
  my ($self) = @_;
  my $tmp = 0;
  for my $e ($self->experiments()) {
    $tmp += $e->length();
  }
  return $tmp;
}

1;
