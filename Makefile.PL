#!/usr/bin/perl

use 5.014002;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'LTree::Hash',
    VERSION_FROM      => 'lib/LTree/Hash.pm', # finds $VERSION
    PREREQ_PM         => {
      'Test::LeakTrace' => 0.14, # Only for test
      'Test::Deep' => 0.11, # Only for test
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/LTree/Hash.pm',
       AUTHOR         => 'Zykov Mikhail <zmsmihail@yandex.ru>') : ()),
    LIBS              => [''],
    DEFINE            => '',
    INC               => '-I.',
);

