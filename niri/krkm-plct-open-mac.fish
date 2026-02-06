#!/usr/bin/env fish
if dex-autostart -d $argv[1] | string match -q -r "Executing command"
	dex-autostart $argv[1]
else
	xdg-open $argv[2]
end
