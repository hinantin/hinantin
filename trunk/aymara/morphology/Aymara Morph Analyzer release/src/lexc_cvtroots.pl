#!/usr/bin/env perl

###################################################################################
#
#	lexc_cvtroots.pl    convert dic/roots.xml to lexc format
#
#       outputs various files, one for each basic category type
#       with   LEXICON  cattype    at the head of each one
#
#       roots.xml can have all kinds of roots, in any order; lexc_cvtroots.pl
#       sorts them into different basic category types in order
#       to allow them to take different continuation classes in a lexc grammar
#
#       Ken Beesley
#	Copyright (c) 1999 Xerox Corporation.  All Rights Reserved.
#       Copyright (c) 2000 Xerox Corporation.  All Rights Reserved.
#
# reviewed and edited 12 April 2000
# start rewrite for XML::Twig and Unicode 30 March 2005
#
#
###################################################################################

use strict ;
use XML::Twig ;
use Unicode::Normalize ;

###################################################################

my $entrycnt = 0 ;
my $subentrycnt = 0 ;

# the following names are the same as the 'cat' ATTRs in roots.xml

# adjective
# dayname
# digit
# interrogative
# monthname
# multiplier
# ncommon
# negative
# nproper
# ntemporal
# positional
# positionaldefective
# pronoundemonstrative
# pronounpersonal
# verb

my $adjective = "adjective.lexc" ;
my $dayname = "dayname.lexc" ;
my $digit = "digit.lexc" ;
my $interrogative = "interrogative.lexc" ;
my $monthname = "monthname.lexc" ;
my $multiplier = "multiplier.lexc" ;
my $ncommon = "ncommon.lexc" ;
my $negative = "negative.lexc" ;
my $nproper = "nproper.lexc" ;
my $ntemporal = "ntemporal.lexc" ;
my $positional = "positional.lexc" ;
my $positionaldefective = "positionaldefective.lexc" ;
my $pronoundemonstrative = "pronoundemonstrative.lexc" ;
my $pronounpersonal = "pronounpersonal.lexc" ;
my $verb = "verb.lexc" ;

open ADJECTIVEOUT, ">:utf8", "../obj/$adjective" || die "Cannot open $adjective for output" ;
open DAYNAMEOUT, ">:utf8", "../obj/$dayname" || die "Cannot open $dayname for output" ;
open DIGITOUT, ">:utf8", "../obj/$digit" || die "Cannot open $digit for output" ;
open INTERROGATIVEOUT, ">:utf8", "../obj/$interrogative" || die "Cannot open $interrogative for output" ;
open MONTHNAMEOUT, ">:utf8", "../obj/$monthname" || die "Cannot open $monthname for output" ;
open MULTIPLIEROUT, ">:utf8", "../obj/$multiplier" || die "Cannot open $multiplier for output" ;
open NCOMMONOUT, ">:utf8", "../obj/$ncommon" || die "Cannot open $ncommon for output" ;
open NEGATIVEOUT, ">:utf8", "../obj/$negative" || die "Cannot open $negative for output" ;
open NPROPEROUT, ">:utf8", "../obj/$nproper" || die "Cannot open $nproper for output" ;
open NTEMPORALOUT, ">:utf8", "../obj/$ntemporal" || die "Cannot open $ntemporal for output" ;
open POSITIONALOUT, ">:utf8", "../obj/$positional" || die "Cannot open $positional for output" ;
open POSITIONALDEFECTIVEOUT, ">:utf8", "../obj/$positionaldefective" || die "Cannot open $positionaldefective for output" ;
open PRONOUNDEMONSTRATIVEOUT, ">:utf8", "../obj/$pronoundemonstrative" || die "Cannot open $pronoundemonstrative for output" ;
open PRONOUNPERSONALOUT, ">:utf8", "../obj/$pronounpersonal" || die "Cannot open $pronounpersonal for output" ;
open VERBOUT, ">:utf8", "../obj/$verb" || die "Cannot open $verb for output" ;

# create a lexicon header for each cat in roots.xml

print ADJECTIVEOUT "\n\n\nLEXICON adjective\n\n" ;
print DAYNAMEOUT "\n\n\nLEXICON dayname\n\n" ;
print DIGITOUT "\n\n\nLEXICON digit\n\n" ;
print INTERROGATIVEOUT "\n\n\nLEXICON interrogative\n\n" ;
print MONTHNAMEOUT "\n\n\nLEXICON monthname\n\n" ;
print MULTIPLIEROUT "\n\n\nLEXICON multiplier\n\n" ;
print NCOMMONOUT "\n\n\nLEXICON ncommon\n\n" ;
print NEGATIVEOUT "\n\n\nLEXICON negative\n\n" ;
print NPROPEROUT "\n\n\nLEXICON nproper\n\n" ;
print NTEMPORALOUT "\n\n\nLEXICON ntemporal\n\n" ;
print POSITIONALOUT "\n\n\nLEXICON positional\n\n" ;
print POSITIONALDEFECTIVEOUT "\n\n\nLEXICON positionaldefective\n\n" ;
print PRONOUNDEMONSTRATIVEOUT "\n\n\nLEXICON pronoundemonstrative\n\n" ;
print PRONOUNPERSONALOUT "\n\n\nLEXICON pronounpersonal\n\n" ;
print VERBOUT "\n\n\nLEXICON verb\n\n" ;

