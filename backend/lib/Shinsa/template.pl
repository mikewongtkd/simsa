#! /usr/bin/perl

my @modules = qw( Examination Schedule Official Panel Examiner User Login Group Score Examinee );

our $template = <<EOF;
package Shinsa::<module>;
use base qw( Shinsa::DBO );

1;
EOF

foreach my $module (@modules) {
	open my $fh, '>', "$module.pm" or die $!;
	close $fh
}
