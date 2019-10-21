#!/usr/bin/bash
vmstat -n | awk 'BEGIN{cpu_count=2}{getline;getline;for(c=cpu_count-1;c>=0;c--){print "CPU: "c" "$(NF-c*3-2)","$(NF-c*3-1)","$(NF-c*3);}}'
