package HiD::Generator::JSMin;

# ABSTRACT: minify javascripts 

=head1 SYNOPSIS

In F<_config.yml>:

   plugins:
        - JSMin 
   jsmin:
        sources:
            - js/*.js
        output: js/

=head1 DESCRIPTION

HiD::Generator::JSMin is a plugin for the HiD static blog system
that uses L<Javascript::Minifier> to minify your javascripts.

=head1 CONFIGURATION PARAMETERS

=head2 sources

List of javascript sources to compile. File globs can be used.

=head2 output

Site sub-directory where the minified files will be put.
Defaults to same dir as source.

=cut

use Moose;
with 'HiD::Generator';
use File::Find::Rule;
use Path::Tiny;
use JavaScript::Minifier qw(minify);

use 5.014;

sub generate {
  my($self, $site) = @_;

  my $src = $site->config->{jsmin}{sources};
  my $dest = $site->config->{jsmin}{dest} || 'js/';

  # allow for a single source
  my @js_sources = ref $src ? @$src : $src ? ( $src ) : ();

  foreach my $file ( map { glob $_ } @js_sources) {

    # If there is a min file, skip it, although we should prefer minning
    # ourselves
    if ($file =~ /\.min\./g) { next }

    my $filename = path($file)->basename('.js');

    $site->INFO("* Minifying js file - " . $file);
    open(my $in, $file) or die;
    open(my $out, '>', $dest . $filename . '.min.js') or die;

    minify(input => $in, outfile => $out);

    close($in);
    close($out);

    $site->INFO("* Publishing " . $dest . $filename . '.min.js');
  }

  $site->INFO("* Compiled js files successfully!");
}

__PACKAGE__->meta->make_immutable;
1;
