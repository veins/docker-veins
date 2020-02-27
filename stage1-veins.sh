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

# prerequisites for Veins
apt-get -y install git python python3

cd /opt

git clone --depth 1 --branch veins-${VEINS_VERSION} https://github.com/sommer/veins veins-${VEINS_VERSION}
ln -s veins-${VEINS_VERSION} veins

cd /opt/veins
rm -fr .git
