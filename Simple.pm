package Mac::OSA::Simple;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS
    %ScriptComponents);
use Mac::Components;
use Mac::OSA;
use Mac::AppleEvents;
use Exporter;
use Carp;

@ISA = qw(Exporter AutoLoader);
@EXPORT = qw(compiled frontier applescript osa_script
    compile_applescript compile_frontier compile_osa_script
    %ScriptComponents);
@EXPORT_OK = @Mac::OSA::EXPORT;
%EXPORT_TAGS = (all => [@EXPORT, @EXPORT_OK]);
$VERSION = '0.10';

tie %ScriptComponents, 'Mac::OSA::Simple::Components';

sub frontier            { _doscript($_[0], 'LAND') }
sub applescript         { _doscript($_[0], 'ascr') }
sub osa_script          { _doscript(@_[0, 1])      }

sub compile_frontier    { _compile_script($_[0], 'LAND') }
sub compile_applescript { _compile_script($_[0], 'ascr') }
sub compile_osa_script  { _compile_script(@_[0, 1])      }

sub execute {
    my($self, $value, $return) = ($_[0], '', '');

    $value = OSAExecute($self->{COMP}, $self->{ID}, 0, 0);
    if ($value) {
        $return = OSADisplay($self->{COMP}, $value, 'TEXT', 0)
            or croak $^E;
        OSADispose($self->{COMP}, $value);
    }
    ($self->{RETURN}) = ($return ? (AEPrint($return) =~ /^Ò(.*)Ó$/) : 1);
    $self->{RETURN};
}

sub dispose {
    my $self = shift;
    if ($self->{ID} && $self->{COMP}) {
        OSADispose($self->{COMP}, $self->{ID});
        delete $self->{ID};
    }
    if ($self->{SCRIPT}) {
        AEDisposeDesc($self->{SCRIPT});
        delete $self->{SCRIPT};
    }
    1;
}

sub compiled {
    my($self, $script, $data) = @_;
    $script = OSAStore(@$self{qw(COMP ID)}, 'scpt', 0) or croak $^E;
    $data = $script->data->get;
    AEDisposeDesc $script;
    $data;
}

sub _compile_script {
    my($text, $c, $comp, $script, $self) = @_;
    $self = bless {COMP => $ScriptComponents{$c},
        TEXT => $text, TYPE => $c}, __PACKAGE__;
    $self->_compile;
}

sub _doscript {
    my($text, $c, $self, $return) = @_;
    $self = _compile_script($text, $c);
    $return = $self->execute;
    $self->dispose;
    $return;
}

sub _compile {
    my $self = shift;
    my($text, $comp, $script, $id) = @_;
    $self->{SCRIPT} = AECreateDesc('TEXT', $self->{TEXT}) or croak $^E;
    $self->{ID} = OSACompile($self->{COMP}, $self->{SCRIPT}, 0)
        or croak $^E;
    $self;
}

sub DESTROY {
    my $self = shift;
    if (exists($self->{ID}) || exists($self->{SCRIPT})) {
        $self->dispose;
    }
}

END {
    foreach my $comp (keys %ScriptComponents) {
        CloseComponent($ScriptComponents{$comp});
    }
}

package Mac::OSA::Simple::Components;

BEGIN {
    use Carp;
    use Tie::Hash ();
    use Mac::Components;
    use Mac::OSA;
    use vars qw(@ISA);
    @ISA = qw(Tie::StdHash);
}

sub FETCH {
    my($self, $comp) = @_;
    if (!$self->{$comp}) {
        $self->{$comp} = 
            OpenDefaultComponent(kOSAComponentType(), $comp)
            or croak $^E;
    }
    $self->{$comp};
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
      speaker.sound (examples.duration, examples.amplitude,
          examples.frequency)
    EOS

    print frontier('clock.now()');

    applescript('beep 3');

=head1 DESCRIPTION

Allows simple access to Mac::OSA.  Just pass the script to the function
for C<frontier()> or C<applescript()>.  Or, pass the script and the
four-character component ID to C<osa_script()>.   Functions return a
value if there is one, or 1 if successful and there is no value.

[Hm.  Should C<frontier()> and/or C<osa_script($script, 'LAND')> launch
Frontier if it is not running?]

Also note that you can get the raw data of a compiled script with:

    $script = compile_applescript($script_text);
    $raw_data = $script->compiled;

(There are also C<compile_frontier> and C<compile_osa_script>).

C<$script> there is an object with parameters like C<SCRIPT> (the
AEDesc containing the compiled script), C<COMP> (the scripting component),
C<ID> (the script ID), and C<TEXT> (the text of the script).

You can manually dispose of the OSA script and the AEDesc with
C<$script-E<gt>dispose>, or let it get disposed of during object destruction.

You can access scripting components via the tied hash C<%ScriptComponents>
which is automatically exported.  Components are only opened if they have not
been already, and are closed when the program exits.


=head1 TODO

Add OSALoad stuff so compiled scripts from resource forks etc.
can files can be used.


=head1 HISTORY

=over 4

=item v0.10, Tuesday, March 9, 1999

Added lots of stuff to get compiled script data.

=item v0.02, May 19, 1998

Here goes ...

=back

=head1 AUTHOR

Chris Nandor F<E<lt>pudge@pobox.comE<gt>>
http://pudge.net/

Copyright (c) 1999 Chris Nandor.  All rights reserved.  This program is free 
software; you can redistribute it and/or modify it under the same terms as 
Perl itself.  Please see the Perl Artistic License.

=head1 SEE ALSO

Mac::OSA, Mac::AppleEvents, Mac::AppleEvents::Simple, macperlcat.

=head1 VERSION

Version 0.10 (Tuesday, March 9, 1999)

=cut
