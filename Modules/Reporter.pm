=pod
=head1 Fabio Elia Locatelli
=head2 fabioelialocatelli@yandex.com
=head3 +64204485500
=encoding utf8
=cut

package Reporter;

use strict;
use warnings;

use Cwd;
use File::Path;

use lib 'Modules';
use Designer;
use Formatter;

=pod
=item new()

The class constructor.
File names are predefined, whereas reporting period
and tag to be filtered are parsed from the command line.

=cut

sub new {
    my ($object, $attributes) = @_;
    my $filePrefix = $attributes->{reportingPeriod};

    my $this = bless {
        fileDirectory => "Reporting" . "-" . $filePrefix,
        fileCombined => $filePrefix . "-" . "Combined.html",
        fileReport => $filePrefix . "-" . "Report.html",
        reportingPeriod => $attributes->{reportingPeriod},
        reportingTag =>  $attributes->{reportingTag}
    }, $object;

    return $this;
}

=pod
=item mergeLogs()

The function responsible for log merging.
All files having specific extensions are parsed,
afterwards they are merged into an additional one
for further processing.

=cut

sub mergeLogs{

    my $combinedWriter;
    my $logReader;

    my @logFiles = glob('Logs/*.log');
    my $foundLogs = scalar(@logFiles);
    my $scriptDirectory = getcwd();

    my $this = shift();
    my $fileCombined = $this->{fileCombined};
    my $fileDirectory = $this->{fileDirectory};
    my $reportingPeriod = $this->{reportingPeriod};

    if($foundLogs != 0){

        if(-d $fileDirectory){
            rmtree($fileDirectory);
        }

        my $documentFormatter = Formatter->new();

        unless (-d $fileDirectory) {
          mkdir($fileDirectory);
        }
        chdir($fileDirectory);

        unless (-f $fileCombined){
            open ($combinedWriter, '>:encoding(UTF-8)', $fileCombined)
            or die "Could not open $fileCombined for writing...";

            print $combinedWriter $documentFormatter->{openHtml};
            print $combinedWriter $documentFormatter->{openBody};

            foreach (@logFiles) {

                chdir($scriptDirectory);

                open ($logReader, '<:encoding(UTF-8)', $_)
                or die "Could not open $_ for reading...";

                while (my $logEntry = <$logReader>) {
                    if (grep{/$reportingPeriod/} $logEntry){
                        chomp($logEntry);
                        print $combinedWriter $documentFormatter->{openParagraph} . $logEntry . $documentFormatter->{closeParagraph};
                    }
                }

                close $logReader;
            }

            print $combinedWriter $documentFormatter->{closeBody};
            print $combinedWriter $documentFormatter->{closeHtml};

            close $combinedWriter;
        }

    } elsif($foundLogs == 0) {

        print "There are no logs. Aborting...";
        rmtree($fileDirectory);
        exit;
    }
}

=pod
=item generateReport()

The function responsible for report generation.
A HTML file is generated and all entries matching
the tag specified on the command line are appended.

=cut

sub generateReport{

    my $reportWriter;
    my $combinedReader;

    my $this = shift();
    my $fileDirectory = $this->{fileDirectory};
    my $fileReport = $this->{fileReport};
    my $fileCombined = $this->{fileCombined};
    my $reportingTag = $this->{reportingTag};

    my $documentDesigner = Designer->new();
    my $documentFormatter = Formatter->new();

    chdir($fileDirectory);

    open($combinedReader, '<:encoding(UTF-8)', $fileCombined)
    or die "Could not open $fileCombined for reading...";

    open($reportWriter, '>:encoding(UTF-8)', $fileReport)
    or die "Could not open $fileReport for writing...";

    print $reportWriter $documentFormatter->{openHtml};
    print $reportWriter $documentFormatter->{openHead};
    print $reportWriter $documentFormatter->{openStyle};

    print $reportWriter $documentDesigner->{indentSelector} . "body" . $documentDesigner->{openBlock};
    print $reportWriter $documentDesigner->{indentBlock}. "background-color: " . $documentDesigner->{backgroundColor};
    print $reportWriter $documentDesigner->{indentBlock}. "font-family: " . $documentDesigner->{fontFamily};
    print $reportWriter $documentDesigner->{closeBlock};

    print $reportWriter $documentFormatter->{closeStyle};
    print $reportWriter $documentFormatter->{closeHead};
    print $reportWriter $documentFormatter->{openBody};

    while (my $logEntry = <$combinedReader>) {

        my @filteredLogEntry = grep {/$reportingTag/} $logEntry;

        foreach(@filteredLogEntry){
            print $reportWriter $_;
        }
    }

    print $reportWriter $documentFormatter->{closeBody};
    print $reportWriter $documentFormatter->{closeHtml};

    close $reportWriter;
    close $combinedReader;
}

1;
