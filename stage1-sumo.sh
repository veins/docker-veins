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

# prerequisites for SUMO
apt-get -y install git curl cmake libxerces-c-dev libgdal-dev libproj-dev libfox-1.6-dev

export SUMO_TAG=v$(echo "$SUMO_VERSION" | tr . _)

cd /opt
git clone --depth 1 --branch "${SUMO_TAG}" https://github.com/eclipse/sumo sumo-${SUMO_VERSION}
ln -s sumo-${SUMO_VERSION} sumo
export PATH=$PATH:/opt/sumo/bin
cd sumo

case "$SUMO_VERSION" in
0.30.0)
    # SUMO 0.30.0 needs a patch to compile
    cat /tmp/sumo-0.30.0.patch | patch -p1
    mv sumo/* .
    rmdir sumo
    ;;
0.32.0)
    # SUMO 0.32.0 needs a patch to compile
    curl --location https://github.com/eclipse/sumo/files/2159974/patch-sumo-0.32.0-ComparatorIdLess.txt | patch -p1
    ;;
1.0.0 | 1.0.1 | 1.2.0)
    echo "Error: this version of SUMO will not compile without GUI support, which this .def file does not install."
esac

case "$SUMO_VERSION" in
0.30.0 | 0.32.0)
    make -f Makefile.cvs
    ./configure
    make -j8
    ;;
*)
    cd build
    cmake ..
    make -j8
    cd ..
    ;;
esac

rm -fr .git docs build tests
