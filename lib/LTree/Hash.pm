package LTree::Hash;

use 5.014002;
use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use LTree::Hash ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	ltree_hash ltree_array
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&LTree::Hash::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('LTree::Hash', $VERSION);

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

LTree::Hash - fast parsing ltree-like hash

=head1 SYNOPSIS

  use LTree::Hash qw(ltree_hash);
  use Data::Dumper qw(Dumper);
  
  my $hashref = {
       'Top.Science.Astronomy.Astrophysics'            => '',
       'Top.Science.Astronomy.Cosmology'               => 0,
       'Top.Collections.Pictures.Astronomy.Stars'      => {},
       'Top.Collections.Pictures.Astronomy.Galaxies'   => {key => 'val'},
       'Top.Collections.Pictures.Astronomy.Astronauts' => undef,
       'Top.Hobbies.Amateurs_Astronomy'                => [1..10],
  };
  
  my $result = ltree_hash($hashref);
  print STDERR Dumper($result);
  exit 0;
  
  Output is:
  
  $VAR1 = {
    'Top' => {
      'Science' => {
        'Astronomy' => {
          'Astrophysics' => '',
          'Cosmology' => 0
         }
      },
      'Hobbies' => {
        'Amateurs_Astronomy' => [
          1,2,3,4,5,6,7,8,9,10
        ]
      },
      'Collections' => {
        'Pictures' => {
          'Astronomy' => {
            'Astronauts' => undef,
            'Stars' => {},
            'Galaxies' => {
              'key' => 'val'
            }
          }
        }
      }
    }
  };
  
=head1 DESCRIPTION

TODO.

=head1 EXPORT

None by default.

=head1 AUTHOR

Zykov Mikhail, E<lt>miha@pglite.ruE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Zykov Mikhail

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

