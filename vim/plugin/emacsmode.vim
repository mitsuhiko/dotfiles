" -*- Mode: vim; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
"
" File: emacsmode.vim
" Author: Jerry Talkington <jerry@smartasfuck.com>
" $Id: emacsmode.vim,v 1.1.1.1 2004/03/28 18:06:56 jerry Exp $

" the max lines to read
"let &modelines = 3

if exists("loaded_emacsmode")
    finish
endif

let loaded_emacsmode = 1

if(has("perl"))
    function ReadEmacsModeLine()
        perl << PERLEND

        $lines = VIM::Eval('byte2line(600)');
        $count = 0;

        while($count < $lines) {
            $line = $curbuf->Get($count);

            if($line =~ m/.*-\*-.*Mode\:.*-\*-.*$/) {
                @line = split(/-\*-/, $line);
                $line = $line[1];
                $line =~ s/\s+//g;
                last;
            }
            $line = undef;
            $count++;
        }

        if(!defined($line)) {
            return;
        }

        %Equivs = ( 
            'Mode'             => '', # have to map some of these
            'tab-width'        => 'tabstop=',
            'c-basic-offset'   => 'shiftwidth=',
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

        @args = split(';', $line);

        foreach $arg (@args) {
            my($key, $value) = split(':', $arg);

            if($Equivs{$key}) {
                VIM::SetOption("$Equivs{$key}$value");
            } else {
                if($key eq "Mode") {
                    my($mode) = ();

                    if($Modes{$value}) {
                        $mode = $Modes{$value};
                    } else {
                        $mode = $value;
                    }

                    VIM::DoCommand("set filetype=$mode");

                } elsif($key eq "indent-tabs-mode") {
                    if($Bool{$value} == 0) {
                        VIM::SetOption("expandtab");
                    } elsif($Bool{$value} == 1) {
                        VIM::SetOption("noexpandtab");
                    } else {
                        VIM::Msg("Unknown value: $value\n");
                    }
                } else {
                    VIM::Msg("Unknown setting: $key\n");
                }
            }
        }

PERLEND
    endfun

else
    function ReadEmacsModeLine()
        let l:i = 1
        " mode line can be in the first 600 bytes
        let l:byteLine = byte2line(600)

        while i < l:byteLine + 1
            let l:lineInput = getline(i)
            if(match(l:lineInput, ".*-\*-.*Mode\:.*-\*-.*$") > -1)
                " have to escape quotes for the command line to work
                let l:lineInput = substitute(l:lineInput, '"', '\\"', "g")

                let l:scriptArgs = "~/.vim/plugin/emacsmode.pl \"" . l:lineInput . "\""

                let l:result = system(l:scriptArgs)

                if exists("l:result")
                    exe l:result
                endif

                break
            endif
            let l:i = l:i + 1
        endwhile
    endfunction
endif

autocmd BufRead * call ReadEmacsModeLine()
