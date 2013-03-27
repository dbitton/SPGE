#########
# Author: rmp
# Maintainer: rmp
# Created: 2002
# Last Modified: 2003-05-01
# SPGE viewer expression plot track for grouped experiments
#
package Sanger::Graphics::GlyphSet::SPGE_expression_group;
use strict;
use vars qw(@ISA);
use Sanger::Graphics::GlyphSet;
@ISA = qw(Sanger::Graphics::GlyphSet);
use Sanger::Graphics::Glyph::Line;

sub init_label {
    my ($self) = @_;
    return if( defined $self->{'config'}->{'_no_label'} );

    my $log_base = $self->{'config'}->get('SPGE_expression_group', 'log_base') || 10;
    my $txt      = "ratio";
    my $type     = $self->{'config'}->get('SPGE_expression_group', 'scale') || "";

    if($type eq "log") {
      $txt = qq(log$log_base($txt));
    }

    my $label = new Sanger::Graphics::Glyph::Text({
					       'text'      => $txt,
					       'font'      => 'Small',
					       'absolutey' => 1,
					      });
    $self->label($label);
}

sub _init {
  my ($self) = @_;
  
  my $Config      = $self->{'config'};
  my $Container   = $self->{'container'};
  my $len         = $Container->length();
  my @experiments = $Container->experiments();
  my $im_width    = $Config->image_width();
  my $scale_type  = $Config->get('SPGE_expression_group', 'scale');
  my $log_base    = $Config->get('SPGE_expression_group', 'log_base') || 10;
  my $im_height   = 200;
  my $min         = undef;
  my $max         = undef;
  my $data        = {};

  if($scale_type eq "log") {
    for my $experiment (@experiments) {
      my $eid = $experiment->id();
      for my $gene ($experiment->genes()) {
	$data->{$eid.$gene} = [map { $_=&logn($_->data(), $log_base) ;} $gene->expressions()];
	
	my $tmin = &min(@{$data->{$eid.$gene}});
	$min     = $tmin if(!defined $min || $tmin < $min);
	
	my $tmax = &max(@{$data->{$eid.$gene}});
	$max     = $tmax if(!defined $max || $tmax > $max);
      }
    }
    
  } else {
    for my $experiment (@experiments) {
      my $eid = $experiment->id();
      for my $gene ($experiment->genes()) {
	$data->{$eid.$gene} = [map { $_=$_->data() ;} $gene->expressions()];
      }

      my $tmin = $experiment->minexpression();
      my $tmax = $experiment->maxexpression();
      $min = $tmin if(!defined $min || (defined $tmin && $tmin < $min));
      $max = $tmax if(!defined $max || (defined $tmax && $tmax > $max));
    }

    $min ||= 0;
    $max ||= 1;
  }

  return if(!defined $max || !defined $min);

  #########
  # some boundary checks
  #
  if($max == $min) {
    my $tmp = $max;
    $max = $tmp+1;
    $min = $tmp-1;
  }

  $min = 0 if ($min > 0);

  my $rmax = int($max);
  $rmax++ if($rmax < $max);
  my $rmin = int($min);
  $rmin-- if($rmin > $min);

  my $rdiff           = $rmax - $rmin;
  my $number_of_steps = 10;
  my $interval        = sprintf("%.02f", $rdiff / $number_of_steps);
  my $scale_y         = $im_height / $rdiff;
  $scale_y            = 200 if($scale_y > 200);

  #########
  # positive scale
  #
  for (my $i = 0; $i <= $rmax; $i+= $interval) {
    my $label = $i;

    if($interval < 1) {
      $label = sprintf("%.02f", $label);
    } elsif($interval < 10) {
      $label = sprintf("%.01f", $label);
    } else {
      $label = int($label);
    }

    $label  = 0 if($label == 0); # arf!
    $label .= "  ";

    $self->push(Sanger::Graphics::Glyph::Text->new({
						'x'         => -6 - length($label) * 6,
						'y'         => yflip($rmin, $rdiff, $i) * $scale_y,
						'width'     => length($label) * 6,
						'height'    => 0,
						'colour'    => 'black',
						'absolutex' => 1,
						'text'      => $label,
						'font'      => "Tiny",
					       }));
    $self->push(Sanger::Graphics::Glyph::Line->new({
						'x'         => -4,
						'y'         => yflip($rmin, $rdiff, $i) * $scale_y,
						'width'     => 4,
						'height'    => 0,
						'colour'    => 'black',
						'absolutex' => 1,
						'absolutewidth' => 1,
					       }));
  }

  #########
  # negative scale
  #
  for (my $i = 0; $i >= $rmin; $i-= $interval) {
    my $label = $i;

    if($interval < 1) {
      $label = sprintf("%.02f", $label);
    } elsif($interval < 10) {
      $label = sprintf("%.01f", $label);
    } else {
      $label = int($label);
    }

    $label  = 0 if($label == 0); # arf!
    $label .= "  ";

    $self->push(Sanger::Graphics::Glyph::Text->new({
						'x'         => -6 - length($label) * 6,
						'y'         => yflip($rmin, $rdiff, $i) * $scale_y,
						'width'     => length($label) * 6,
						'height'    => 0,
						'colour'    => 'black',
						'absolutex' => 1,
						'absolutewidth' => 1,
						'text'      => $label,
						'font'      => "Tiny",
					       }));
    $self->push(Sanger::Graphics::Glyph::Line->new({
						'x'         => -4,
						'y'         => yflip($rmin, $rdiff, $i) * $scale_y,
						'width'     => 4,
						'height'    => 0,
						'colour'    => 'black',
						'absolutex' => 1,
						'absolutewidth' => 1,
					       }));
  }

  $self->push(Sanger::Graphics::Glyph::Line->new({
					      'x'         => 0,
					      'y'         => yflip($rmin, $rdiff, $rmin) * $scale_y,
					      'width'     => 0,
					      'height'    => -$rdiff * $scale_y,
					      'colour'    => 'black',
					     }));


  #########
  # populate our colour cache
  #
  my @cols     = @{$Config->get('SPGE_expression_group', 'cols')};
#  if(scalar @genes > scalar @cols) {
#    warn qq(SPGE_expression needs to allocate more colours in geexview.pm!);
#  }

  my $alloc_cols = {};

  #########
  # draw all our genes
  #
  my $experiment_offset = 0;
  for my $experiment (@experiments) {
    my $eid = $experiment->id();
    for my $gene ($experiment->genes()) {

      if(!exists $alloc_cols->{$gene->id()}) {
	$alloc_cols->{$gene->id()} = shift @cols;
      }
      my $col = $alloc_cols->{$gene->id()};

      my @data = @{$data->{$eid.$gene}};
      my @tps  = $experiment->time_points();
      
      my $len = scalar @data;
      $len--;

      for (my $i = 0; $i < $len; $i++) {
	my $dotted = undef;
	my $data1  = $data[$i];
	my $data2  = $data[$i+1];
	my $tp1    = $tps[$i];
	my $tp2    = $tps[$i+1];
	
	while(!defined $data2) {
	  $i++;
	  $data2  = $data[$i+1];
	  $tp2    = $tps[$i+1];
	  $dotted = "dotted";
	  if($i > $len) {
	    $data2 = undef;
	    last;
	  }
	}
	
	next unless (defined $data1 && defined $data2);
	
	my $x = $tp1->time() - $experiment->start();
	my $w = $tp2->time() - $tp1->time();
	my $y = yflip($rmin, $rdiff, $data1);
	my $h = yflip($rmin, $rdiff, $data2) - $y;
	
	if($dotted) {
	  $self->unshift(Sanger::Graphics::Glyph::Line->new({
							     'x'      => $x,
							     'y'      => $y * $scale_y,
							     'width'  => 0.5,
							     'height' => 0,
							     'colour' => $col || "grey",
							    }));
	} else {
	  $self->unshift(Sanger::Graphics::Glyph::Line->new({
							     'x'      => $x+$experiment_offset,
							     'y'      => $y * $scale_y,
							     'width'  => $w,
							     'height' => $h * $scale_y,
							     'colour' => $col || "grey",
#							     'dotted' => $dotted,
							    }));
	}
      }
    }
    
    $experiment_offset += $experiment->length();
    $self->push(Sanger::Graphics::Glyph::Line->new({
						'x'      => $experiment_offset,
						'y'      => yflip($rmin, $rdiff, $rmin) * $scale_y,
						'width'  => 0,
						'height' => -$rdiff * $scale_y,
						'colour' => 'grey',
						'dotted' => 1,
					       }));
  }
}

#########
# some maths functions
#
sub logn {
  my ($n, $base) = @_;
  $n or return;
  $base ||= 10;
  $n    ||= 0;

  if("$base" eq "e") {
    $base = exp(1);
  }

  return 0 if($n <= 0);
  return log($n)/log($base);
}

sub max {
  my @tmp = @_;
  my $max = undef;
  for my $t (@tmp) {
    $max = $t if(!defined $max || $t > $max);
  }
  return $max;
}

sub min {
  my @tmp = @_;
  my $min = undef;
  for my $t (@tmp) {
    $min = $t if(!defined $min || $t < $min);
  }
  return $min;
}

sub yflip {
  my ($rmin, $rdiff, $coord) = @_;
  return  $rdiff / 2 + $rmin - $coord;
}


1;
