use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'			=> 'Mac::OSA::Simple',
	'VERSION_FROM'		=> 'Simple.pm',
	'PREREQ_PM'		=> {
    		'Mac::AppleEvents' => 1.25,
    		'Mac::Components'  => 1.02,
    		'Mac::Memory'      => 1.22,
    		'Mac::OSA'         => 1.02,
    		'Mac::Resources'   => 1.03,
    		'Test::More'       => 0,
	},
	'clean'			=> {
		'FILES'	=> 'Mac-OSA-Simple-*'
	},
);