# open a file for Multichar_Symbols
# it will be sorted and uniq-ed before use

open MCSOUT, ">:utf8", "../obj/mcs.list" || die "Could not open mcs.list for output" ;

# instantiate an XML::Twig object to parse the roots.xml file

my $parser = new XML::Twig ( TwigHandlers => { 'entry' => \&entry_handler } ) ;

eval { $parser->parsefile("dic/roots/roots.xml") ; } ;

# downtranslate certain fields of the dictionary entries to
# lexc format, sorting them initially into separate intermiediate files,
# under ../obj/
# one file (and LEXICON) for each major part of speech

# Perl select() changes the default for STDOUT, facilitating
# the sorting of the alphabetical entries into separate
# part-of-speech "buckets"

select(STDOUT) ;

# if there was a parser error, $@ will be set

if ($@) {
  print "Parse error: $@\n" ;
  print "Entry count:    $entrycnt\n" ;
  print "Subentry count: $subentrycnt\n" ;
  print "Error termination lexc_cvtroots.pl\n" ;
} else {
  print "Entry count:    $entrycnt\n" ;
  print "Subentry count: $subentrycnt\n" ;
  print "Normal termination lexc_cvtroots.pl\n" ;
}

############################## callback subroutine #####################

my $lexical = "" ;
my $surface = "" ;
my $cat = "" ;
my $feat = "" ;

sub entry_handler {
    my ($t, $entry) = @_ ;
    # the arguments passed to a "handler" are always
    # 1.  The twigparser object itself
    # 2.  The element, in this case an <entry> element

    $entrycnt++ ;

    my $form = $entry->first_child('form') ;

    $lexical = NFC($form->first_child_trimmed_text('lexical')) ;
    # should be a UTF-8 string, canonical composition
    

    my $surfaceElmt = $form->first_child('surface') ; 
    if (defined($surfaceElmt)) {
	$surface = NFC($surfaceElmt->trimmed_text) ;
    } else {
	$surface = $lexical ;
    }

    my @subentries = $entry->children('subentry') ;

    foreach my $subentry (@subentries) {
	$subentrycnt++ ;

	$cat = NFC($subentry->att('cat')) ;

	if ($cat eq "adjective") {
	    select(ADJECTIVEOUT) ;
	} elsif ($cat eq "dayname") {
	    select(DAYNAMEOUT) ;
	} elsif ($cat eq "digit") {
	    select(DIGITOUT) ;
	} elsif ($cat eq "interrogative") {
	    select(INTERROGATIVEOUT) ;
	} elsif ($cat eq "monthname") {
	    select(MONTHNAMEOUT) ;
	} elsif ($cat eq "multiplier") {
	    select(MULTIPLIEROUT) ;
	} elsif ($cat eq "ncommon") {
	    select(NCOMMONOUT) ;
	} elsif ($cat eq "negative") {
	    select(NEGATIVEOUT) ;
	} elsif ($cat eq "nproper") {
	    select(NPROPEROUT) ;
	} elsif ($cat eq "ntemporal") {
	    select(NTEMPORALOUT) ;
	} elsif ($cat eq "positional") {
	    select(POSITIONALOUT) ;
	} elsif ($cat eq "positionaldefective") {
	    select(POSITIONALDEFECTIVEOUT) ;
	} elsif ($cat eq "pronoundemonstrative") {
	    select(PRONOUNDEMONSTRATIVEOUT) ;
	} elsif ($cat eq "pronounpersonal") {
	    select(PRONOUNPERSONALOUT) ;
	} elsif ($cat eq "verb") {
	    select(VERBOUT) ;
	} else {
	    print STDERR "Error in roots.xml: unknown category $cat for entry $lexical\n" ;
	}

	my $featuresElmt = $subentry->first_child('features') ;
	if (defined($featuresElmt)) {
	    my @featureElmts = $featuresElmt->children('feature') ;
	    foreach my $featureElmt (@featureElmts) {
		$feat = NFC($featureElmt->trimmed_text) ;
		$feat =~ /^\@.*\@$/ || print STDERR "Ill-formed flag diacritic $feat in entry: $lexical\n" ;
		# collect all the flag-diac multichar symbols for declaration
		print MCSOUT "$feat\n" ;
		# add FlagDiacritics to both the upper and lower sides
		$lexical .= $feat ;
		$surface .= $feat ;
	    }
	}

	# the XML 'cat' attribute is the lexc continuation-class name
	if ($lexical eq $surface) {
	    print "$lexical\t\t$cat", "root ;\n" ;
	} else {
	    print "$lexical", ":", "$surface\t\t$cat", "root ;\n" ;
	}
    }  # end of loop through subentries
}
