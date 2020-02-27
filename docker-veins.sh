#!/bin/bash

set -e

docker container run \
	--mount type=tmpfs,destination=/tmp \
	--privileged \
	--read-only \
	--interactive \
	--tty \
	--rm \
	--volume $(pwd):/work \
	"$1" \
	--launchd --chdir "$2" "${@:3}"

