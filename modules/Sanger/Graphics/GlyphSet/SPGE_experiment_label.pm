#########
# Author: rmp
# Maintainer: rmp
# Created: 2002
# Last Modified: 2003-05-01
# SPGE viewer basic experiment label track
#
package Sanger::Graphics::GlyphSet::SPGE_experiment_label;
use strict;
use vars qw(@ISA);
use Sanger::Graphics::GlyphSet;
@ISA = qw(Sanger::Graphics::GlyphSet);
use Sanger::Graphics::Glyph::Rect;
use Sanger::Graphics::Glyph::Text;

sub init_label {
  my ($self) = @_;
  return if( defined $self->{'config'}->{'_no_label'} );
  
  my $label = new Sanger::Graphics::Glyph::Text({
						 'text'      => "experiment",
						 'font'      => 'Small',
						 'absolutey' => 1,
						});
  $self->label($label);
}

sub _init {
  my ($self)            = @_;
  my $experiment_offset = 0;
  my $container         = $self->{'container'};

  if($container->can("name")) {
    $self->push(Sanger::Graphics::Glyph::Text->new({
						    'x'         => $experiment_offset,
						    'y'         => 6,
						    'height'    => 12,
						    'colour'    => 'black',
						    'absolutey' => 1,
						    'text'      => $container->group->description() . " / " . $container->name(),
						    'font'      => "Small",
						   }));

  } else {
    for my $experiment ($container->experiments()) {
      $self->push(Sanger::Graphics::Glyph::Text->new({
						      'x'         => $experiment_offset,
						      'y'         => 6,
						      'height'    => 12,
						      'colour'    => 'black',
						      'absolutey' => 1,
						      'text'      => $experiment->name(),
						      'font'      => "Small",
						     }));
      $experiment_offset += $experiment->length();
    }
  }
}

1;
