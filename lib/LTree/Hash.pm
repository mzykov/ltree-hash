package LTree::Hash;

use 5.014002;
use strict;
use warnings;
use utf8;

our $VERSION = '1.0';

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ('all' => ['ltree_hash']);
our @EXPORT_OK   = (@{$EXPORT_TAGS{'all'}});

require XSLoader;
XSLoader::load('LTree::Hash', $VERSION);

1;

__END__

=head1 NAME

LTree::Hash - fast parsing ltree-like hash

=head1 SYNOPSIS

Transform plain HashRef whose keys are look like LTree 
to deep HashRef. Feet arise from https://www.postgresql.org/docs/current/static/ltree.html

=head1 DESCRIPTION

  use LTree::Hash qw(ltree_hash);
  use Data::Dumper qw(Dumper); # for debug only
  
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
  


=head1 EXPORT

None by default.

=head1 AUTHOR

Zykov Mikhail, E<lt>zmsmihail@yandex.ruE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Zykov Mikhail

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

