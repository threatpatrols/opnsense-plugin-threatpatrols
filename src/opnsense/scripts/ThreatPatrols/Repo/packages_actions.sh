#!/bin/sh

set -e

threatpatrols_packages_installed()
{
  pkg info --raw --raw-format json-compact --annotations --all | grep 'repository":"ThreatPatrols'
}

case ${1} in
  installed)
    threatpatrols_packages_installed
    ;;
  *)
    echo "usage: packages_actions.sh [ installed ]"
    exit 1

esac
