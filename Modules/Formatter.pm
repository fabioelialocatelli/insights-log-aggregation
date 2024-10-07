=pod
=head1 Fabio Elia Locatelli
=head2 fabioelialocatelli@yandex.com
=head3 +64204485500
=encoding utf8
=cut

package Formatter;

use strict;
use warnings;

sub new{
  my $object = @_;
  my $this = bless {
    openHtml => "<html>\n",
    openHead => "\t<head>\n",
    openStyle => "\t\t<style>\n",
    openBody => "\t<body>\n",
    openHeader => "\t\t<h3>",
    openHeaderSmall => "\t\t<h4>",
    openParagraph => "\t\t<p>",
    openTable => "\t\t<table>\n",
    openTableHeader => "<th>",
    openTableRow => "\t\t\t<tr>",
    openTableCell => "<td>",
    openUnorderedList => "\t\t<ul>\n",
    openListEntry => "\t\t\t<li>",
    closeHtml => "</html>\n",
    closeHead => "\t</head>\n",
    closeStyle => "\t\t</style>\n",
    closeBody => "\t</body>\n",
    closeHeader => "</h3>\n",
    closeHeaderSmall => "</h4>\n",
    closeParagraph => "</p>\n",
    closeTable => "\t\t</table>\n",
    closeTableHeader => "</th>",
    closeTableRow => "</tr>\n",
    closeTableCell => "</td>",
    closeUnorderedList => "\t\t</ul>\n",
    closeListEntry => "</li>\n"
  }, $object;

  return $this;
}

1;
