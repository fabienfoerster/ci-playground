#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o errtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


function help {
	echo "Usage: $(basename $0) [<newversion> | major | minor | patch]"
}

if [ -z "$1" ] || [ "$1" = "help" ]; then
	help
	exit
fi

__release=$1


if [[ -d ".git" ]]; then

    # Checks if there are any uncommitted changes in git
	changes=$(git status --porcelain)

	if [[ -z "${changes}" ]]; then
		echo "Bumping version of server project with [$__release]"
        __version_file=$(mktemp) # avoid creating untracked files so version doesn't become -dirty.
        if [ "$__release" = "beta" ] || [ "$__release" = "release" ] || [ "$__release" = "patch" ]; then
          "$__dir"/scripts/calVer --cmd "$__release" >> "$__version_file"
        else
          echo "$__release" >> "$__version_file"
        fi
        __version=$(cat "${__version_file}")



        # shellcheck disable=SC2086
        __tag="v${__version}"
        echo "Tagging git repository with version [${__tag}]"
        git add .
        git commit --allow-empty -m "Bump version to ${__tag}"
        # shellcheck disable=SC2086
        git tag ${__tag}
        git push origin && git push origin "${__tag}"
	else
		echo "Please commit staged files prior to bumping"
	fi
else
	echo "No git repo configured"
fi