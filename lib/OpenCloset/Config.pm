package OpenCloset::Config;
# ABSTRACT: OpenCloset config class

use utf8;

use Moo;
use MooX::TypeTiny;
use Types::Standard qw( Str );
use namespace::clean -except => 'meta';

our $VERSION = '0.003';

use Path::Tiny;

has "file" => (
    is      => "ro",
    isa     => Str,
    default => sub { $ENV{OPENCLOSET_CONFIG} },
);

has "conf" => ( is => "lazy" );

sub _build_conf {
    my $self = shift;

    my $conf_file = $self->file;
    die
        "Cannot find config file. You can set OPENCLOSET_CONFIG environment variable for default config file path.\n"
        unless $conf_file && -e $conf_file;

    my $conf = eval path($conf_file)->slurp_utf8;

    return $conf;
}

sub dbic {
    my $self = shift;

    my $conf = $self->conf;
    unless ( $conf->{database} ) {
        warn "database section is needed\n";
        return;
    }

    my %dbic_conf = (
        dsn      => $conf->{database}{dsn},
        user     => $conf->{database}{user},
        password => $conf->{database}{pass},
        %{ $conf->{database}{opts} },
    );

    return \%dbic_conf;
}

sub chi {
    my $self = shift;

    my $conf = $self->conf;
    unless ( $conf->{cache} ) {
        warn "cache section is needed\n";
        return;
    }
    unless ( $conf->{cache}{dir} ) {
        warn "cache.dir section is needed\n";
        return;
    }

    my %cache_conf = (
        driver   => "File",
        root_dir => $conf->{cache}{dir},
    );

    return \%cache_conf;
}

sub load {
    my $conf_file = shift;
    my %opt;
    %opt = %{ shift; } if ref $_[0] eq "HASH";
    my %default = @_;

    my $conf = OpenCloset::Config->new( file => $conf_file )->conf;

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
