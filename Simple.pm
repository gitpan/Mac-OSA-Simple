package Mac::OSA::Simple;

use strict;
use vars qw($VERSION @ISA @EXPORT);
use Mac::Components;
use Mac::OSA;
use Mac::AppleEvents;
use Exporter;
use Carp;

@ISA = qw(Exporter AutoLoader);
@EXPORT = qw(frontier applescript osa_script);
$VERSION = sprintf("%d.%02d", q$Revision: 0.02 $ =~ /(\d+)\.(\d+)/);

my(%Comp);

sub frontier    { _doscript($_[0], 'LAND') }
sub applescript { _doscript($_[0], 'ascr') }
sub osa_script  { _doscript(@_[0, 1])      }

sub _doscript {
	my($script, $value, $return, $text, $comp);

	if (!defined($Comp{$_[1]})) {	# get component instance
		$Comp{$_[1]} =
			OpenDefaultComponent(kOSAComponentType(), $_[1]) or croak $^E;
	}
	$comp = $Comp{$_[1]};

	$script = _compile($_[0], $comp);
	$value = OSAExecute($comp, $script, 0, 0);
	if ($value) {
		$return = OSADisplay($comp, $value, 'TEXT', 0)	or croak $^E;
		OSADispose($comp, $value);
	}
	OSADispose($comp, $script);

	return $return ? (AEPrint($return) =~ /^Ò(.*)Ó$/) : 1;
}

sub _compile {
	my($script, $id);
	$script = AECreateDesc('TEXT', $_[0])	or croak $^E;
	$id = OSACompile($_[1], $script, 0)		or croak $^E;
	AEDisposeDesc($script);
	return $id;
}

END {
	foreach my $comp (keys %Comp) {
		CloseComponent($Comp{$comp});
	}
}

1;
__END__

=head1 NAME

Mac::OSA::Simple - Simple access to Mac::OSA

=head1 SYNOPSIS

	#!perl -wl
	use Mac::OSA::Simple;
	osa_script(<<'EOS', 'LAND');
	  dialog.getInt ("Duration?",@examples.duration);
	  dialog.getInt ("Amplitude?",@examples.amplitude);
	  dialog.getInt ("Frequency?",@examples.frequency);
	  speaker.sound (examples.duration, examples.amplitude, examples.frequency)
	EOS

	print frontier('clock.now()');

	applescript('beep 3');

=head1 DESCRIPTION

Allows simple access to Mac::OSA.  Just pass the script to the function for C<frontier()> or
C<applescript()>.  Or, pass the script and the four-character component ID to C<osa_script()>.
Functions return a value if there is one, or 1 if successful and there is no value.

Hm.  Should C<frontier()> and/or C<osa_script($script, 'LAND')> launch Frontier if it is not
running?

=head1 EXPORT

Exports functions C<frontier()>, C<applescript()>, C<osa_script()>.

=head1 HISTORY

=over 4

=item v0.02, May 19, 1998

Here goes ...

=back

=head1 AUTHOR

Chris Nandor F<E<lt>pudge@pobox.comE<gt>>
http://pudge.net/

Copyright (c) 1998 Chris Nandor.  All rights reserved.  This program is free 
software; you can redistribute it and/or modify it under the same terms as 
Perl itself.  Please see the Perl Artistic License.

=head1 SEE ALSO

Mac::OSA, Mac::AppleEvents, Mac::AppleEvents::Simple, macperlcat.

=head1 VERSION

Version 0.02 (27 May 1998)

=cut
