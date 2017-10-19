#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use File::stat;
use File::Spec;

my $dbconf = "dbi:SQLite:dbname=/var/tmp/files.db";
my $dbh;
$dbh = DBI->connect($dbconf,"","") or die $dbh->errstr;

my $insert = $dbh->prepare(<<SQL);
	INSERT INTO files(basename, dirname, size) VALUES(?,?,?);
SQL
 
sub do_file {
	my $file = shift;
	my $stat = stat $file;
	my $size = $stat->size;

	return unless $size > 1024*1024; # ignore files <1M


	my (undef, $dirname, $basename) = File::Spec->splitpath($file);
	$insert->execute($basename, $dirname, $size);
}

sub do_find {
	local $/ = "\0";
	my $fh = shift;
	while (<$fh>) {
		do_file $_
	}
}


foreach (@ARGV) {
	open my $fh, "find $_ -type f -print0|";
	do_find $fh;
	close $fh;
}
