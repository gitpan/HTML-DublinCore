use Test::More tests=>4;

use HTML::DublinCore;

my $html = `cat t/test.html`;
my $dc = HTML::DublinCore->new( $html );

my $title = $dc->title();
isa_ok( $title, 'HTML::DublinCore::Element' );
like( $title->content(), qr/ motores /, 'retrieved single element' );

my @creators = $dc->creator();
is( scalar(@creators), 2, 'retrieved multiple elements' );

is( length( $dc->asHtml() ), 1810, 'asHtml() seems to work' );
