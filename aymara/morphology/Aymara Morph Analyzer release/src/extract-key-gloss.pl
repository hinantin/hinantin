#!/usr/bin/env perl

###################################################################################
#
#	extract-key-gloss.pl   extract all keys and glosses from dic/roots/roots.xml
#
#            list keys, marked with categories, in one file
#            list English glosses in a second file
#            list Spanish glosas in a third file
#
#            These files will match up line for line (multiple glosses/glosas
#             are put on the same line, separated by $glossdelim
#
#            When currently used, the keys are read in the original order
#            and converted into a hash, with values from 0 to n; these
#            integers are then used as indices into the glosses or glosas
#            as appropriate (as indicated by the user)
#
#       Ken Beesley
#	Copyright (c) 2000, 2005 Xerox Corporation.  All Rights Reserved.
#       modified 14 Feb 2000 update
#       modified 2 Mar 2000 update
#       rewritten 11 Apr 2005 for XML::Twig and Unicode
#
###################################################################################

use strict ;
use XML::Twig ;
use Unicode::Normalize ;

my $glossdelim = ";;" ;

open KEYOUT, ">:utf8", "../bin/keys.txt" || die "Cannot open keys.txt for output" ;
open GLOSSOUT, ">:utf8", "../bin/glosses.txt" || die "Cannot open glosses.txt for output" ;
open GLOSAOUT, ">:utf8", "../bin/glosas.txt" || die "Cannot open glosas.txt for output" ;

my $parser = new XML::Twig ( TwigHandlers => { 'entry' => \&entry_handler } ) ;

eval { $parser->parsefile("dic/roots/roots.xml") ; } ;

if ($@) {
  print "Parse error: $@\n" ;
} else {
  print "Normal termination of extract-key-gloss.pl.\n" ;
}


######################### Call-back subroutines #################################

my $key ;
my $cat ;

my $gloss ;
my $glosa ;

my $glosslist ;
my $glosalista ;

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

sub entry_handler {
    my ($tp, $entry) = @_ ;
    $key = NFC($entry->first_child('form')->first_child('lexical')->trimmed_text) ;

    $key =~ s/\^V/\+/g ;  # ^V in xml dict mapped to +
    $key =~ s/\^V/\-/g ;

    my @subentries = $entry->children('subentry') ;

    foreach my $subentry (@subentries) {
	$cat = $subentry->att('cat') ;
	$glosslist = "" ;
	$glosalista = "" ;

	print KEYOUT "$key", "_$cat\n" ;

	# English
	my @glossElmts = $subentry->first_child('glosses')->first_child('english')->children('gloss') ;
	foreach my $glossElmt (@glossElmts) {
	    $gloss = NFC($glossElmt->trimmed_text) ;
	    if ($glosslist ne "") {
		$glosslist .= $glossdelim ;
	    }
	    $glosslist .= $gloss ;
	}

	# Spanish
	my @glosaElmts = $subentry->first_child('glosses')->first_child('spanish')->children('glosa') ;
	foreach my $glosaElmt (@glosaElmts) {
	    $glosa = NFC($glosaElmt->trimmed_text) ;
	    if ($glosalista ne "") {
		$glosalista .= $glossdelim ;
	    }
	    $glosalista .= $glosa ;
	}

	print GLOSSOUT $glosslist, "\n" ;
	print GLOSAOUT $glosalista, "\n" ;
    }
}

