#########
# Author: rmp
# Maintainer: rmp
# Last Modified: 2003-06-09
#
package SPGE::DrawableContainer;
use vars qw/@ISA/;
@ISA = qw(Sanger::Graphics::DrawableContainer);
use Sanger::Graphics::DrawableContainer;
use Sanger::Graphics::GlyphSet::SPGE_scalebar;
use Sanger::Graphics::GlyphSet::SPGE_expression;
use Sanger::Graphics::GlyphSet::SPGE_genekey;
use Sanger::Graphics::GlyphSet::SPGE_meiosis;
use Sanger::Graphics::GlyphSet::SPGE_expression_group;
use Sanger::Graphics::GlyphSet::SPGE_scalebar_group;
use Sanger::Graphics::GlyphSet::SPGE_experiment_label;
1;
