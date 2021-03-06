#########
# Author: rmp
# Maintainer: rmp
# Created: 2002
# Last Modified: 2003-05-01
# SPGE viewer scalebar for single experiments
#
package Sanger::Graphics::GlyphSet::SPGE_scalebar;
use strict;
use vars qw(@ISA);
use Sanger::Graphics::GlyphSet;
@ISA = qw(Sanger::Graphics::GlyphSet);
use Sanger::Graphics::Glyph::Rect;
use Sanger::Graphics::Glyph::Text;

sub init_label {
  my ($self) = @_;
  return if( defined $self->{'config'}->{'_no_label'} );
  
  my $type = $self->{'container'}->time_scale() || "hrs";
  my $txt  = "time ($type)";
  my $font = "Small";

  # Slightly dodgy hack to get repeat scale bar for mating experiments.

  my $expt_id_cjp = $self->{container}{time_points}[1]{experiment_id};

  if ($expt_id_cjp == 12 or $expt_id_cjp == 13) {

      $txt = "repeat no.";

  }

  if(defined $self->{'config'}->get('SPGE_scalebar', 'ds')) {
    $font = "Tiny";
    $txt  = "";
    return;
  }
  
  my $label = Sanger::Graphics::Glyph::Text->new({
						  'text'      => $txt,
						  'font'      => 'Small',
						  'absolutey' => 1,
						 });
  $self->label($label);
}

sub _init {
  my ($self) = @_;
  
  my $Config     = $self->{'config'};
  my $Container  = $self->{'container'};
  my $length     = $Container->length();
  my $start      = $Container->start();
  my $end        = $Container->end();
  my $pix_per_bp = $Config->transform->{'scalex'};

  $self->push(Sanger::Graphics::Glyph::Line->new({
						  'x'         => 0,
						  'y'         => 0,
						  'width'     => $length,
						  'height'    => 0,
						  'colour'    => 'black',
						  'absolutey' => 1,
						 }));
  
  for my $tp ($Container->time_points()) {
    my $i = $tp->time();
    
    my $label = $i;
    my $txt = $i;
    if($txt == $Container->length()) {
      $txt -= 4* length($label) / $pix_per_bp;
    }
    $self->push(Sanger::Graphics::Glyph::Rect->new({
						    'x'         => $i - $start,
						    'y'         => 0,
						    'width'     => 0,
						    'height'    => 4,
						    'colour'    => 'black',
						    'absolutey' => 1,
						   }));
    $self->push(Sanger::Graphics::Glyph::Text->new({
						    'x'         => $txt - $start,
						    'y'         => 6,
						    'height'    => 12,
						    'colour'    => 'black',
						    'absolutey' => 1,
						    'text'      => $label,
						    'font'      => "Tiny",
						   }));
  }
}

1;
