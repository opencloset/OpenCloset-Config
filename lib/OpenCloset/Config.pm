package OpenCloset::Config;
# ABSTRACT: OpenCloset config class

use utf8;
use strict;
use warnings;

use Path::Tiny;

our $VERSION = '0.003';

sub load {
    my $conf_file = shift;
    my %opt; %opt = %{ shift; } if ref $_[0] eq 'HASH';
    my %default   = @_;

    $conf_file ||= $ENV{OPENCLOSET_CONFIG};
    die "cannot find config file\n" unless -e $conf_file;
    my $conf = eval path($conf_file)->slurp_utf8;

    my %real_conf;
    if ( $opt{root} ) {
        %real_conf = ( %default, %{ $conf->{ $opt{root} } } );
    }
    else {
        %real_conf = ( %default, %$conf );
    }

    return \%real_conf;
}

1;

# COPYRIGHT

__END__

=head1 SYNOPSIS

    use OpenCloset::Config;

    my $conf              = OpenCloset::Config::load( 'app.conf' );
    my $conf_with_default = OpenCloset::Config::load(
        'app.conf',
        key1 => 'default1',
        key2 => 'default2',
        key3 => 'default3',
        key4 => 'default4',
    );
    my $conf_sub = OpenCloset::Config::load(
        'app.conf',
        { root => 'subkey' },
    );
    my $conf_sub_with_default = OpenCloset::Config::load(
        'app.conf',
        { root => 'subkey' },
        key1 => 'default1',
        key2 => 'default2',
        key3 => 'default3',
        key4 => 'default4',
    );

=head1 DESCRIPTION

...

=func load
