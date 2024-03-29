package Media::Info::Mplayer;

use 5.010001;
use strict;
use warnings;
use Log::Any '$log';

use Capture::Tiny qw(capture);
use Log::Any::For::Builtins qw(system);
use Perinci::Sub::Util qw(err);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       get_media_info
               );

our $VERSION = '0.03'; # VERSION

our %SPEC;

$SPEC{get_media_info} = {
    v => 1.1,
    summary => 'Return information on media file/URL',
    args => {
        media => {
            summary => 'Media file/URL',
            schema  => 'str*',
            pos     => 0,
            req     => 1,
        },
    },
    deps => {
        prog => 'mplayer',
    },
};
sub get_media_info {
    require File::Which;

    my %args = @_;

    File::Which::which("mplayer")
          or return err(412, "Can't find mplayer in PATH");
    my $media = $args{media} or return err(400, "Please specify media");

    # make sure user can't sneak in cmdline options to mplayer
    $media = "./$media" if $media =~ /\A-/;

    my ($stdout, $stderr, $exit) = capture {
        local $ENV{LANG} = "C";
        system("mplayer", "-identify", $media,
               "-quiet", "-msglevel", "all=0", "-frames", "0");
    };

    return err(500, "Can't execute mplayer ($exit)") if $exit;
    #mplayer always emits that message?
    #return err(404, "Media file not found")
    #    if $stderr =~ /^mplayer: No such file/m;

    my $info = {};
    $info->{duration} = $1      if $stdout =~ /^ID_LENGTH=(.+)/m;
    $info->{num_channels} = $1  if $stdout =~ /^ID_AUDIO_NCH=(.+)/m;
    $info->{num_chapters} = $1  if $stdout =~ /^ID_CHAPTERS=(.+)/m;
    #$info->{_audio_format} = $1 if $stdout =~ /^ID_AUDIO_FORMAT=(.+)/m;
    for (qw/
               AUDIO_FORMAT
               AUDIO_BITRATE
               AUDIO_RATE
               VIDEO_FORMAT
               VIDEO_BITRATE
               VIDEO_WIDTH
               VIDEO_HEIGHT
               VIDEO_FPS
               VIDEO_ASPECT
           /) {
        $info->{lc($_)} = $1 if $stdout =~ /^ID_\Q$_\E=(.+)/m;
    }

    [200, "OK", $info, {"func.raw_output"=>$stdout}];
}

1;
# ABSTRACT: Return information on media file/URL using mplayer

__END__

=pod

=encoding utf-8

=head1 NAME

Media::Info::Mplayer - Return information on media file/URL using mplayer

=head1 VERSION

version 0.03

=head1 SYNOPSIS

Use directly:

 use Media::Info::Mplayer qw(get_media_info);
 my $res = get_media_info(media => '/home/steven/celine.avi');

or use via L<Media::Info>.

Sample result:

 [
   200,
   "OK",
   {
     audio_bitrate => 128000,
     audio_format  => 85,
     audio_rate    => 44100,
     duration      => 2081.25,
     num_channels  => 2,
     num_chapters  => 0,
   },
   {
     "func.raw_output" => "ID_AUDIO_ID=0\n...",
   },
 ]

=head1 FUNCTIONS


=head2 get_media_info(%args) -> [status, msg, result, meta]

Return information on media file/URL.

Arguments ('*' denotes required arguments):

=over 4

=item * B<media>* => I<str>

Media file/URL.

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head1 SEE ALSO

L<Media::Info>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Media-Info-Mplayer>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Media-Info-Mplayer>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
http://rt.cpan.org/Public/Dist/Display.html?Name=Media-Info-Mplayer

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
