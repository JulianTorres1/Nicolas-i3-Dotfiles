#!/usr/bin/env fish

# Requires both fish shell and ponymix to work
# https://github.com/falconindy/ponymix

function next-valid-index
	set val $argv[1]
	set lst $argv[2..-1]
	set n (findindex $val $lst)
	if test $n -ge (count $lst)
		set ndx 1
	else
		set ndx (math $n + 1)
	end
	echo $lst[$ndx]
end

set sinks (pactl list short sinks | awk '{print $1}')
set streams (pactl list short sink-inputs | cut -f1)
set current (ponymix -t sink defaults --short | awk '{print $2}'|head -1)

switch $argv[1]
	case set
		set next (ponymix -t sink list --short | grep -i $argv[2]| head -1 |awk '{print $2}')
	case toggle
		set first (ponymix -t sink list --short | grep -i $argv[2]| head -1 |awk '{print $2}')
		set second (ponymix -t sink list --short | grep -i $argv[3]| head -1 |awk '{print $2}')
		if [ $current = $first ]
			set next $second
		else
			set next $first
		end
	case next
		set next (next-valid-entry $current $sinks)
end

if not test $next
	echo 'invalid argument please enter next, set [name], or toggle [name] [name] wherein name is a valid substring in the sink description'
	echo 'Sinks:'
	ponymix -t sink list --short
	return 1
end

for s in $streams
	pactl move-sink-input $s $next
end
pactl set-default-sink $next
ponymix unmute
signal-i3blocks output
signal-i3blocks 5
