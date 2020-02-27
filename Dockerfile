# syntax=docker.io/docker/dockerfile:1
# escape=\

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

#
# Tested with Docker version 18.09
#
# Run this container with its `--help` option for details:
# ```
# docker container run -it --rm car2x/docker-veins-0.0.4:latest --help
# ```
#


# ----------------------------------------------------------------------------

FROM --platform=linux/amd64 debian:10 AS stage0

WORKDIR /opt

RUN apt-get update && apt-get install -y bash clang


# ----------------------------------------------------------------------------

FROM stage0 AS stage1-veins

# (--build-arg parameter - warning: default value repeats below)
ARG veins_version=5.0
ARG VEINS_VERSION=$veins_version

COPY stage1-veins.sh .
RUN ./stage1-veins.sh && rm ./stage1-veins.sh


# ----------------------------------------------------------------------------

FROM stage0 AS stage1-omnetpp
# (--build-arg parameter - warning: default value repeats below)
ARG opp_version=5.6
ARG OPP_VERSION=$opp_version

COPY stage1-omnetpp.sh .
RUN ./stage1-omnetpp.sh && rm ./stage1-omnetpp.sh


# ----------------------------------------------------------------------------

FROM stage0 AS stage1-sumo
# (--build-arg parameter - warning: default value repeats below)
ARG sumo_version=1.4.0
ARG SUMO_VERSION=$sumo_version

COPY stage1-sumo.sh .
RUN ./stage1-sumo.sh && rm ./stage1-sumo.sh


# ----------------------------------------------------------------------------

FROM stage0 AS stage1-docker-veins
ARG veins_version=5.0
ARG opp_version=5.6
ARG sumo_version=1.4.0
ARG VEINS_VERSION=$veins_version
ARG OPP_VERSION=$opp_version
ARG SUMO_VERSION=$sumo_version

COPY stage1-docker-veins.sh .
RUN ./stage1-docker-veins.sh && rm ./stage1-docker-veins.sh


# ----------------------------------------------------------------------------

FROM stage0 AS stage2

LABEL version="0.0.4"
LABEL maintainer="sommer@cms-labs.org"

# ENV LC_ALL=C

COPY --from=stage1-veins /opt /opt/
COPY --from=stage1-omnetpp /opt /opt/
COPY --from=stage1-sumo /opt /opt/
COPY --from=stage1-docker-veins /opt /opt/

RUN apt-get install -y python3 make libxml2 libxerces-c3.2 libproj13 lldb valgrind

RUN apt-get -y autoremove && apt-get -y clean && apt-get -y autoclean

WORKDIR /work

ENTRYPOINT ["/bin/bash", "/opt/docker-veins/run.sh"]
CMD ["--help"]


