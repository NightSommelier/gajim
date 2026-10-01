#!/bin/bash

# SPDX-FileCopyrightText: Contributors to Gajim <https://gajim.org/>
#
# SPDX-License-Identifier: GPL-3.0-only

# Helper script to build virtual environments for omemo-dr, nbxmpp and Gajim on Mac OS
#
# Requirements for this script:
# - Brew: Follow installation instructions at https://brew.sh
#
# Instructions:
# - Always check the following versions variables (check tags dates on Gitlab to make omemo-dr, nbxmpp and Gajim versions match)
# - Always execute this script from the directory where it is located (./gajim-macos-helper.sh)
# - To build (or rebuild) a new version of omemo-dr, nbxmpp and Gajim: ./gajim-macos-helper.sh build
# - To start built version: ./gajim-macos-helper.sh start
#
# Instructions for CI mode:
# - To build (or rebuild) a new version of omemo-dr, nbxmpp and Gajim: ./gajim-macos-helper.sh build ci
# - To create a dmg file: ./gajim-macos-helper.sh create-dmg ci
#
# Instructions to create a release with tagged version of Gajim with CI mode:
# - To build (or rebuild) a new version of Gajim: ./gajim-macos-helper.sh build ci 2.4.1
# - To create a dmg file: ./gajim-macos-helper.sh create-dmg ci 2.4.1
#
# Note: Bash on macOS is stuck in version 3.2, so we avoid using recent things in this script

set -e

# Variables
gajim_version="master"
nbxmpp_version="master"
omemo_dr_version="master"
python_version="3.14"
gajim_git="https://gitlab.com/gajim/gajim"
nbxmpp_git="https://gitlab.com/gajim/python-nbxmpp"
omemo_dr_git="https://gitlab.com/gajim/omemo-dr"
python_dependencies="\
	pyobjc \
	cryptography \
	pillow \
	idna \
	precis-i18n \
	certifi \
	css-parser \
	keyring \
	packaging \
	qrcode \
	SQLAlchemy \
	emoji \
	h2 \
	socksio \
	httpx2 \
	pysequoia"

# Set PATH and DYLD_LIBRARY_PATH for Brew to use Brew Python version (see https://gitlab.com/gajim/gajim/-/work_items/12365)
DEFAULT_PATH="$PATH"
DEFAULT_DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH"
DEFAULT_XDG_DATA_DIRS="$XDG_DATA_DIRS"
if [ "$(uname -m)" == "x86_64" ]
then
	export PATH="/usr/local/bin:/Library/Frameworks/Python.framework/Versions/${python_version}/bin:$PATH"
	export XDG_DATA_DIRS="/usr/local/share:$XDG_DATA_DIRS"
	export DYLD_LIBRARY_PATH="/usr/local/lib:$DYLD_LIBRARY_PATH"
elif [ "$(uname -m)" == "arm64" ]
then
	export PATH="/opt/homebrew/bin:/opt/homebrew/opt/python@${python_version}/bin:$PATH"
	export XDG_DATA_DIRS="/opt/homebrew/share:$XDG_DATA_DIRS"
	export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"
fi
export CI_BUILD=0
export CI_GAJIM_RELEASE=0

function install_brew_dependencies() {
	brew update
	# GitHub Actions macos-15 images ship with a conflicting /opt/homebrew/bin/openssl link (openssl@1.1).
	# Unlink it before installing modern dependencies to avoid link collision errors.
	brew unlink openssl@1.1 2>/dev/null || true
	brew link --overwrite openssl@3 2>/dev/null || true
	brew install --overwrite python@${python_version} gettext librsvg git gtk4 libadwaita pygobject3 adwaita-icon-theme libsoup@3 gst-python gtksourceview5 gstreamer libspelling || {
		brew unlink openssl@1.1 2>/dev/null || true
		brew link --overwrite --force openssl@3 2>/dev/null || true
	}
}

function recreate_venv() {
	if [ -d "./gajim-venv" ]; then
		rm -rf ./gajim-venv
	fi
	python${python_version} -m venv --system-site-packages ./gajim-venv
	source ./gajim-venv/bin/activate
	pip3 install --upgrade pip
	pip3 install --upgrade $python_dependencies pyinstaller
	deactivate
}

