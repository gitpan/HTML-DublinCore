package HTML::DublinCore::Element;

use constant DC_ELEMENT_NAME		=> 0;
use constant DC_ELEMENT_QUALIFIER	=> 1;
use constant DC_ELEMENT_CONTENT		=> 2;
use constant DC_ELEMENT_LANGUAGE	=> 3;
use constant DC_ELEMENT_SCHEME		=> 4;

sub new { 
    return bless [];
}

sub name {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_NAME ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_NAME ] ) );
}

sub qualifier {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_QUALIFIER ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_QUALIFIER ] ) );
}

sub content {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_CONTENT ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_CONTENT ] ) );
}

sub language {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_LANGUAGE ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_LANGUAGE ] ) );
}
 
sub scheme {
    my ($self,$val) = @_;
    if ( defined( $val ) ) { $self->[ DC_ELEMENT_SCHEME ] = $val; }
    return( _clean( $self->[ DC_ELEMENT_SCHEME ] ) );
}

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

sub _clean {
    my $x = shift;
    $x=~s/</&lt;/g;
    $x=~s/>/&gt;/g;
    $x=~s/&/&amp;/g;
    return( $x );
}

1;
