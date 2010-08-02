#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 40;
use WWW::Scraper::ISBN;

###########################################################

my $CHECK_DOMAIN = 'www.google.com';

my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

SKIP: {
	skip "Can't see a network connection", 39   if(pingtest($CHECK_DOMAIN));

	$scraper->drivers("Wheelers");

    # this ISBN doesn't exist
	my $isbn = "1234567890";
    my $record;
    eval { $record = $scraper->search($isbn); };
    if($@) {
        like($@,qr/Invalid ISBN specified/);
    }
    elsif($record->found) {
        ok(0,'Unexpectedly found a non-existent book');
    } else {
		like($record->error,qr/Failed to find that book on Wheelers website|website appears to be unavailable/);
    }

	$isbn   = "0099547937";
	$record = $scraper->search($isbn);
    my $error  = $record->error || '';

    SKIP: {
        skip "Website unavailable", 19   if($error =~ /website appears to be unavailable/);

        unless($record->found) {
            diag($record->error);
        } else {
            is($record->found,1);
            is($record->found_in,'Wheelers');

            my $book = $record->book;
            is($book->{'isbn'},         '9780099547938'         ,'.. isbn found');
            is($book->{'isbn10'},       '0099547937'            ,'.. isbn10 found');
            is($book->{'isbn13'},       '9780099547938'         ,'.. isbn13 found');
            is($book->{'ean13'},        '9780099547938'         ,'.. ean13 found');
            is($book->{'title'},        'Ford County'           ,'.. title found');
            is($book->{'author'},       'John Grisham'          ,'.. author found');
            like($book->{'book_link'},  qr|http://www.wheelers.co.nz/books/9780099547938-|);
            is($book->{'image_link'},   'http://www.wheelers.co.nz/resource/product/large/978009/9780099547938.jpg');
            is($book->{'thumb_link'},   'http://www.wheelers.co.nz/resource/product/small/978009/9780099547938.jpg');
            like($book->{'description'},qr|John Grisham takes you into the heart of America's Deep South|);
            is($book->{'publisher'},    'Misc - Random House New Zealan'              ,'.. publisher found');
            is($book->{'pubdate'},      '27 May 2010'              ,'.. pubdate found');
            is($book->{'binding'},      'Paperback'             ,'.. binding found');
            is($book->{'pages'},        '352'                   ,'.. pages found');
            is($book->{'width'},        '111'                   ,'.. width found');
            is($book->{'height'},       '178'                   ,'.. height found');
            is($book->{'weight'},       undef                   ,'.. weight found');
        }
    }

	$isbn   = "9780007203055";
	$record = $scraper->search($isbn);
    $error  = $record->error || '';

    SKIP: {
        skip "Website unavailable", 19   if($error =~ /website appears to be unavailable/);

        unless($record->found) {
            diag($record->error);
        } else {
            is($record->found,1);
            is($record->found_in,'Wheelers');

            my $book = $record->book;
            is($book->{'isbn'},         '9780007203055'         ,'.. isbn found');
            is($book->{'isbn10'},       '0007203055'            ,'.. isbn10 found');
            is($book->{'isbn13'},       '9780007203055'         ,'.. isbn13 found');
            is($book->{'ean13'},        '9780007203055'         ,'.. ean13 found');
            like($book->{'author'},     qr/Simon Ball/          ,'.. author found');
            is($book->{'title'},        q|The Bitter Sea: The Brutal World War II Fight for the Mediterranean|  ,'.. title found');
            like($book->{'book_link'},  qr|http://www.wheelers.co.nz/books/9780007203055-|);
            is($book->{'image_link'},   'http://www.wheelers.co.nz/resource/product/large/978000/9780007203055.jpg');
            is($book->{'thumb_link'},   'http://www.wheelers.co.nz/resource/product/small/978000/9780007203055.jpg');
            like($book->{'description'},qr|A gripping history of the Mediterranean campaigns|);
            is($book->{'publisher'},    'HarperCollins'         ,'.. publisher found');
            is($book->{'pubdate'},      '1 April 2010'          ,'.. pubdate found');
            is($book->{'binding'},      'Paperback'             ,'.. binding found');
            is($book->{'pages'},        416                     ,'.. pages found');
            is($book->{'width'},        130                     ,'.. width found');
            is($book->{'height'},       197                     ,'.. height found');
            is($book->{'weight'},       312                     ,'.. weight found');

            #use Data::Dumper;
            #diag("book=[".Dumper($book)."]");
        }
    }
}

###########################################################

# crude, but it'll hopefully do ;)
sub pingtest {
    my $domain = shift or return 0;
    system("ping -q -c 1 $domain >/dev/null 2>&1");
    my $retcode = $? >> 8;
    # ping returns 1 if unable to connect
    return $retcode;
}
