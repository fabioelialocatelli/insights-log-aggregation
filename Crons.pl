=pod
=head1 Fabio Elia Locatelli
=head2 fabioelialocatelli@yandex.com
=head3 +64204485500
=encoding utf8
=cut

use strict;
use warnings;

use lib 'Modules';
use Parser;

my $logFilter = Parser->new({
  reportingPeriod => pop(@ARGV)
});

$logFilter->mergeLogs();
$logFilter->generateReport();
$logFilter->generateList();
