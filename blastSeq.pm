#!/usr/bin/perl -w

package blastSeq_Alessandra_2;
use strict;
use TheSchwartz::Job;
use base qw( TheSchwartz::Worker );
use Data::Dumper;
use DBI;

sub work {

	my $class = shift;
	my TheSchwartz::Job $job = shift;
	my $jobID = $job->jobid;
	my $params = $job->arg;
	my $args = $params->[0];

	# connect to the database
	my $driver = "mysql"; 
	my $database = "webdev";
	my $dsn = "DBI:$driver:database=$database";
	my $userid = "webdev";
	my $password = "internet";
	my $dbh = DBI->connect($dsn, $userid, $password) or die $DBI::errstr;

	# change job status to RUNNING
	my $statement = qq{UPDATE blastSeq_Alessandra SET jobstatus = "R" where jobid = ?};
	my $sth = $dbh->prepare($statement)
	  or die $dbh->errstr;
	$sth->execute($jobID)
	  or die $sth->errstr;

	# write query sequence into a file
	my $seq = $args->{'seq'};
	my $queryFile = "query_".$jobID.".fasta";
	open(QUERY, "> $queryFile") or die;
	print QUERY ">query\n";
	print QUERY $seq;
	close QUERY;
	
	# run blastp
	my $db = "/home/webdev20171/db_uniprot/uniprot_human";
	system("blastp -db ".$db." -query ".$queryFile." -outfmt 6 > /var/www/html/disciplina/webdev20171/Htinha/result/".$jobID."_result.txt");
	system("rm $queryFile");

	# change job status to Complete
	my $status = "C";
	my $statement2 = qq{UPDATE blastSeq_Alessandra SET jobstatus = ? where jobid = ?};
	my $sth2 = $dbh->prepare($statement2)
	  or die $dbh->errstr;
	$sth2->execute($status,$jobID)
	  or die $sth2->errstr;

	$job->completed();

}

return 1;
