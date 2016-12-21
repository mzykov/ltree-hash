#!/usr/bin/perl

####################################################################
#                            Top                                   #
#                         /   |  \                                 #
#                 Science Hobbies Collections                      #
#                     /       |              \                     #
#            Astronomy   Amateurs_Astronomy Pictures               #
#               /  \                            |                  #
#    Astrophysics  Cosmology                Astronomy              #
#                                            /  |    \             #
#                                     Galaxies Stars Astronauts    #
####################################################################

use strict;
use warnings;
use utf8;

use Test::More tests => 1;
use Test::LeakTrace;
use LTree::Hash 'ltree_hash';

my $leaks = leaked_count {
  my $hashref = {
       'Top.Science.Astronomy.Astrophysics'            => '',
       'Top.Science.Astronomy.Cosmology'               => 0,
       'Top.Collections.Pictures.Astronomy.Stars'      => {},
       'Top.Collections.Pictures.Astronomy.Galaxies'   => {key => 'val'},
       'Top.Collections.Pictures.Astronomy.Astronauts' => undef,
       'Top.Hobbies.Amateurs_Astronomy'                => [1..10],
  };
  
  my $result = ltree_hash($hashref);
  $hashref = undef;
  $result->{Top2} = 'Test value';
};

ok($leaks == 0);

__END__