function clone_source() {
	if [ -d "./gajim-source" ]; then
		rm -rf ./gajim-source
	fi
	if [ -d "./nbxmpp-source" ]; then
		rm -rf ./nbxmpp-source
	fi
	if [ -d "./omemo-dr-source" ]; then
		rm -rf ./omemo-dr-source
	fi
	if [ "$CI_GAJIM_RELEASE" == 0 ]
	then
		git clone ${nbxmpp_git} ./nbxmpp-source
		git clone ${omemo_dr_git} ./omemo-dr-source
		cd ./nbxmpp-source/
		git checkout ${nbxmpp_version}
		cd ../omemo-dr-source/
		git checkout ${omemo_dr_version}
		cd ../
	else
		gajim_version="$CI_GAJIM_RELEASE"
	fi
	if [ -d "../.git" ]; then
		git clone .. ./gajim-source
	else
		git clone ${gajim_git} ./gajim-source
		cd ./gajim-source/
		git checkout ${gajim_version}
		cd ../
	fi
}

function install_omemo_dr() {
	source ./gajim-venv/bin/activate
	cd ./omemo-dr-source/
	pip3 install .
	cd ../
	deactivate
}

function install_nbxmpp() {
	source ./gajim-venv/bin/activate
	cd ./nbxmpp-source/
	pip3 install .
	cd ../
	deactivate
}

function install_gajim() {
	source ./gajim-venv/bin/activate
	cd ./gajim-source/
	python3 ./make.py build --dist macos
	pip3 install --no-deps .
	cd ../
	deactivate
}

function start_gajim() {
	source ./gajim-venv/bin/activate
	cd ./gajim-source/
	gajim
	deactivate
}

function clean_environment() {
	if [ -d "./gajim-source" ]; then
		rm -rf ./gajim-source
	fi
	if [ -d "./nbxmpp-source" ]; then
		rm -rf ./nbxmpp-source
	fi
	if [ -d "./omemo-dr-source" ]; then
		rm -rf ./omemo-dr-source
	fi
	if [ -d "./gajim-venv" ]; then
		rm -rf ./gajim-venv
	fi
}

function build_new_environment() {
	install_brew_dependencies
	clone_source
	recreate_venv
	install_omemo_dr
	install_nbxmpp
	install_gajim
}

function create_dmg() {
	source ./gajim-venv/bin/activate
	cd ./gajim-source/
	./mac/makebundle.py
	cd ../
	deactivate
}

function main()
{
	# CI
	if [ "$2" == "ci" ]
	then
		export CI_BUILD=1
		if [ ! -z "$3" ]
		then
			export CI_GAJIM_RELEASE="$3"
		fi
	fi
	# Selector
	if [ -z "$1" ]
	then
		usage "$0"
	elif [ "$1" == "build" ]
	then
		build_new_environment
	elif [ "$1" == "create-dmg" ]
	then
		create_dmg
	elif [ "$1" == "start" ]
	then
		start_gajim
	elif [ "$1" == "clean" ]
	then
		clean_environment
	fi
}

function usage()
{
	cat <<- EOS
		$1: macOS Helper to build virtual environments and start Gajim

		build			Build omemo-dr, nbxmpp and Gajim virtual environments
		create-dmg		Create Gajim dmg bundle
		start			Start Gajim
		clean			Delete omemo-dr, nbxmpp and Gajim virtual environments

		build ci [version]	Build omemo-dr, nbxmpp and Gajim system side in CI (optional: with a specific version of Gajim)
		create-dmg ci [version]	Create Gajim dmg installer system side in CI (optional: with a specific version of Gajim)
	EOS
}

main "$@"

export DYLD_LIBRARY_PATH="$DEFAULT_DYLD_LIBRARY_PATH"
export XDG_DATA_DIRS="$DEFAULT_XDG_DATA_DIRS"
export PATH="$DEFAULT_PATH"

exit 0
