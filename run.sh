#!/bin/bash

## run your planner here
/planner/pandaPIparser $1 $2 temp.parsed
if [ ! -f temp.parsed ]; then
	echo "Parsing failed."
	exit 101
fi

/planner/pandaPIgrounder -q temp.parsed "$(basename "$1" .hddl)-$(basename "$2" .hddl).psas"
rm temp.parsed
if [ ! -f "$(basename "$1" .hddl)-$(basename "$2" .hddl).psas" ]; then
	echo "Grounding failed."
	exit 102
fi

/planner/pandaPIengine --gValue=none --suboptimal --heuristic="rc2(ff)" "$(basename "$1" .hddl)-$(basename "$2" .hddl).psas" | tee panda.log

/planner/pandaPIparser -c panda.log $3
