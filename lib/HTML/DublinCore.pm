package HTML::DublinCore;

use strict;
use warnings;
use Carp qw( croak );
use base qw( HTML::Parser );
use HTML::DublinCore::Element;

our $VERSION = .3;

=head1 NAME

HTML::DublinCore - Extract Dublin Core metadata from HTML 

=head1 SYNOPSIS

  use HTML::DublinCore;

  ## pass HTML to constructor
  my $dc = HTML::DublinCore->new( $html );

  ## get the title element and print it's content
  my $title = $dc->element( 'Title' );
  print "title: ", $title->content(), "\n";

  ## get the same title content in one step
  print "title: ", $dc->element( 'Title' )->content(), "\n";

  ## list context will retrieve all of a particular element 
  foreach my $element ( $dc->element( 'Creator' ) ) {
      print "creator: ",$element->content(),"\n";
  }

  ## qualified dublin core
  my $creation = $dc->element( 'Date.created' )->content();

=head1 DESCRIPTION

HTML::DublinCore is a module for easily extracting Dublin Core metadata
that is embedded in HTML documents. The Dublin Core is a small set of metadata 
elements for describing information resources. Dublin Core is typically 
stored in the E<lt>HEADE<gt> of and HTML document using the E<lt>METAE<gt> tag.
For more information on embedding DublinCore in HTML see RFC 2731 
L<http://www.ietf.org/rfc/rfc2731>

HTML::DublinCore allows you to easily extract, and work with the Dublin Core
metadata found in a particular HTML document.  For a definition of the 
meaning of various Dublin Core elements please see 
L<http://www.dublincore.org/documents/dces/>

=head1 METHODS

=cut

## valid dublin core elements

our @VALID_ELEMENTS = qw(
    title
    creator
    subject
    description
    publisher
    contributor
    date
    type
    format
    identifier
    source
    language
    relation
    coverage
    rights
);

=head2 new()

Constructor which you pass HTML content.

    $dc = HTML::DublinCore->new( $html );

=cut 

sub new {

    my ( $class, $html ) = @_;
    croak( "please supply string of HTML as argument to new()" ) if !$html;

    ## create object and initialize storage
    my $self = bless {}, ref( $class ) || $class;
    map { $self->{ "DC_$_" } = [] } @VALID_ELEMENTS;
    $self->{ "DC_errors" } = [];

    ## initialize our parser, and parse
    $self->init();
    $self->parse( $html );

}

=head2 element() 

This method will return a relevant HTML::DublinCore::Element object. When 
called in a scalar context element() will return the first relevant element
found, and when called in a list context it will return all the relevant 
elements (since Dublin Core elements are repeatable).

    ## create HTML::DublinCore object from HTML
    my $dc = HTML::DublinCore->new( $html );

    ## retrieve first title element
    my $element = $dc->element( 'Title' );
    my $title = $element->content();

    ## shorthand object chaining to extract element content
    my $title = $dc->element( 'Title' )->content();

    ## retrieve all creator elements
    @creators = $dc->element( 'Creator' );
    
You can also retrieve qualified elements in a similar fashion. 

    my $date = $dc->element( 'Date.created' )->content();

In order to fascilitate chaining element() will return an empty 
HTML::DublinCore::Element object when the requested element does not
exist.

=cut

sub element {
    my ($self,$name) = @_;
    $name = lc( $name );

    ## must be a valid DC element (with additional qualifier)
    croak( "invalid Dublin Core element: $name" ) 
	if ! grep { $name =~ /^$_/ } @VALID_ELEMENTS;
    
    ## extract qualifier if present
    my $qualifier; 
    ($name,$qualifier) = split /\./, $name;

    my @elements = ();
    foreach my $element ( @{ $self->{ "DC_$name" } } ) {
	if ( $qualifier and $element->qualifier() =~ /$qualifier/i ) {
	    push( @elements, $element );
	} elsif ( !$qualifier ) {
	    push( @elements, $element );
	}
    }

    if ( wantarray ) { return @elements };
    return( $elements[0] ) if $elements[0];

    ## otherwise return an empty element object to fascilitate
    ## chaining when the element doesn't exist :
    ## $dc->element( 'Title' )->content().

    return( HTML::DublinCore::Element->new() );

}

=head2 elements()

Returns all the Dublin Core elements found as HTML::DublinCore::Element
objects which you can then manipulate further.

    my $dc = HTML::DublinCore->new( $html );
    foreach my $element ( $dc->elements() ) {
	print "name=", $element->name(), "\n";
	print "content=", $element->content(), "\n";
    }

=cut 

sub elements {
    my $self = shift;
    my @elements = ();
    foreach my $type ( @VALID_ELEMENTS ) {
	push( @elements, @{ $self->{ "DC_$type" } } );
    }
    return( @elements );
}

=head2 title()

Returns an HTML::DublinCore::Element object for the title element. You can then 
retrieve content, qualifier, scheme, lang attributes like so. 

    my $dc = HTML::DublinCore->new( $html );
    my $title = $dc->title();
    print "content: ",$title->content(),"\n";
    print "qualifier: ",$title->qualifier(),"\n";
    print "schema: ",$title->schema(),"\n";
    print "language: ",$title->language(),"\n";

Since there can be multiple instances of a particular element type (title,
creator, subject, etc) you can retrieve multiple title elements by calling
title() in a list context.

    my @titles = $dc->title();
    foreach my $title ( @titles ) {
	print "title: ",$title->content(),"\n";
    }

=cut

sub title {
    my $self = shift;
    return( $self->_getElement( 'title', wantarray ) );
}

