#########
# Author: rmp
# Maintainer: rmp
# Created: 2002
# Last Modified: 2003-05-01
# SPGE viewer meiosis track for tagging timelines
#
package Sanger::Graphics::GlyphSet::SPGE_meiosis;
use strict;
use vars qw(@ISA);
use Sanger::Graphics::GlyphSet;
@ISA = qw(Sanger::Graphics::GlyphSet);
use Sanger::Graphics::Glyph::Text;
use Sanger::Graphics::Glyph::Line;
use Sanger::Graphics::Glyph::Poly;
use Sanger::Graphics::Bump;

sub init_label {
    my ($self) = @_;
    return if( defined $self->{'config'}->{'_no_label'} );
    my $label = new Sanger::Graphics::Glyph::Text({
        'text'      => $self->{'config'}->get('SPGE_meiosis','label'),
        'font'      => 'Small',
        'absolutey' => 1,
    });
    $self->label($label);
}

sub _init {
  my ($self) = @_;
  
  my $Config          = $self->{'config'};
  my $Container       = $self->{'container'};
  my $start           = $Container->start();
  my $pix_per_bp      = $Config->transform->{'scalex'};
  my $fontname        = "Small";
  my $w               = $Config->texthelper->width($fontname);
  my ($font_w_bp,$h)  = $Config->texthelper->px2bp($fontname);
  my $bitmap_length   = int($Container->length() * $pix_per_bp);
  my @bitmap          = ();


  for my $ms ($Container->meiosis_stages()) {
    my $halfduration = $ms->time_duration() / 2;
    my $centre       = $ms->time_start() - $start + $halfduration;
    my $description  = $ms->description;
    my $label_width  = $font_w_bp * length(" $description ");
    my $gx           = $centre - $label_width / 2;
    $gx              = 0 if($gx < 0);
    my $tglyph       = Sanger::Graphics::Glyph::Text->new({
						       'x'         => $gx,
						       'y'         => 12,
						       'height'    => 20,
						       'width'     => $label_width,
						       'colour'    => 'black',
						       'absolutey' => 1,
						       'text'      => $description,
						       'font'      => $fontname,
						      });
    
    my $bump_start   = int($tglyph->x() * $pix_per_bp);
    $bump_start      = 0 if ($bump_start < 0);
    my $bump_end     = $bump_start + int($tglyph->width()*$pix_per_bp) +1;
    $bump_end        = $bitmap_length if ($bump_end > $bitmap_length);
    my $row          = &Sanger::Graphics::Bump::bump_row(
				       $bump_start,
				       $bump_end,
				       $bitmap_length,
				       \@bitmap
				      );
    
    $tglyph->y($tglyph->y() + (1.2 * $row * $h) + 1);
    $self->push($tglyph);

    if($ms->time_duration() == 0) {
      #########
      # draw an arrow
      #

      $centre += 3/$pix_per_bp if($centre <= 0); # hack alert! - poly's with neg coords don't draw correctly
      $self->push(Sanger::Graphics::Glyph::Poly->new({
						  'points'    => [$centre, 6, $centre-(2/$pix_per_bp), 10, $centre+(2/$pix_per_bp), 10],
						  'absolutey' => 1,
						  'colour'    => 'black',
						 }));

      $self->push(Sanger::Graphics::Glyph::Line->new({
						  'x'         => $centre,
						  'y'         => 6,
						  'height'    => 6 + (1.2 * $row * 6),
						  'width'     => 0,
						  'colour'    => 'black',
						  'absolutey' => 1,
						 }));
    } else {
      #########
      # draw a |---|
      #
      $self->push(Sanger::Graphics::Glyph::Line->new({
						  'x'         => $centre - $halfduration,
						  'y'         => 4,
						  'height'    => 4,
						  'width'     => 0,
						  'colour'    => 'black',
						  'absolutey' => 1,
						 }));
      $self->push(Sanger::Graphics::Glyph::Line->new({
						  'x'         => $centre - $halfduration,
						  'y'         => 6,
						  'height'    => 0,
						  'width'     => $ms->time_duration(),
						  'colour'    => 'black',
						  'absolutey' => 1,
						 }));
      $self->push(Sanger::Graphics::Glyph::Line->new({
						  'x'         => $centre + $halfduration,
						  'y'         => 4,
						  'height'    => 4,
						  'width'     => 0,
						  'colour'    => 'black',
						  'absolutey' => 1,
						 }));
    }
  }
}

1;
