=pod
=head1 Fabio Elia Locatelli
=head2 fabioelialocatelli@yandex.com
=head3 +64204485500
=encoding utf8
=cut

package Designer;

use strict;
use warnings;

sub new{
    my $object = @_;
    my $this = bless {
    backgroundColor => "gainsboro;\n",
    display => "list;/n",
    fontFamily => "Montserrat, Helvetica, Sans-Serif;\n",
    fontWeight => "normal;\n",
    textAlign => "center;\n",
    borderWidth => "1px;\n",
    borderStyle => "solid;\n",
    borderCollapse => "collapse;\n",
    margin => "1.25em;\n",
    padding => "0.25em;\n",
    tableLayout => "auto;\n",
    tableWidth => "35%;\n",
    width => "15em;\n",
    openBlock => "{\n",
    closeBlock => "\t\t}\n",
    indentSelector => "\t\t",
    indentBlock => "\t\t\t"
  }, $object;

  return $this;
}

1;
