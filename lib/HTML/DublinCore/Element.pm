package HTML::DublinCore::Element;

use constant DC_ELEMENT_NAME		=> 0;
use constant DC_ELEMENT_QUALIFIER	=> 1;
use constant DC_ELEMENT_CONTENT		=> 2;
use constant DC_ELEMENT_LANGUAGE	=> 3;
use constant DC_ELEMENT_SCHEME		=> 4;

=head1 NAME

HTML::DublinCore::Element - Class for representing a DC element

=head1 SYNOPSIS

    my $element = $dc->element( 'Title' );
    print "title content: ", $element->content(), "\n";
    print "title qualifier: ", $element->qualifier(), "\n";
    print "title language: ", $element->language(), "\n";
    print "title scheme: ", $element->scheme(), "\n";

=head1 DESCRIPTION

HTML::DublinCore methods such as element(), elements(), title(), etc return
HTML::DublinCore::Element objects as their result. These can be queried 
further to extract an elements content, qualifier, language, and schema. For a 
definition of these attributes please see RFC 2731 and 
L<http://www.dublincore.org>.

=head1 METHODS

=head2 new()

The constructor which you won't have to use, but which is used internally
when parsing the Dublin Core out of an HTML document.

=cut

sub new { 
    return bless [];
}

=head2 content()

Gets and sets the content of the element. This will be the most 
often used HTML::DublinCore::Element method since you will want to get 
at the content of the element. 
    
    ## extract the element
    my $title = $dc->element( 'title' );
    print $title->content();

    ## or you can chain them together
    print $dc->element( 'title' )->content();

=cut

sub content {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_CONTENT ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_CONTENT ] ) );
}

=head2 qualifier()

Gets and sets the qualifier used by the element.

=cut

sub qualifier {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_QUALIFIER ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_QUALIFIER ] ) );
}

=head2 language()

Gets and sets the language scheme if any is used in the specified element.

=cut

sub language {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_LANGUAGE ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_LANGUAGE ] ) );
}

=head2 scheme()

Gets and sets the scheme used by the element. 

=cut
 
sub scheme {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_SCHEME ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_SCHEME ] ) );
}

=head2 name()

Gets and sets the element name (title, creator, date, etc). This method
isn't often used because you the name is often used to retrieve the element
object with HTML::DublinCore::element(), or the like.

=cut

sub name {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_NAME ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_NAME ] ) );
}

=head2 asHtml()

A method which returns the element as HTMl.

=cut

sub asHtml {
    my $self = shift;
    my $name = ucfirst( $self->name() );
    if ( $self->qualifier() ) { $name .= '.' . $self->qualifier(); }
    my $content = $self->content();
    my $scheme = $self->scheme();
    my $lang = $self->language();

    my $html = qq(<meta name="DC.$name" content="$content");
    if ( $scheme ) { 
	$html .= qq( scheme="$scheme"); 
    }
    if ( $language ) { 
	$html .= qq( lang="$lang");
    } 
    $html .= '>';
    return ( $html );
}

=head1 SEE ALSO

=over 4

=item * HTML::DublinCore

=back

=head1 AUTHORS

=over 4

=item * Ed Summers E<lt>ehs@pobox.comE<gt>

=back

=cut

sub _clean {
    my $x = shift || '';
    $x=~s/</&lt;/g;
    $x=~s/>/&gt;/g;
    $x=~s/&/&amp;/g;
    return( $x );
}

1;
