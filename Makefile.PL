
use strict;
use warnings;

use 5.010001;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Return information on media file/URL using mplayer",
  "AUTHOR" => "Steven Haryanto <stevenharyanto\@gmail.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Media-Info-Mplayer",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Media::Info::Mplayer",
  "PREREQ_PM" => {
    "Capture::Tiny" => 0,
    "File::Which" => 0,
    "Log::Any" => 0,
    "Log::Any::For::Builtins" => 0,
    "Perinci::Sub::Util" => "0.37",
    "Rinci" => "v1.1.40"
  },
  "TEST_REQUIRES" => {
    "File::Spec" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::More" => 0
  },
  "VERSION" => "0.03",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Capture::Tiny" => 0,
  "File::Spec" => 0,
  "File::Which" => 0,
  "IO::Handle" => 0,
  "IPC::Open3" => 0,
  "Log::Any" => 0,
  "Log::Any::For::Builtins" => 0,
  "Perinci::Sub::Util" => "0.37",
  "Rinci" => "v1.1.40",
  "Test::More" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



