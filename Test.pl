use diagnostics;
use warnings;

use Cwd;

use File::Spec::Functions;

my $baseDirectory = getcwd();
my $reportingFile = 'seagulls.txt';
my $reportingDirectory = 'Reports';

my $outputDirectory = catdir($baseDirectory, $reportingDirectory);
my $outputFile = catfile($outputDirectory, $reportingFile);

my $outputString = 'seagulls love crabs';

if (-d $outputDirectory) {
  rmdir $outputDirectory;
} else {

  mkdir $outputDirectory;

}

open(my $reportWriter, '>:utf8', $outputFile)
or die "Could not open $outputFile for writing...";

print $reportWriter $outputString;
close $reportWriter;

open(my $reportReader, '<:utf8', $outputFile)
or die "Could not open $outputFile for reading...";

while ( < $reportReader > ) {
  print $_
}

<<<<<<< HEAD
close $reportReader;
=======
close $reportReader;
>>>>>>> 693c3f6 (Updated Contact Details)
