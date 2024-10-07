=pod
=head1 Fabio Elia Locatelli
=head2 fabioelialocatelli@yandex.com
=head3 +64204485500
=encoding utf8
=cut

use strict;
use warnings;

use lib 'Modules';
use Reporter;

my $reporter = Reporter->new({
  reportingPeriod => pop(@ARGV),
  reportingTag =>pop(@ARGV)
});

$reporter->mergeLogs();
$reporter->generateReport();
