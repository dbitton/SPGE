#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-06-28
# Last Modified: 2003-05-01
# Gene Synonym class
#
package SPGE::GeneSynonym;
use strict;
use SPGE::Base;
use vars qw/@ISA/;
@ISA = qw/SPGE::Base/;

sub new {
  my ($class, $refs) = @_;
  my $self = {
	      'data' => [],
             };
  bless($self, $class);

  for my $k (qw(util id gene_id name synonym fuzzy)) {
    $self->{$k} = $refs->{$k} if(defined $refs->{$k});
  }

  $self->load() if((defined $self->id()        ||
		    defined $self->gene_id()   ||
		    defined $self->name() ||
		    defined $self->synonym()) &&
		   !defined $refs->{'_noload'});

  return $self;
}

sub load {
  my ($self) = @_;

  my $query = undef;

  if(defined $self->id()) {
    my $qid = $self->dbh->quote($self->id());
    $query  = "s.id=$qid";

  } elsif(defined $self->synonym()) {
    my $match = "=";
    my $qgs = "";

    if(defined $self->fuzzy()) {
      $qgs = $self->dbh->quote("%".$self->synonym()."%");
      $match = "LIKE";
    } else {
      $qgs = $self->dbh->quote($self->synonym());
    }
    $query  = "s.synonym $match $qgs";

  } elsif(defined $self->gene_id()) {
    my $qgid = $self->dbh->quote($self->gene_id());
    $query   = "s.gene_id=$qgid";

  } elsif(defined $self->name()) {
    my $match = "=";
    my $qgn = "";

    if(defined $self->fuzzy()) {
      $qgn = $self->dbh->quote("%".$self->name()."%");
      $match = "LIKE";
    } else {
      $qgn = $self->dbh->quote($self->name());
    }
    $query  = "g.name $match $qgn";
  }

  my $q = qq(SELECT s.id,s.gene_id,s.synonym,g.name FROM gene_synonym s, gene g WHERE s.gene_id=g.id AND $query);
#warn $q;

  my $sth = $self->dbh->prepare($q);
  $sth->execute();

  while(my $ref = $sth->fetchrow_hashref()) {
    push @{$self->{'data'}}, $ref;
  }

  if(scalar @{$self->{'data'}} == 1) {
    my $d = @{$self->{'data'}}[0];
    undef($self->{'synonym'});
    $self->name($d->{'name'});
    $self->load();
  }

#  warn qq(Retrieved ), $sth->rows(), qq( rows\n);
  $sth->finish();
}

sub fuzzy {
  my ($self, $fuzzy) = @_;
  $self->{'fuzzy'} = $fuzzy if(defined $fuzzy);
  return $self->{'fuzzy'};
}

sub id {
  my ($self, $id) = @_;
  $self->{'id'} = $id if(defined $id);
  return $self->{'id'};
}

sub synonym {
  my ($self, $synonym) = @_;
  $self->{'synonym'} = $synonym if(defined $synonym);
  return $self->{'synonym'};
}

sub gene_id {
  my ($self, $gene_id) = @_;
  $self->{'gene_id'} = $gene_id if(defined $gene_id);
  return $self->{'gene_id'};
}

sub name {
  my ($self, $name) = @_;
  $self->{'name'} = $name if(defined $name);
  return $self->{'name'};
}

sub gene_names {
  my ($self) = @_;
  return $self->unique("name");
}

sub gene_ids {
  my ($self) = @_;
  return $self->unique("gene_id");
}

sub synonyms {
  my ($self) = @_;
  return $self->unique("synonym");
#  return map { $_->{'synonym'} } @{$self->{'data'}};
}

sub synonym_by_gene_name {
  my ($self, $gn) = @_;
  return map { $_->{'synonym'} } grep { $_->{'name'} eq $gn } @{$self->{'data'}};
}

sub synonym_by_gene_id {
  my ($self, $gid) = @_;
  return map { $_->{'synonym'} } grep { $_->{'gene_id'} eq $gid } @{$self->{'data'}};
}

sub unique {
  my ($self, $tag) = @_;

  my %seen = ();
  my @uniq = ();
  for my $d (map { $_->{$tag} } @{$self->{'data'}}) {
    push @uniq, $d if(!$seen{$d}++);
  }
  return @uniq;

}

1;
