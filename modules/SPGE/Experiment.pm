#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-06-25
# Last Modified: 2003-05-01
# SPGE viewer Experiment class
#
package SPGE::Experiment;
use strict;
use SPGE::Base;
use SPGE::TimePoint;
use SPGE::Meiosis;
use SPGE::Gene;
use SPGE::Expression;
use vars qw/@ISA/;
@ISA = qw/SPGE::Base/;

sub new {
  my ($class, $refs) = @_;
  my $self = {
	      'time_points'    => [],
	      'meiosis_stages' => [],
	      'expressions'    => {}, # keyed by gene name
	      'genes'          => {},
	     };
  bless($self, $class);

  for my $k (qw(util id name experiment_group_id)) {
    $self->{$k} = $refs->{$k} if(defined $refs->{$k});
  }

  $self->load() if((defined $self->id() || defined $self->name()) && !defined $refs->{'_noload'});

  if(defined $refs->{'gene_names'}) {
    for my $gn (@{$refs->{'gene_names'}}) {
      $self->load_gene_by_name($gn);
    }
  }

  return $self;
}

sub experiment_by_id {
  my ($self, $id) = @_;
  return $self->new({
		     'id' => $id,
		    });
}

sub experiment_by_name {
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

sub group {
  my $self = shift;
  unless(exists($self->{'group'})) {
    ($self->{'group'}) = SPGE::ExperimentGroup->new({
						     'util' => $self->util(),
						     'id'   => $self->experiment_group_id(),
						    });
  }
  return $self->{'group'};
}

sub time_scale {
  my $self = shift;
  return $self->group->time_scale();
}

sub experiment_group_id {
  my ($self, $gumshoe) = @_;
  $self->{'experiment_group_id'} = $gumshoe if(defined $gumshoe);
  return $self->{'experiment_group_id'};
}

sub load_gene_by_name {
  my ($self, $gene_name) = @_;

  if(!exists $self->{'genes'}->{$gene_name}) {
    my $gene = SPGE::Gene->new({
				'util' => $self->util(),
				'name' => $gene_name,
			       });
    $self->load_gene_expression($gene);
    $self->{'genes'}->{$gene_name} = $gene;
  }

  return $self->{'genes'}->{$gene_name};
}

sub genes {
  my ($self) = @_;
  return sort { $a->id() <=> $b->id() } values %{$self->{'genes'}};
}

sub length {
  my ($self) = @_;
  return $self->end() - $self->start();
}

sub start {
  my ($self)     = @_;
  my @timepoints = $self->time_points();
  if(@timepoints) {
    return $timepoints[0]->time();
  } else {
    return 0;
  }
}

sub end {
  my ($self)     = @_;
  my @timepoints = $self->time_points();
  if(@timepoints) {
    return $timepoints[-1]->time();
  } else {
    return 1;
  }
}

sub maxexpression {
  my ($self) = @_;
  my $max = 0;

  for my $gene ($self->genes()) {
    for my $expression (map { $_->data() } $gene->expressions()) {
      $max = $expression if(defined $expression && $expression > $max);
    }
  }
  return $max;
}

sub minexpression {
  my ($self) = @_;
  my $min = undef;

  for my $gene ($self->genes()) {
    for my $expression (map { $_->data() } $gene->expressions()) {
      $min = $expression if(!defined $min || (defined $expression && $expression < $min));
    }
  }
  return $min;
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

  my $sth = $self->dbh->prepare(qq(SELECT id,name,experiment_group_id
				   FROM   experiment
				   WHERE  $query LIMIT 1));
  $sth->execute();

  my $ref = $sth->fetchrow_hashref();
  $sth->finish();
  $self->name($ref->{'name'});
  $self->id($ref->{'id'});
  $self->experiment_group_id($ref->{'experiment_group_id'});
}

sub time_points {
  my ($self) = @_;

  if(scalar @{$self->{'time_points'}} > 0) {
    return @{$self->{'time_points'}};
  }


  my $qid = $self->dbh->quote($self->id());
  my @tmp = ();
  my $sth = $self->dbh->prepare(qq(SELECT   id,experiment_id,time
				   FROM     time_point
				   WHERE    experiment_id = $qid
				   ORDER BY time));
  $sth->execute();
  while(my $hashref = $sth->fetchrow_hashref()) {
    push @tmp, SPGE::TimePoint->new({
				     'util'          => $self->util(),
				     '_noload'       => 1,
				     'id'            => $hashref->{'id'},
				     'experiment_id' => $hashref->{'experiment_id'},
				     'time'          => $hashref->{'time'},
				    });
  }
  $sth->finish();

  $self->{'time_points'} = \@tmp;
  return @tmp;
}

sub meiosis_stages {
  my ($self) = @_;

  if(scalar @{$self->{'meiosis_stages'}} > 0) {
    return @{$self->{'meiosis_stages'}};
  }


  my $qid = $self->dbh->quote($self->id());
  my @tmp = ();
  my $sth = $self->dbh->prepare(qq(SELECT   id,experiment_id,time_start,time_duration,description
				   FROM     meiosis_stage
				   WHERE    experiment_id = $qid
				   ORDER BY time_start));
  $sth->execute();
  while(my $hashref = $sth->fetchrow_hashref()) {
    push @tmp, SPGE::Meiosis->new({
				   (
				    'util'          => $self->util(),
				    '_noload'       => 1,
				   ),
				   %{$hashref},
				  });
  }
  $sth->finish();

  $self->{'meiosis_stages'} = \@tmp;
  return @tmp;
}

sub expressions_by_gene_name {
  my ($self, $gene_name) = @_;

  my $gene = $self->load_gene_by_name($gene_name);

  return $gene->expressions();
}

sub load_gene_expression {
  my ($self, $gene) = @_;

  if(scalar $gene->expressions() == 0) {
    my @expressions = ();
    
    for my $time_point ($self->time_points()) {
      push @expressions, SPGE::Expression->new({
						'util'          => $self->util(),
						'time_point_id' => $time_point->id(),
						'gene_id'       => $gene->id(),
					       });
    }
    
    $gene->expressions(@expressions);
  }
}

sub experiments {
  my ($self) = @_;

  $self = $self->new() if(!ref($self));

  my $sth = $self->dbh->prepare(qq(SELECT id,name,experiment_group_id
				   FROM   experiment
				   ORDER BY id));
  $sth->execute();

  my @experiments = ();

  while(my $ref = $sth->fetchrow_hashref()) {
    push @experiments, SPGE::Experiment->new({
					      'id'                  => $ref->{'id'},
					      'name'                => $ref->{'name'},
					      'experiment_group_id' => $ref->{'experiment_group_id'},
					      '_noload'             => 1,
					      'util'                => $self->util(),
					     });
  }
  $sth->finish();
  return @experiments;
}

sub genes_by_profile {
  my ($self, $seriesref, $threshold) = @_;
  $threshold ||= 1;
  my $sth = $self->dbh->prepare(qq(SELECT gene_id,count(gene_id) AS count
				   FROM   expression
				   WHERE  @{[ join(' OR ', map { "bin_id=$_" } @{$seriesref})]}
				   GROUP BY gene_id
				   ORDER BY count DESC));
  $sth->execute();

  my @genes  = ();

  while(my ($gene_id, $count) = $sth->fetchrow_array()) {
    next if($count < $threshold);
    push @genes, SPGE::Gene->new({
				  'util'  => $self->util(),
				  'id'    => $gene_id,
				  'score' => $count,
				 });
  }
  $sth->finish();
  return @genes;
}

1;
