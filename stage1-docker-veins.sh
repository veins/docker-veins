#!/bin/bash

#
# docker-veins -- Docker container for quickly building and running Veins simulations anywhere
# Copyright (C) 2020 Christoph Sommer <sommer@cms-labs.org>
#
# Documentation for these modules is at http://veins.car2x.org/
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

set -e

# version info
mkdir -p /opt/docker-veins
cat <<- EOF > /opt/docker-veins/version.txt
	docker-veins-0.0.4
EOF

# help text
mkdir -p /opt/docker-veins
cat <<- EOF > /opt/docker-veins/help.txt
	This container includes:
	- Debian Buster;
	- Veins ${VEINS_VERSION} (for sumo-launchd.py);
	- OMNeT++ ${OPP_VERSION}; and
	- SUMO ${SUMO_VERSION}.
	
	Its runscript will simply run the given command;
	- optionally in parallel to sumo-launchd.py (runscript --launchd option);
	- optionally after changing to a given directory (runscript --chdir option).
	
	You might want to mount a work directory (docker --volume option) to make simulations available in the container, which can then be built and run.

	For example, to compile and run the Veins ${VEINS_VERSION} tutorial simulation in work/src/veins/examples/veins, you would run the following:
	mkdir -p work/src
	cd work/src
	git clone --branch veins-${VEINS_VERSION} https://github.com/sommer/veins veins
	cd ..
	CONTAINER --chdir src/veins -- ./configure
	CONTAINER --chdir src/veins -- make
	CONTAINER --chdir src/veins/examples/veins --launchd -- ./run -u Cmdenv
	head work/src/veins/examples/veins/results/General-\#0.sca

	...with CONTAINER being a shorthand for something like:
	docker container run --mount type=tmpfs,destination=/tmp --privileged --read-only --interactive --tty --rm --volume \$(pwd):/work car2x/docker-veins-0.0.4:latest
EOF

# script for docker-veins
mkdir -p /opt/docker-veins
cat <<- "EOF" > /opt/docker-veins/run-with-launchd.sh
	#!/bin/bash
	set -e
	/opt/veins/sumo-launchd.py -d
	trap "kill $(cat /tmp/sumo-launchd.pid)" EXIT
	"$@"
EOF
chmod a+x /opt/docker-veins/run-with-launchd.sh

# runscript
mkdir -p /opt/docker-veins
cat <<- "EOF" > /opt/docker-veins/run.sh
	#
	# docker-veins -- Docker container for quickly building and running Veins simulations anywhere
	# Copyright (C) 2020 Christoph Sommer <sommer@cms-labs.org>
	#
	# Documentation for these modules is at http://veins.car2x.org/
	#
	# SPDX-License-Identifier: GPL-2.0-or-later
	#
	# This program is free software; you can redistribute it and/or modify
	# it under the terms of the GNU General Public License as published by
	# the Free Software Foundation; either version 2 of the License, or
	# (at your option) any later version.
	#
	# This program is distributed in the hope that it will be useful,
	# but WITHOUT ANY WARRANTY; without even the implied warranty of
	# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	# GNU General Public License for more details.
	#
	# You should have received a copy of the GNU General Public License
	# along with this program; if not, write to the Free Software
	# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
	#
	
	set -e
	
	WITH_LAUNCHD=0
	GETOPT_RESULT=$(getopt --name "docker-veins runscript" --options Vhc:l --longoptions version,help,chdir:,launchd -- "$@")
	eval set -- "$GETOPT_RESULT"
	while true; do
	    case "$1" in
	    -V | --version)
	        cat /opt/docker-veins/version.txt
	        exit 0
	        ;;
	    -h | --help)
	        cat /opt/docker-veins/help.txt
	        exit 0
	        ;;
	    -c | --chdir)
	        shift
	        cd "$1"
	        ;;
	    -l | --launchd)
	        WITH_LAUNCHD=1
	        ;;
	    --)
	        shift
	        break
	        ;;
	    esac
	    shift
	done
	
	# Make sure that we should actually run something
	test "$#" -ge 1 || (echo "docker-veins runscript: No command line to execute. For more information, run this container with its '--help' option."; exit 1)
	
	# set up build/run environment
	export PATH="$PATH:/opt/omnetpp/bin"
	export PATH="$PATH:/opt/sumo/bin"
	
	case "$WITH_LAUNCHD" in
	0)
	    exec "$@"
	    ;;
	1)
	    exec /opt/docker-veins/run-with-launchd.sh "$@"
	    ;;
	esac
EOF
chmod a+x /opt/docker-veins/run.sh

