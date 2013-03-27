#########
# Author: rmp
# Maintainer: rmp
# Created: 2002
# Last Modified: 2003-05-01
# SPGE viewer configuration for gene key canvas
#
package SPGE::WebUserConfig::geexview_key;
use strict;
use Sanger::Graphics::WebUserConfig;
use vars qw(@ISA);
@ISA = qw(Sanger::Graphics::WebUserConfig);

sub init {
  my ($self) = @_;
  my $cmap = $self->colourmap();
  
  $self->{'general'}->{'geexview'} = {
				      '_artefacts' => [qw(SPGE_genekey)],
				      '_options'   => [qw(on pos col hi known unknown)],
				      '_names'     => {
						       'on'  => 'activate',
						       'pos' => 'position',
						       'col' => 'colour',
						       'dep' => 'bumping depth',
						       'str' => 'strand',
						       'hi'  => 'highlight colour',
						      },
				      '_settings' => {
						      'width'           => 700,
						      'bgcolor'         => 'white',
						      'zmenu_behaviour' => 'onclick',
						     },
				      'SPGE_genekey' => {
							 'on'         => "on",
							 'pos'        => '1',
							 'txt'        => 'black',
							 'str'        => 'r',
							 'cols'       => [qw(rust
									     steelblue
									     blueviolet
									     coral
									     chocolate
									     slateblue
									     darkblue
									     brown
									     darkgrey
									     darkorchid
									     darksalmon
									     darkseagreen
									     deeppink
									     dodgerblue
									     firebrick
									     forestgreen
									     goldenrod
									     navyblue
									     maroon
									     magenta
									     mediumblue)],
							},
				     };
}
1;
