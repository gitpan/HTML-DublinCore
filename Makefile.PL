use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		=> 'HTML::DublinCore',
    VERSION_FROM	=> 'lib/HTML/DublinCore.pm', 
    PREREQ_PM		=> { HTML::Parser },
    ABSTRACT_FROM	=> 'lib/HTML/DublinCore.pm', 
    AUTHOR		=> 'Ed Summers <ehs@pobox.com>',
);
