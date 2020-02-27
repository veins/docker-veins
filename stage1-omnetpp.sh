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

# prerequisites for OMNeT++
apt-get -y install curl make bison flex libxml2-dev zlib1g-dev


cd /opt
case "$OPP_VERSION" in
5.0)
    curl --location https://gateway.ipfs.io/ipns/ipfs.omnetpp.org/release/${OPP_VERSION}/omnetpp-${OPP_VERSION}-src.tgz | tar -xzv
    ;;
5.1 | 5.1.1 | 5.2 | 5.2.1 | 5.3)
    curl --location https://gateway.ipfs.io/ipns/ipfs.omnetpp.org/release/${OPP_VERSION}/omnetpp-${OPP_VERSION}-src-core.tgz | tar -xzv
    ;;
5.4 | 5.5)
    echo "Error: No mirror configured for this version of OMNeT++"
    ;;
*)
    curl --location https://github.com/omnetpp/omnetpp/releases/download/omnetpp-${OPP_VERSION}/omnetpp-${OPP_VERSION}-src-core.tgz | tar -xzv
esac

ln -s omnetpp-${OPP_VERSION} omnetpp
export PATH=$PATH:/opt/omnetpp/bin
cd omnetpp

case "$OPP_VERSION" in
5.0 | 5.1 | 5.1.1 | 5.2 | 5.2.1)
    # patch configure.user since command line override is not available
    perl -p -i -e s/WITH_TKENV=yes/WITH_TKENV=no/ configure.user
    perl -p -i -e s/WITH_QTENV=yes/WITH_QTENV=no/ configure.user
    ;;
esac

./configure WITH_QTENV=no WITH_OSG=no WITH_OSGEARTH=no
make -j8 base MODE=debug
make -j8 base MODE=release
rm -fr doc out test samples misc config.log config.status


