#!/usr/bin/perl
# Takes output from stage1, computes sha256 sums for files where two files have
# the same size and no sha256 sum has been calculated yet
use strict;
use warnings;
use DBI;
use File::Spec;

my $dbconf = "dbi:SQLite:dbname=/var/tmp/files.db";
my $dbh;
$dbh = DBI->connect($dbconf,"","") or die $dbh->errstr;


# files with duplicate size
my $possible_dupes = $dbh->prepare(<<SQL);
	SELECT basename,dirname,f.size,sha256
	FROM files f
	INNER JOIN
		( SELECT COUNT(*) count, size
		  FROM files g
		  GROUP BY g.size
		  HAVING COUNT(*) > 1 ) sel
	ON f.size = sel.size
	ORDER BY sel.count DESC
SQL

my $update_hash = $dbh->prepare(<<SQL);
	UPDATE files
	SET sha256 = ?
	WHERE dirname = ? AND basename = ?
SQL

sub sha256file {
	my $f = shift;
	open my $fd, "-|", 'sha256sum', '-b', '--', $f;
	my $sha = <$fd>;
	print "$sha\n";
	return (split /[* ]/, $sha)[0];
}

$possible_dupes->execute;
while (my @row = $possible_dupes->fetchrow_array) {
	my ($basename, $dirname, $size, $sha) = @row;

	next if defined $sha && $sha ne ''; # don't do work twice

	my $file = File::Spec->catfile($dirname, $basename);
	$sha = sha256file $file;

	$update_hash->execute($sha, $dirname, $basename);
}
