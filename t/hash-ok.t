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
use Test::Deep;
use LTree::Hash 'ltree_hash';

my $original = {
     Top => {
       Science => {
         Astronomy => {
           Astrophysics => '',
           Cosmology => 0,
         },
       },
       Collections => {
         Pictures => {
           Astronomy => {
             Stars => {},
             Galaxies => {key => 'val'},
             Astronauts => undef,
           },
         },
       },
       Hobbies => {
         Amateurs_Astronomy => [1..10],
       },
     },
     Top2 => 'Test value',
};

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

ok(eq_deeply($result,$original));

__END__

