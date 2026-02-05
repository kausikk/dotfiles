#!/usr/bin/env fish
if dex -d $argv[1] | string match -q -r "Executing command"
	dex $argv[1]
else
	xdg-open $argv[2]
end