=head2 creator()

Retrieve creator information in the same manner as title().

=cut

sub creator {
    my $self = shift;
    return( $self->_getElement( 'creator', wantarray ) );
}

=head2 subject()

Retrieve subject information in the same manner as title().

=cut

sub subject {
    my $self = shift;
    return( $self->_getElement( 'subject', wantarray ) );
}

=head2 description()

Retrieve description information in the same manner as title().

=cut

sub description {
    my $self = shift;
    return( $self->_getElement( 'description', wantarray ) );
}

=head2 publisher()

Retrieve publisher  information in the same manner as title().

=cut

sub publisher {
    my $self = shift;
    return( $self->_getElement( 'publisher', wantarray ) );
}

=head2 contribtor()

Retrieve contributor information in the same manner as title().

=cut

sub contributor {
    my $self = shift;
    return( $self->_getElement( 'contributor', wantarray ) );
}

=head2 date()

Retrieve date information in the same manner as title().

=cut

sub date {
    my $self = shift;
    return( $self->_getElement( 'date', wantarray ) );
}

=head2 type()

Retrieve type information in the same manner as title().

=cut

sub type {
    my $self = shift;
    return( $self->_getElement( 'type', wantarray ) );
}

=head2 format()

Retrieve format information in the same manner as title().

=cut

sub format {
    my $self = shift;
    return( $self->_getElement( 'format', wantarray ) );
}

=head2 identifier()

Retrieve identifier information in the same manner as title().

=cut

sub identifier {
    my $self = shift;
    return( $self->_getElement( 'identifier', wantarray ) );
}

=head2 source()

Retrieve source information in the same manner as title().

=cut

sub source {
    my $self = shift;
    return( $self->_getElement( 'source', wantarray ) );
}

=head2 language()

Retrieve language information in the same manner as title().

=cut

sub language {
    my $self = shift;
    return( $self->_getElement( 'language', wantarray ) );
}

=head2 relation()

Retrieve relation information in the same manner as title().

=cut

sub relation {
    my $self = shift;
    return( $self->_getElement( 'relation', wantarray ) );
}

=head2 coverage()

Retrieve coverage information in the same manner as title().

=cut

sub coverage {
    my $self = shift;
    return( $self->_getElement( 'coverage', wantarray ) );
}

=head2 rights()

Retrieve rights information in the same manner as title().

=cut

sub rights {
    my $self = shift;
    return( $self->_getElement( 'rights', wantarray ) );
}

=head2 asHtml() 

Serialize your Dublin Core metadata as HTML E<lt>METAE<gt> tags.

    print $dc->asHtml();

=cut

sub asHtml {
    my $self = shift;
    my $html = '';
    foreach my $name ( @VALID_ELEMENTS ) { 
	foreach my $element ( @{ $self->{ "DC_$name" } } ) {
	    $html .= $element->asHtml() . "\n";
	}
    }
    return( $html );
}

=head1 TODO

=over 4

=item * More comprehensive tests.

=item * Handle HTML entities properly.

=item * Collect error messages so they can be reported out of the object.

=back

=head1 SEE ALSO

=over 4 

=item * HTML::DublinCore::Element

=item * Dublin Core L<http://www.dublincore.org/>

=item * RFC 2731 L<http://www.ietf.org/rfc/rfc2731>

=item * HTML::Parser

=item * perl4lib L<http://www.rice.edu/perl4lib>

=back

=head1 AUTHOR

Ed Summers E<lt>ehs@pobox.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Ed Summers

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut


## start tag hander. This automatically gets called in new() when we 
## parse HTML since HTML::DublinCore inherits from HTML::Parser.

sub start {
    my ( $self, $tagname, $attr, $attrseq, $origtext ) = @_;
    return if ( $tagname ne 'meta' );

    ## lowercase keys
    my %attributes = map { lc($_) => $attr->{$_} } keys( %$attr );

    ## parse name attribute (eg. DC.Identifier.ISBN )
    return( undef ) if ! exists( $attributes{ name } );
    my ( $namespace, $element, $qualifier ) = 
	split /\./, lc( $attributes{ name } );

    ## ignore non-DublinCore data 
    return( undef ) if $namespace ne 'dc';
    
    ## make sure element is dublin core
    if ( ! grep { $element } @VALID_ELEMENTS ) {
	$self->_error( "invalid element: $element found" );
	return( undef );
    }

    ## return if we don't have a content attribute
    if ( ! exists( $attributes{ content } ) ) {
	$self->_error( "element $element lacks content" );
	return( undef );
    }

    ## create a new HTML::DublinCore::Element object 
    my $dc = HTML::DublinCore::Element->new();
    $dc->name( $element );
    $dc->qualifier( $qualifier );
    $dc->content( $attributes{ content } );
    if ( exists( $attributes{ scheme } ) ) {
	$dc->scheme( $attributes{ scheme } );
    } 
    if ( exists( $attributes{ lang } ) ) {
	$dc->language( $attributes{ lang } );
    }
   
    ## stash it for later
    push ( @{ $self->{ "DC_$element" } }, $dc );

}

sub _error {
    my ( $self, $msg ) = @_;
    push( @{ $self->{ DC_errors } }, $msg );
    return( 1 );
}

sub _getElement {
    my ( $self, $element, $wantarray ) = @_;
    my $contents = $self->{ "DC_$element" };
    if ( $wantarray ) { return( @$contents ); }
    elsif ( scalar( @$contents ) > 0 ) { return( $contents->[0] ); }
    return( HTML::DublinCore::Element->new() );
}

1;
