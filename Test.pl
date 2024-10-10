use diagnostics;
use warnings;
use strict;

use Cwd;
use POSIX qw(strftime);
use File::Spec::Functions;

my $hostGroup = $ARGV[0];

my $baseDirectory = getcwd();
my $playbookExecution = strftime "%Y%m%d_%H%M%S", localtime;

my $playbookExecutionLog = "patching_${hostGroup}_${playbookExecution}.log";
my $loggingDirectory = 'Runs';

my $playbookLogDirectory = catdir($baseDirectory, $loggingDirectory);
my $playbookLog = catfile($playbookLogDirectory, $playbookExecutionLog);

unless ( -d $playbookLogDirectory) {
   mkdir $playbookLogDirectory;
}

open(my $playbookLogWriter, '>:utf8', $playbookLog)
or die "Could not open $playbookLog for writing...";

my @playbookExecution = `ansible-playbook patching.yml -l $hostGroup -K`;
foreach (@playbookExecution) {
  print $playbookLogWriter $_
}

close $playbookLogWriter;
