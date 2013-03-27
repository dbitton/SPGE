#########
# Author: rmp
# Maintainer: rmp
# Created: 2002
# Last Modified: 2003-02-27
# SPGE viewer scalebar for grouped experiments
#
package Sanger::Graphics::GlyphSet::SPGE_scalebar_group;
use strict;
use vars qw(@ISA);
use Sanger::Graphics::GlyphSet;
@ISA = qw(Sanger::Graphics::GlyphSet);
use Sanger::Graphics::Glyph::Rect;
use Sanger::Graphics::Glyph::Text;

sub init_label {
  my ($self) = @_;
  return if( defined $self->{'config'}->{'_no_label'} );
  
  my $type = $self->{'container'}->time_scale();
  my $txt  = "time ($type)";
  my $font = "Small";
  
  my $label = new Sanger::Graphics::Glyph::Text({
						 'text'      => $txt,
						 'font'      => 'Small',
						 'absolutey' => 1,
						});
  $self->label($label);
}

sub _init {
  my ($self) = @_;
  
  my $Config            = $self->{'config'};
  my $pix_per_bp        = $Config->transform->{'scalex'};
  my $Container         = $self->{'container'};
  my @experiments       = $Container->experiments();
  my $experiment_offset = 0;
  my $shove_flag        = 0;

  for my $experiment (@experiments) {
    my $length = $experiment->length();
    my $start  = $experiment->start();
    my $end    = $experiment->end();

    $self->push(Sanger::Graphics::Glyph::Line->new({
						'x'         => $experiment_offset,
						'y'         => 0,
						'width'     => $length,
						'height'    => 0,
						'colour'    => 'black',
						'absolutey' => 1,
					       }));
    
    for my $tp ($experiment->time_points()) {
      my $i     = $tp->time();
      my $label = $i;
      my $txt   = $i;

      if($txt == $experiment->length()) {
	$txt -= 5* length($label) / $pix_per_bp;
      }

      $self->push(Sanger::Graphics::Glyph::Rect->new({
						  'x'         => $i - $start + $experiment_offset,
						  'y'         => 0,
						  'width'     => 0,
						  'height'    => $shove_flag?8:4,
						  'colour'    => 'black',
						  'absolutey' => 1,
						 }));
      $self->push(Sanger::Graphics::Glyph::Text->new({
						  'x'         => $txt - $start + $experiment_offset,
						  'y'         => $shove_flag?12:6,
						  'height'    => 12,
						  'colour'    => 'black',
						  'absolutey' => 1,
						  'text'      => $label,
						  'font'      => "Tiny",
						 }));
    }

    $experiment_offset += $experiment->length();
    $shove_flag = !$shove_flag;
  }
}

1;
