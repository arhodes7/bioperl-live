
#
# BioPerl module for Bio::SeqFeatureProducer::GFF
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqFeatureProducer::GFF - Produce Sequence Features from a GFF file

=head1 SYNOPSIS

input GFF, add_features($seq), $seq now has features from the GFF.

=head1 DESCRIPTION

GFF parsing and feature adding.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  vsns-bcd-perl@lists.uni-bielefeld.de          - General discussion
  vsns-bcd-perl-guts@lists.uni-bielefeld.de     - Technically-oriented discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Jason Stajich

Jason Stajich <jason@chg.mc.duke.edu>

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SeqFeatureProducer::GFF;

use vars qw(@ISA);
use Bio::SeqFeatureProducerI;
use Bio::Root::Object;
use Bio::SeqFeature::Generic;
use IO::File;

use strict;

# Object preamble - inheriets from Bio::Root::RootI
use Carp;

@ISA = qw(Bio::Root::Object Bio::SeqFeatureProducerI);

sub _initialize {
    my ($self, @args) = @_;
    my $make = $self->SUPER::_initialize();
    my ( $gff ) = $self->_rearrange([qw(GFF)], @args);
    $self->{'_rptfileread'} = 0;
    $self->_parse_rpt($gff);
    return $make;
}

=head2 _parse_rpt

 Title   : _parse_rpt
 Usage   : $seqprod->_parse_rpt($filename);
 Function: Reads in rpt file
 Returns : none
 Args    : Bio::Seq object

=cut

sub _parse_rpt {
    my ($self,$rpt) = @_;
    my $fileh;
    if( defined $rpt && ref($rpt) && $rpt->isa('IO::Scalar') ) { 
	$fileh = $rpt;
    } else { 
	$fileh = new IO::File($rpt, "r");	
    }
    my @feats;
    while( <$fileh> ) {
	next if ( /^\#/);
	my $feat = new Bio::SeqFeature::Generic( -gff_string=> $_ );    
	push @feats, $feat;
    }
    $self->{'_features'} = [ @feats ];
    $self->{'_rptfileread'}  = 1;
}

=head2 add_features

 Title   : add_features
 Usage   : $featprod->add_features($seq);
 Function: Adds features to the sequence based on
           already parsed sequence data
 Returns : none
 Args    : Bio::Seq object

=cut

sub add_features {
    my ($self,$seq) = @_;
    $self->throw("Must have read BLAST Report before trying to add features") 
	if( ! $self->{'_rptfileread'} ) ;

    foreach my $f ( @{$self->{'_features'}} ) {
	$seq->add_SeqFeature($f);
    }
    return 1;
}

1;
