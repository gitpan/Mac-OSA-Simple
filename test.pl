#!perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use strict;
my($loaded, $c, $n);

BEGIN {
    $| = 1;
    local($/, *F);
    open F, $0 or die $!;
    my @n = (<F> =~ /\+\+\$c/gm);  # count number of tests
    $n = scalar @n;
    printf "1..%d\n", $n;
}
END {print "not ok 1\n" unless $loaded;}

use Mac::OSA::Simple;
use Mac::MoreFiles;
use Mac::Processes;

$c = 0;
$loaded = 1;

printf "ok %d\n", ++$c;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $x = $MacPerl::Version;
$x =~ s/\s+.*$//;

ok(($x ge '5.2.0r4' && $] >= 5.004), ++$c,
    'upgrade MacPerl to 5.2.0r4 or better');

my $frontier;
if ($x = $Application{LAND}) {
    printf "ok %d\n", ++$c;
    $frontier = LaunchApplication(LaunchParam->new(
        launchControlFlags => launchContinue|launchNoFileFlags,
        launchAppSpec => $Application{LAND}
    ));
    ok($frontier, ++$c, 'not able to launch Frontier');
    if ($frontier) {
        1 while ! is_running('LAND');
    }
    sleep(10);  # let frontier get ready
    SetFrontProcess(GetCurrentProcess());
}


### init main tests

my($script, $freturn, $return, $type, $cwd, $temp, $class,
    $comp1a, $comp1b, $comp1c, $comp2a, $comp2b, $comp2c,
    $comp3a, $comp3b, $comp3c, $file_a, $file_b, $file_c);
$class = 'Mac::OSA::Simple';
$script = 'return "foo"';
$return = '"foo"';
$freturn = 'foo';
$type = 'ascr';
chomp($cwd = `pwd`);
$file_a = "$cwd:test_a.rsrc";
$file_b = "$cwd:test_b.rsrc";
$file_c = "$cwd:test_c.rsrc";




### do script tests

$temp = applescript($script);
ok(($temp eq $return), ++$c, "applescript() returned $temp, expected $return");

$temp = osa_script($type, $script);
ok(($temp eq $return), ++$c, "osa_script() returned $temp, expected $return");

if ($frontier) {
    $temp = frontier($script);
    ok(($temp eq $freturn), ++$c, "frontier() returned $temp, expected $freturn");
}




### compile script tests

$comp1a = compile_applescript($script);
ok($comp1a->isa($class), ++$c, "comp1a not of type $class");

$temp = $comp1a->execute;
ok(($temp eq $return), ++$c, "comp1a returned $temp, expected $return");

$comp1b = compile_osa_script($type, $script);
ok($comp1b->isa($class), ++$c, "comp1b not of type $class");

$temp = $comp1b->execute;
ok(($temp eq $return), ++$c, "comp1b returned $temp, expected $return");

if ($frontier) {
    $comp1c = compile_frontier($script);
    ok($comp1c->isa($class), ++$c, "comp1c not of type $class");

    $temp = $comp1c->execute;
    ok(($temp eq $freturn), ++$c, "comp1c returned $temp, expected $freturn");
}




### load compiled scripts tests

$comp2a = load_osa_script($comp1a->compiled);
ok($comp2a->isa($class), ++$c, "comp2a not of type $class");

$temp = $comp2a->execute;
ok(($temp eq $return), ++$c, "comp2a returned $temp, expected $return");

$comp2b = load_osa_script($comp1b->compiled);
ok($comp2b->isa($class), ++$c, "comp2b not of type $class");

$temp = $comp2b->execute;
ok(($temp eq $return), ++$c, "comp2b returned $temp, expected $return");

if ($frontier) {
    $comp2c = load_osa_script($comp1c->compiled);
    ok($comp2c->isa($class), ++$c, "comp2c not of type $class");

    $temp = $comp2c->execute;
    ok(($temp eq $freturn), ++$c, "comp2c returned $temp, expected $freturn");
}




### save compiled scripts tests

ok($comp2a->save($file_a), ++$c, "comp2a not able to be saved to $file_a");
ok($comp2b->save($file_b), ++$c, "comp2b not able to be saved to $file_b");
ok($comp2c->save($file_c), ++$c, "comp2a not able to be saved to $file_c")
    if $frontier;




### load saved scripts tests

$comp3a = load_osa_script($file_a, 1);
ok($comp3a->isa($class), ++$c, "comp3a not of type $class");

$temp = $comp3a->execute;
ok(($temp eq $return), ++$c, "comp3a returned $temp, expected $return");

$comp3b = load_osa_script($file_b, 1);
ok($comp3b->isa($class), ++$c, "comp3b not of type $class");

$temp = $comp3b->execute;
ok(($temp eq $return), ++$c, "comp3b returned $temp, expected $return");

if ($frontier) {
    $comp3c = load_osa_script($file_c, 1);
    ok($comp3c->isa($class), ++$c, "comp3c not of type $class");

    $temp = $comp3c->execute;
    ok(($temp eq $freturn), ++$c, "comp3c returned $temp, expected $freturn");
}




### dispose scripts tests

ok($comp1a->dispose, ++$c, "comp1a won't dispose");
ok($comp2a->dispose, ++$c, "comp2a won't dispose");
ok($comp3a->dispose, ++$c, "comp3a won't dispose");

ok($comp1b->dispose, ++$c, "comp1b won't dispose");
ok($comp2b->dispose, ++$c, "comp2b won't dispose");
ok($comp3b->dispose, ++$c, "comp3b won't dispose");

if ($frontier) {
    ok($comp1c->dispose, ++$c, "comp1b won't dispose");
    ok($comp2c->dispose, ++$c, "comp2b won't dispose");
    ok($comp3c->dispose, ++$c, "comp3b won't dispose");
}





### unlink script test files tests

ok(unlink($file_a), ++$c, "file_a won't unlink");
ok(unlink($file_b), ++$c, "file_a won't unlink");
ok(unlink($file_c), ++$c, "file_a won't unlink") if $frontier;

if (!$frontier) {   # make test results look nice if Frontier not around
    for ($c..$n-1) {
        $c++;
        print "ok $c\n";
    }
}




### subroutines

sub ok {
    my($true, $count, $text) = @_;
    printf "%sok %d%s\n", ($true ? '' : 'not '), $count,
        ($true ? '' : " ($text)");
}

sub is_running {
    my %x;
    while (my($k, $v) = each %Process) {
        goto &is_running if !ref($v);
        # hopefully we don't go into a neverending loop here
        $x{$v->processSignature} = 1;
    }
    return exists $x{shift()};
}

__END__
