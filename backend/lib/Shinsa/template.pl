#! /usr/bin/perl

my @modules = qw( Exam Schedule User Login Group Score Role );

our $template = <<EOF;
package Shinsa::<module>;
use base qw( Shinsa::DBO );

1;
EOF

foreach my $module (@modules) {
	my $copy = $template;
	$copy =~ s/<module>/$module/g;
	open my $fh, '>', "$module.pm" or die $!;
	print $fh $copy;
	close $fh
}
