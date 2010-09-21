#!/usr/bin/perl -w
# -*- Mode: perl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
# $Id: emacsmode.pl,v 1.1.1.1 2004/03/28 18:06:56 jerry Exp $

sub bail();

$input = $ARGV[0];
$output = ();

if(!$input) {
    bail();
}

%Equivs = (
    'Mode'             => '', # have to map some of these
    'tab-width'        => ':set tabstop=',
    'c-basic-offset'   => ':set shiftwidth=',
    'indent-tabs-mode' => '', # can't just set something, two different commands to turn on/off
);

%Bool = (
    'nil'   => 0,
    'false' => 0,
    'off'   => 0,
    'true'  => 1,
    'on'    => 1,
);

%Modes = (
    'C++' => "cpp",
    'c++' => "cpp",
);

if($input =~ m/.*-\*-.*Mode\:.*-\*-.*$/) {
    #get the meat
    @input = split(/-\*-/, $input);
    $input = $input[1];

    #strip whitespace
    $input =~ s/\s+//g;
}

defined($input) || bail();

@args = split(';', $input);

foreach $arg (@args) {
    my($key, $value) = split(':', $arg);

    if($Equivs{$key}) {
        $output .= "$Equivs{$key}$value\n";
    } else {
        if($key eq "Mode") {
            my($mode) = ();
            if($Modes{$value}) {
                $mode = $Modes{$value};
            } else {
                $mode = $value;
            }

            $output .= ":set filetype=$mode\n";

        } elsif($key eq "indent-tabs-mode") {
            if($Bool{$value} == 0) {
                $output .= ":set expandtab\n";
            } elsif($Bool{$value} == 1) {
                $output .= ":set noexpandtab\n";
            } else {
                $output .= ":echo \"\\nUnknown value: $value\\n\"\n";
            }
        } else {
            $output .= ":echo \"\\nUnknown setting: $key\\n\"\n";
        }
    }
}

print($output);
exit(0);


sub bail() {
    print(":echo \"script failed\"");
    exit(0);
}
