=pod
=head1 Fabio Elia Locatelli
=head2 fabioelialocatelli@yandex.com
=head3 +64204485500
=encoding utf8
=cut

use strict;
use warnings;

use lib 'Modules';
use Filter;

my $filter = Filter->new({
  reportingPeriod => pop(@ARGV)
});

$filter->mergeLogs();
$filter->generateReport();
$filter->generateList();
$filter->countAuthentications();
