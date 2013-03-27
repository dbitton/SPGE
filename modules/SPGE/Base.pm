#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-05-27
# Last Modified: 2003-05-01
# SPGE viewer API Base class
#
package SPGE::Base;
use strict;
use SPGE::Util;


sub util {
  my ($self, $util) = @_;
  if(substr(ref($self), 0, 6) eq "SPGE::") {
    $self->{'util'} = $util if(defined $util);
    $self->{'util'} ||= SPGE::Util->new();
    return $self->{'util'};
  } else {
    return SPGE::Util->new();
  }
}

sub dbh {
  my ($self) = @_;
  return $self->util->dbh();
}

1;
