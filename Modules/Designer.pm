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

    my $googleFont = q(@import url('https://fonts.googleapis.com/css2?family=Ubuntu:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&display=swap'););

    my $object = @_;
    my $this = bless {
    googleFont => "$googleFont\n",
    backgroundColor => "whitesmoke;\n",
    display => "list;/n",
    fontFamily => "Ubuntu, Montserrat, Helvetica, Sans-Serif;\n",
    fontWeight => "450;\n",
    fontSize => "11pt;\n",
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
    indentBlock => "\t\t\t",
    listStyle => "disclosure-closed\n"
  }, $object;

  return $this;
}

1;
