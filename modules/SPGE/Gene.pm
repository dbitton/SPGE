#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-06-25
# Last Modified: 2003-05-01
# Gene class
#
package SPGE::Gene;
use strict;
use SPGE::Base;
use vars qw/@ISA/;
@ISA = qw/SPGE::Base/;

sub new {
  my ($class, $refs) = @_;
  my $self = {
	      'expressions' => [],
	     };
  bless($self, $class);

  for my $k (qw(util id name score genedb_id)) {
    $self->{$k} = $refs->{$k} if(defined $refs->{$k});
  }

  $self->load() if((defined $self->id() || defined $self->name()) && !defined $refs->{'_noload'});

  return $self;
}

sub gene_by_id {
  my ($self, $id) = @_;
  return $self->new({
		     'id' => $id,
		    });
}

sub gene_by_name {
  my ($self, $name) = @_;
  return $self->new({
		     'name' => $name,
		    });
}

sub id {
  my ($self, $id) = @_;
  $self->{'id'} = $id if(defined $id);
  return $self->{'id'};
}

sub name {
  my ($self, $name) = @_;
  $self->{'name'} = $name if(defined $name);
  return $self->{'name'};
}

sub genedb_id {
  my ($self, $genedb_id) = @_;
  $self->{'genedb_id'} = $genedb_id if(defined $genedb_id);
  return $self->{'genedb_id'};
}

sub score {
  my ($self, $score) = @_;
  $self->{'score'} = $score if(defined $score);
  return $self->{'score'};
}

sub load {
  my ($self) = @_;

  my $query = undef;

  if(defined $self->id()) {
    my $qid = $self->dbh->quote($self->id());
    $query = qq(id=$qid);

  } elsif(defined $self->name()) {
    my $qname = $self->dbh->quote($self->name());
    $query = qq(name=$qname);
  }

  return if(!defined $query);

  my $sth = $self->dbh->prepare(qq(SELECT id,name,genedb_id
				   FROM   gene
				   WHERE  $query LIMIT 1));
  $sth->execute();

  my $ref = $sth->fetchrow_hashref();
  $sth->finish();

  if(!defined $ref->{'name'} && !defined $ref->{'id'}) {
    $self->name("unknown");
    $self->id(0);
    $self->genedb_id("");
  } else {
    $self->name($ref->{'name'});
    $self->id($ref->{'id'});
    $self->genedb_id($ref->{'genedb_id'});
  }
}

sub all_genes {
  my ($self) = @_;
  my $sth = $self->dbh->prepare(qq(SELECT id,name,genedb_id
				   FROM   gene
				   ORDER BY id));
  $sth->execute();
  my @genes = ();

  while(my $ref = $sth->fetchrow_hashref()) {
    push @genes, SPGE::Gene->new({
	'id' => $ref->{'id'},
	'name' => $ref->{'name'},
	'genedb_id' => $ref->{'genedb_id'},
	'util' => $self->util(),
	'_noload' => 1,
    });
  }
  $sth->finish();
  return @genes;
}

sub expressions {
  my ($self, @eset) = @_;

  if(scalar @eset == 0) {
    if(scalar @{$self->{'expressions'}} == 0) {
      my ($package, $filename, $line) = caller();
      if($package ne "SPGE::Experiment") {
	warn qq(SPGE::Gene must be loaded first via SPGE::Experiment to retrieve expression data.);
      }
    }
  } else {
    @{$self->{'expressions'}} = sort { $a->time_point_id() <=> $b->time_point_id() }  @eset;
  }

  return @{$self->{'expressions'}};
}

sub expression_by_time_point_id {
  my ($self, $tpid) = @_;

  my @tmp = grep { $_->time_point_id() == $tpid } $self->expressions();

  if(scalar @tmp > 1) {
    warn qq(Weird results in SPGE::Gene::expression_by_time_point_id for $tpid.);
  }

  return $tmp[0];
}
1;
