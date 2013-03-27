#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-05-27
# Last Modified: 2003-05-01
# Database helper object
#
package SPGE::Util;
use strict;
use DBI;

sub new {
  my ($class, $refs) = @_;
  my $self = {
	      'dbname' => 'S_pombe_geneexpression_26',
	      'dbhost' => 'localhost',
	      'dbuser' => 'spgero',
	      'dbpass' => '',
	     };

  for my $k (qw(dbname dbhost dbuser dbpass)) {
    $self->{$k} = $refs->{$k} if(defined $refs->{$k});
  }

  bless($self, $class);

  $self->{'dbh'} = DBI->connect(qq(DBI:mysql:database=$self->{'dbname'};host=$self->{'dbhost'}), $self->{'dbuser'}, $self->{'dbpass'});
  return $self;
}

sub DESTROY {
  my ($self) = @_;
  $self->{'dbh'}->disconnect() if(defined $self->{'dbh'});
}

sub dbh {
  my ($self) = @_;
  return $self->{'dbh'};
}

sub quote {
  my ($self, $str) = @_;
  return $self->{'dbh'}->quote($str);
}

1;
