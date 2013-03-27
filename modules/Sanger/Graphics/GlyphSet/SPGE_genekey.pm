#########
# Author: rmp
# Maintainer: rmp
# Created: 2002-05-30
# Last Modified: 2003-05-01
# SPGE key parent class
#
package Sanger::Graphics::GlyphSet::SPGE_genekey;
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
					     'text'      => 'key',
					     'font'      => 'Small',
					     'absolutey' => 1,
					    });
  $self->label($label);
}


sub _init {
  my ($self) = @_;
  
  my $container  = $self->{'container'};
  my $Config     = $self->{'config'};
  my $y          = 0;
  my $x          = 0;
  my $h          = 14;
  my @genes      = ();
  my @cols       = @{$Config->get('SPGE_genekey', 'cols')};
  my $xspace     = 80;

  if(ref($container) eq "SPGE::Experiment") {
    @genes = $container->genes();
  } else {
    @genes = ($container->experiments())[0]->genes();
  }


  while(my $gene = shift @genes) {
    my $col       = shift @cols;
    my $genedb_id = $gene->genedb_id();
    $self->push(Sanger::Graphics::Glyph::Rect->new({
						'x'         => $x,
						'y'         => $y,
						'width'     => 8,
						'height'    => 8,
						'colour'    => $col,
						'absolutex' => 1,
						'absolutewidth' => 1,
					       }));

    my $name = $gene->name();
    if(length($name) > 9) {
      $name = substr($name, 0, 7) . "..";
    }

    $self->push(Sanger::Graphics::Glyph::Text->new({
						'x'         => $x+10,
						'y'         => $y,
						'width'     => 50,
						'height'    => 8,
						'colour'    => 'black',
						'text'      => $name,
						'font'      => 'Small',
						'absolutex' => 1,
						'absolutewidth' => 1,
					       }));

    my $groupid    = $Config->{'cgi'}->param('group') || 1;
    my $q          = $gene->name();
    my $scale      = $Config->{'cgi'}->param('scale') || "";
    my $genedb_ref = qq(http://www.genedb.org/genedb/Search?name=$genedb_id&organism=pombe);
    my $geex_ref   = qq($ENV{'SCRIPT_NAME'}?group=$groupid;q=$q;match=exact;scale=$scale);

    $self->push(Sanger::Graphics::Glyph::Rect->new({
						'x'      => $x,
						'y'      => $y,
						'width'  => 70,
						'height' => 10,
						'colour' => 'transparent',
						'absolutex' => 1,
						'absolutewidth' => 1,
						'zmenu'  => {
							     'caption'                => qq($name / $genedb_id),
							     qq(01:View this profile) => $geex_ref,
							     qq(02:GeneDB Entry)      => $genedb_ref,
							    },
					       }));

    $x+= $xspace;
    if($x > ($Config->image_width() - $xspace)) {
      $x  = 0;
      $y += $h;
    }
  }
}
1;
