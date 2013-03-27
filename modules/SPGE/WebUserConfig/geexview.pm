#########
# Author: rmp
# Maintainer: rmp
# Created: 2002
# Last Modified: 2003-05-01
# SPGE viewer general configuration (single experiment view)
#
package SPGE::WebUserConfig::geexview;
use strict;
use Sanger::Graphics::WebUserConfig;
use vars qw(@ISA);
@ISA = qw(Sanger::Graphics::WebUserConfig);

sub init {
  my ($self) = @_;
  my $cmap = $self->colourmap();
  
  $self->{'general'}->{'geexview'} = {
				      '_artefacts' => [qw(SPGE_experiment_label SPGE_scalebar SPGE_meiosis SPGE_expression)],
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
						      'width'   => 700,
						      'bgcolor' => 'white',
						     },
				      'SPGE_experiment_label' => {
								  'on'         => "on",
								  'pos'        => '0',
								  'str'        => 'r',
								 },
				      'SPGE_scalebar' => {
							  'on'         => "on",
							  'pos'        => '20',
							  'col'        => 'black',
							  'str'        => 'r',
							 },
				      'SPGE_meiosis' => {
							 'on'         => "on",
							 'pos'        => '30',
							 'col'        => 'black',
							 'str'        => 'r',
							 },
				      'SPGE_expression' => {
							    'on'         => "on",
							    'pos'        => '10',
							    'col'        => 'red',
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
