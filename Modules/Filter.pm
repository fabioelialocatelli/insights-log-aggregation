=pod
=head1 Fabio Elia Locatelli
=head2 fabioelialocatelli@yandex.com
=head3 +64204485500
=encoding utf8
=cut

package Filter;

use strict;
use warnings;
use diagnostics;

use Cwd;
use List::MoreUtils 'true';
use List::MoreUtils 'uniq';
use File::Spec::Functions 'catdir';
use File::Spec::Functions 'catfile';

use lib 'Modules';
use Designer;
use Formatter;

=pod
=item new()

The class constructor.
File names are predefined, whereas the reporting period
is parsed from the command line.

=cut

sub new {
    
    my ($object, $attributes) = @_;
    my $filePrefix = $attributes->{reportingPeriod};
    
    my $this = bless {
        usersFile => $filePrefix . "-" . "Users.csv",
        globbedFile => $filePrefix . "-" . "Combined.html",
        reportFile => $filePrefix . "-" . "Report.html",
        presentationFile => $filePrefix . "-" . "Presentation.html",
        reportingPeriod => $attributes->{reportingPeriod},
        textManipulationDirectory => 'Reports',
        fileDropDirectory => 'Logs'
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

sub mergeLogs {

    my $this = shift();

    my $globbedFileWriter;
    my $logReader;

    my $baseDirectory = getcwd();
    my $reportingPeriod = $this->{reportingPeriod};

    my $fileDropDirectory = $this->{fileDropDirectory};
    my $textManipulationDirectory = $this->{textManipulationDirectory};

    my $globbedFile = $this->{globbedFile};
    my $reportFile = $this->{reportFile};

    my $logPath = catdir($baseDirectory, $fileDropDirectory);

    my $reportOutputDirectory = catdir($baseDirectory, $textManipulationDirectory);
    my $reportFilePath = catfile($reportOutputDirectory, $reportFile);
    my $globbedFilePath = catfile($reportOutputDirectory, $globbedFile);

    chdir $logPath;
    my @logFiles = glob("*");
    my $logsFound = scalar(@logFiles);

    if($logsFound != 0){

        mkdir $reportOutputDirectory;
        my $documentFormatter = Formatter->new();

        open ($globbedFileWriter, '>:encoding(UTF-8)', $globbedFilePath)
        or die "Could not open $globbedFile for writing...";

        print $globbedFileWriter $documentFormatter->{openHtml};
        print $globbedFileWriter $documentFormatter->{openBody};

        foreach (@logFiles) {

            open ($logReader, '<:encoding(UTF-8)', $_)
            or die "Could not open $_ for reading...";

            while (my $logEntry = <$logReader>) {
                if (grep{/$reportingPeriod/} $logEntry){
                    print $globbedFileWriter $logEntry;                  
                }
            }

            close $logReader;
      }

      print $globbedFileWriter $documentFormatter->{closeBody};
      print $globbedFileWriter $documentFormatter->{closeHtml};

      close $globbedFileWriter;
      chdir $baseDirectory;

    } elsif($logsFound == 0) {
        print "There are no logs. Aborting...";
        clearMarkup();
        exit;
    }
}

=pod
=item generateReport()

The function responsible for report generation.
It generates a HTML file containing authentication events
already categorised into successful and unsuccessful.

=cut

sub generateReport {

    my $reportWriter;
    my $globbedFileReader;

    my $formattedLogEntry;
    my $successfulTags;
    my $unsuccessfulTags;
    my $successfulAuths;
    my $unsuccessfulAuths;

    my $cronExecutions;
    my $cronExecutionTags;

    my $anacronExecutions;
    my $anacronExecutionTags;

    my $this = shift();
    my $baseDirectory = getcwd();

    my $reportFile = $this->{reportFile};
    my $globbedFile = $this->{globbedFile};

    my $textManipulationDirectory = $this->{textManipulationDirectory};

    my $reportOutputDirectory = catdir($baseDirectory, $textManipulationDirectory);
    my $reportFilePath = catfile($reportOutputDirectory, $reportFile);
    my $globbedFilePath = catfile($reportOutputDirectory, $globbedFile);

    my $documentDesigner = Designer->new();
    my $documentFormatter = Formatter->new();

    open($reportWriter, '>:encoding(UTF-8)', $reportFilePath)
    or die "Could not open $reportFilePath for writing...";

    open($globbedFileReader, '<:encoding(UTF-8)', $globbedFilePath)
    or die "Could not open $globbedFilePath for reading...";

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

    while (my $logEntry = <$globbedFileReader>) {

        chomp($logEntry);

        if ($logEntry =~ /logged in successfully/ && $logEntry !~ /admin/) {
            $formattedLogEntry = $documentFormatter->{openParagraph} . $logEntry . $documentFormatter->{closeParagraph};
            $successfulTags .= $formattedLogEntry;
            $successfulAuths++;
        }

        if ($logEntry =~ /Failed to login/ && $logEntry !~ /admin/) {
            $formattedLogEntry = $documentFormatter->{openParagraph} . $logEntry . $documentFormatter->{closeParagraph};
            $unsuccessfulTags .= $formattedLogEntry;
            $unsuccessfulAuths++;
        }

        if ($logEntry =~ /run-parts/ && $logEntry !~ /CROND/) {
            $formattedLogEntry = $documentFormatter->{openParagraph} . $logEntry . $documentFormatter->{closeParagraph};
            $cronExecutionTags .= $formattedLogEntry;
            $cronExecutions++;
        }

        if ($logEntry =~ /Anacron/ && $logEntry !~ /CROND/) {
            $formattedLogEntry = $documentFormatter->{openParagraph} . $logEntry . $documentFormatter->{closeParagraph};
            $anacronExecutionTags .= $formattedLogEntry;
            $anacronExecutions++;
        }

    }

    if(defined($successfulTags) && defined($successfulAuths)){
        print $reportWriter $successfulTags;
        print $reportWriter $documentFormatter->{openHeader} . "Successful Authentications: " . $successfulAuths . $documentFormatter->{closeHeader};
    }

    if(defined($unsuccessfulTags) && defined($unsuccessfulAuths)){
        print $reportWriter $unsuccessfulTags;
        print $reportWriter $documentFormatter->{openHeader} . "Unsuccessful Authentications: " . $unsuccessfulAuths . $documentFormatter->{closeHeader};
    }

    if(defined($cronExecutionTags) && defined($cronExecutions)){
        print $reportWriter $cronExecutionTags;
        print $reportWriter $documentFormatter->{openHeader} . "Cronjob Executions: " . $cronExecutions . $documentFormatter->{closeHeader};
    }

    if(defined($anacronExecutionTags) && defined($anacronExecutions)){
        print $reportWriter $anacronExecutionTags;
        print $reportWriter $documentFormatter->{openHeader} . "Anacronjob Executions: " . $anacronExecutions . $documentFormatter->{closeHeader};
    }

    print $reportWriter $documentFormatter->{closeBody};
    print $reportWriter $documentFormatter->{closeHtml};

    close $reportWriter;
    close $globbedFileReader;
}

=pod
=item generateList()

The function responsible for list generation.
It generates a HTML file containg the emails of users
that have authenticated during the reporting period.

=cut

sub generateList {

    my $reportReader;
    my $presentationWriter;

    my @userAuthentications;
    my @userAuthenticationsUnique;

    my $this = shift();
    my $reportFile = $this->{reportFile};
    my $globbedFile = $this->{globbedFile};
    my $presentationFile = $this->{presentationFile};
    my $reportingPeriod = $this->{reportingPeriod};

    my $documentDesigner = Designer->new();
    my $documentFormatter = Formatter->new();

    open($reportReader, '<:encoding(UTF-8)', $reportFile)
    or die "Could not open $reportFile for reading...";

    open($presentationWriter, '>:encoding(UTF-8)', $presentationFile)
    or die "Could not open $presentationFile for writing...";

    print $presentationWriter $documentFormatter->{openHtml};
    print $presentationWriter $documentFormatter->{openHead};
    print $presentationWriter $documentFormatter->{openStyle};

    print $presentationWriter $documentDesigner->{indentSelector} . "body" . $documentDesigner->{openBlock};
    print $presentationWriter $documentDesigner->{indentBlock}. "background-color: " . $documentDesigner->{backgroundColor};
    print $presentationWriter $documentDesigner->{indentBlock}. "font-family: " . $documentDesigner->{fontFamily};
    print $presentationWriter $documentDesigner->{closeBlock};

    print $presentationWriter $documentDesigner->{indentSelector} . "td, " . "th" . $documentDesigner->{openBlock};
    print $presentationWriter $documentDesigner->{indentBlock}. "text-align: " . $documentDesigner->{textAlign};
    print $presentationWriter $documentDesigner->{indentBlock}. "padding: " . $documentDesigner->{padding};
    print $presentationWriter $documentDesigner->{closeBlock};

    print $presentationWriter $documentDesigner->{indentSelector} . "table" . $documentDesigner->{openBlock};
    print $presentationWriter $documentDesigner->{indentBlock}. "table-layout: " . $documentDesigner->{tableLayout};
    print $presentationWriter $documentDesigner->{indentBlock}. "width: " . $documentDesigner->{tableWidth};
    print $presentationWriter $documentDesigner->{indentBlock}. "margin: " . $documentDesigner->{margin};
    print $presentationWriter $documentDesigner->{closeBlock};

    print $presentationWriter $documentDesigner->{indentSelector} . "td, " . "th, " . "table" . $documentDesigner->{openBlock};
    print $presentationWriter $documentDesigner->{indentBlock}. "border-style: " . $documentDesigner->{borderStyle};
    print $presentationWriter $documentDesigner->{indentBlock}. "border-width: " . $documentDesigner->{borderWidth};
    print $presentationWriter $documentDesigner->{indentBlock}. "border-collapse: " . $documentDesigner->{borderCollapse};
    print $presentationWriter $documentDesigner->{closeBlock};    

    print $presentationWriter $documentFormatter->{closeStyle};
    print $presentationWriter $documentFormatter->{closeHead};
    print $presentationWriter $documentFormatter->{openBody};

    print $presentationWriter $documentFormatter->{openHeader};
    print $presentationWriter "Authentications During " . $reportingPeriod;
    print $presentationWriter $documentFormatter->{closeHeader};

    print $presentationWriter $documentFormatter->{openUnorderedList};

    while (my $reportEntry = <$reportReader>) {

        if(grep {/INFO/} $reportEntry){

            my $indexOffset = 1;
            my $indexLeft = index($reportEntry, "'") + $indexOffset;
            my $indexRight = rindex($reportEntry, "'") + $indexOffset;
            my $stringLength = $indexRight - $indexLeft - $indexOffset;
            my $listEntry = substr($reportEntry, $indexLeft, $stringLength);

            if(grep {/@/} $listEntry){

                my @truncatedIdentifier = split('@', $listEntry);
                my $domain = pop(@truncatedIdentifier);
                my $user = pop(@truncatedIdentifier);
                my $recomposedEntry = join('@', $user, $domain);

                push(@userAuthentications, $recomposedEntry);
            }
        }
    }

    @userAuthenticationsUnique = uniq(@userAuthentications);

    foreach(@userAuthenticationsUnique){
        print $presentationWriter $documentFormatter->{openListEntry} . $_ . $documentFormatter->{closeListEntry};
    }

    print $presentationWriter $documentFormatter->{closeUnorderedList};

    close $presentationWriter;
    close $reportReader;
}

=pod
=item countAuthentications()

The function responsible for authetication breakdown.
It generates a HTML file containing separate tables containing
successful and unsuccessful authentication attempts.
Columns are user email and the corresponding amount of either successful
or unsuccessful authentications.

=cut

sub countAuthentications {

    my $presentationReader;
    my $presentationWriter;
    my $reportReader;

    my @userIdentifiers;

    my $this = shift();
    my $reportFile = $this->{reportFile};
    my $presentationFile = $this->{presentationFile};

    my $documentFormatter = Formatter->new();

    open($presentationReader, '<:encoding(UTF-8)', $presentationFile)
    or die "Unable to open $presentationFile for reading...";

    open($presentationWriter, '>>:encoding(UTF-8)', $presentationFile)
    or die "Unable to open $presentationFile for appending...";

    open($reportReader, '<:encoding(UTF-8)', $reportFile)
    or die "Unable to open $reportFile for reading...";

    while (my $listEntry = <$presentationReader>) {

        if (grep {/<li>/} $listEntry){

            my $indexOffset = 1;
            my $indexLeft = index($listEntry, ">") + $indexOffset;
            my $indexRight = rindex($listEntry, "<") + $indexOffset;
            my $stringLength = $indexRight - $indexLeft - $indexOffset;
            my $userIdentifier = substr($listEntry, $indexLeft, $stringLength);

            push(@userIdentifiers, $userIdentifier);
        }
    }

    while(my @reportContent = <$reportReader>){

        my @successfulConnections = grep {/logged in successfully/} @reportContent;
        my @unsuccessfulConnections = grep {/Failed to login/} @reportContent;

        print $presentationWriter $documentFormatter->{openHeader} . "Authentication Breakdown" . $documentFormatter->{closeHeader};

        print $presentationWriter $documentFormatter->{openTable};
        print $presentationWriter $documentFormatter->{openTableRow};
        print $presentationWriter $documentFormatter->{openTableHeader} . "User Email" . $documentFormatter->{closeTableHeader};
        print $presentationWriter $documentFormatter->{openTableHeader} . "Successful Attempts" . $documentFormatter->{closeTableHeader};
        print $presentationWriter $documentFormatter->{closeTableRow};

        foreach(@userIdentifiers){
            my $userIdentifier;
            my $userIdentifierOccurrences;

            $userIdentifier = $_;
            $userIdentifierOccurrences =  true {/$userIdentifier/} @successfulConnections;

            print $presentationWriter $documentFormatter->{openTableRow};
            print $presentationWriter $documentFormatter->{openTableCell} . $_ . $documentFormatter->{closeTableCell};
            print $presentationWriter $documentFormatter->{openTableCell} . $userIdentifierOccurrences . $documentFormatter->{closeTableCell};
            print $presentationWriter $documentFormatter->{closeTableRow};
        }

        print $presentationWriter $documentFormatter->{closeTable};

        print $presentationWriter $documentFormatter->{openTable};
        print $presentationWriter $documentFormatter->{openTableRow};
        print $presentationWriter $documentFormatter->{openTableHeader} . "User Email" . $documentFormatter->{closeTableHeader};
        print $presentationWriter $documentFormatter->{openTableHeader} . "Unsuccessful Attempts" . $documentFormatter->{closeTableHeader};
        print $presentationWriter $documentFormatter->{closeTableRow};

        foreach(@userIdentifiers){
            my $userIdentifier;
            my $userIdentifierOccurrences;

            $userIdentifier = $_;
            $userIdentifierOccurrences =  true {/$userIdentifier/} @unsuccessfulConnections;

            print $presentationWriter $documentFormatter->{openTableRow};
            print $presentationWriter $documentFormatter->{openTableCell} . $_ . $documentFormatter->{closeTableCell};
            print $presentationWriter $documentFormatter->{openTableCell} . $userIdentifierOccurrences . $documentFormatter->{closeTableCell};
            print $presentationWriter $documentFormatter->{closeTableRow};
        }

        print $presentationWriter $documentFormatter->{closeTable};
        print $presentationWriter $documentFormatter->{closeBody};
        print $presentationWriter $documentFormatter->{closeHtml};
    }

    close $presentationWriter;
    close $presentationReader;
    close $reportReader;
}

=pod
=item parseMarkup()

The function responsible for spreadsheet generation.
It generates a CSV file that associates user names, emails
and authentications count. Note that names are obtained from a
separate markup document and the resulting file will include only
the ones that have authenticated during the reporting period.

=cut

sub parseMarkup {

    my $markupReader;
    my $markupWriter;
    my $logReader;

    my @userEntries;
    my @alphabeticallySortedRecords;
    my @filesLog = glob('*.log *.txt');
    my @filesMarkup = glob('*.xml *.xhtml');

    my $this = shift();
    my $fileRecords = $this->{usersFile};
    my $fileLogs = $this->{globbedFile};

    my $foundMarkups = scalar(@filesMarkup);

    if($foundMarkups != 0){

        foreach (@filesMarkup) {

            open ($markupReader, '<:encoding(UTF-8)', $_)
            or die "Could not open $_ for reading...";

            while (my $markupEntry = <$markupReader>) {
                if (grep{/user mail/} $markupEntry){

                    if($markupEntry !~ /admin/){

                        my $userName = filterMarkup($markupEntry, "fullname", "userid", "\"");
                        my $userMail = filterMarkup($markupEntry, "mail", "useldap", "\"");
                        my $userMailCaseLower = lc($userMail);

                        open ($logReader, '<:encoding(UTF-8)', $fileLogs)
                        or die "Could not open $fileLogs for writing...";

                        my @logEntries;
                        while(my $logEntry = <$logReader>){
                            push(@logEntries, $logEntry);
                        }

                        if(length($userMailCaseLower) != 0){
                            my @userIdentifiers = grep{/$userMailCaseLower/} @logEntries;
                            my @authenticationSuccessful = grep{/logged in successfully/} @userIdentifiers;
                            my @authenticationUnsuccessful = grep{/Failed to login/} @userIdentifiers;

                            my $countSuccessful = scalar(@authenticationSuccessful);
                            my $countUnsuccessful = scalar(@authenticationUnsuccessful);

                            unless($countSuccessful == 0){
                                $countUnsuccessful =~ tr/0/-/;
                                push (@userEntries, $userName . "," . $userMailCaseLower . "," . $countSuccessful . "," . $countUnsuccessful . "\n");
                            }                           
                        }
                    }
                }
            }

            @alphabeticallySortedRecords = sort(@userEntries);
            close $markupReader;
        }

        open ($markupWriter, '>:encoding(UTF-8)', $fileRecords)
        or die "Could not open $fileRecords for writing...";

        foreach (@alphabeticallySortedRecords){
            print $markupWriter $_;
        }

        close $markupWriter;

  } elsif($foundMarkups == 0) {

        print "Users file required. Aborting...";        
        clearSheet();
        clearMarkup();
        exit;
    }
}

=pod
=item filterMarkup()

The function responsible for filtering user names and email addresses
out of the markup document. It is used by parseMarkup().

=cut

sub filterMarkup {

    my $stringInput = $_[0];
    my $filterBeginning = $_[1];
    my $filterEnding = $_[2];
    my $filterSeparator = $_[3];

    my $indexOffset = 1;

    my $indexLeft;
    my $indexRight;
    my $stringLength;
    my $stringUnrefined;
    my $stringRefined;

    $indexLeft = index($stringInput, $filterBeginning) + $indexOffset;
    $indexRight = index($stringInput, $filterEnding) + $indexOffset;
    $stringLength = $indexRight - $indexLeft - $indexOffset;
    $stringUnrefined = substr($stringInput, $indexLeft, $stringLength);

    $indexLeft = index($stringUnrefined, $filterSeparator) + $indexOffset;
    $indexRight = rindex($stringUnrefined, $filterSeparator) + $indexOffset;
    $stringLength = $indexRight - $indexLeft - $indexOffset;
    $stringRefined = substr($stringUnrefined, $indexLeft, $stringLength);

    return $stringRefined;
}

=pod
=item clearMarkup()

Minor function invoked by others to purge HTML files.

=cut

sub clearMarkup {

    my @markupFiles = glob('*.html');
    my $foundReports = scalar(@markupFiles);

    if($foundReports != 0){
        unlink(@markupFiles);
    }
}

=pod
=item clearSheet()

Minor function invoked by others to purge CSV files.

=cut

sub clearSheet {
    my @commaFiles = glob('*.csv');
    my $foundSheets = scalar(@commaFiles);

    if($foundSheets != 0){
        unlink(@commaFiles);
    }
}

1;
