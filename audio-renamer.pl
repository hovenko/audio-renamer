#!/usr/bin/env perl
#
# Code and inspiration from http://superuser.com/a/555413
#

use File::Find;
use MP3::Tag;
use Cwd;

my $TAGS_FILE = "out.audio-renamer.tags.csv";
my $SCRIPT_FILE = "out.audio-renamer.renames.sh";

$dir = ".";
open(OUTFILE,">$TAGS_FILE") || die "Can't open: $!\n";
open(OUTSCRIPT,">$SCRIPT_FILE") || die "Can't open: $!\n";
print STDERR 'Writing media tags from "'.getcwd().'"'." (including subdirectories) to $TAGS_FILE\n";
print STDERR "Writing move commands to $SCRIPT_FILE\n";

print OUTFILE "Path;Artist;Title;Track;Album;Year;Genre;File Size\n";
print OUTSCRIPT "#!/bin/bash\n\n";

find(\&edits, $dir);
close(OUTFILE);
print STDERR "Done\n";

sub edits() {
    $fn=$_;
    $not_shown=1;

    if ( -f and $fn=~m/.+\.mp3$/ig) {
        $mp3 = MP3::Tag->new($fn);
        ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
        $fs= -s $fn;
        print OUTFILE "$File::Find::name;$artist;$title;$track;$album;$year;$genre;$fs\n";

        if ($title && $track) {
            print OUTSCRIPT "mv '$File::Find::name' '$File::Find::dir/$track $title.mp3'\n";
        }
    }

    if ( -f and $fn=~m/.+\.wav$|\.m4a$/ig) {
        $fs= -s $fn;
        print OUTFILE "$File::Find::name\\$fn;;;;;;;$fs\n";
    }
}
