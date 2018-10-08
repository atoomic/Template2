#============================================================= -*-perl-*-
#
# t/stash-xs.t
#
# Template script testing (some elements of) the XS version of
# Template::Stash
#
# Written by Andy Wardley <abw@wardley.org>
#
# Copyright (C) 1996-2009 Andy Wardley.  All Rights Reserved.
#
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
#========================================================================

use strict;
use warnings;
use lib qw( ./lib ../lib ../blib/lib ../blib/arch ./blib/lib ./blib/arch );
use Template::Constants qw( :status );
use Template;
use Template::Test;
use Template::Stash::XS;

my $count = 20;
my $data = {
    foo => 10,
    bar => {
        baz => 20,
    },
    something => {
      longer => {
         than => {
          usual => 12345
         }
      }
    },
};

use Benchmark::Dumb qw(:all);

my $stash = Template::Stash::XS->new($data);

print "... check\n";
match( $stash->get('bar.baz'), 20 );
match( $stash->get('something.longer.than.usual'), 12345 );
#match( $stash->get('str_eval_die'), '' );

match( $stash->get2('bar.baz'), 20 );
match( $stash->get2('something.longer.than.usual'), 12345 );

print "... done\n";

compare( "bar.baz" );
compare( 'something.longer.than.usual' );

exit;

sub compare {
  my ( $input ) = @_;

  cmpthese(
      0.01,    # 1% precision
      {   get_set_normal => sub {
              foreach my $i ( 1..1000 ) {
                $stash->get( $input ); 
                $stash->set( $input, $i ); 
                $stash->set( "$i.$i.$i.$i.$i.$i.$i.$i", $i ); 
              }
              
          },
          get_set_buffer => sub {
              foreach my $i ( 1..1000 ) {
                $stash->get2( $input ); 
                $stash->set2( $input, $i );
                $stash->set2( "$i.$i.$i.$i.$i.$i.$i.$i", $i );
              }

          },
      }
  );

}


exit;

__END__

                     Rate get_normal get_buffer
get_normal     1851+-11/s         --     -99.0%
get_buffer 177500+-1700/s 9490+-110%         --
                   Rate get_normal get_buffer
get_normal 952.1+-1.6/s         --     -98.9%
get_buffer 90540+-440/s  9410+-49%         --