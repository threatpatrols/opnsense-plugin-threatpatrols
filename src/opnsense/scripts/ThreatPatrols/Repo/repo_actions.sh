#!/bin/sh

set -e
repos_path="/usr/local/etc/pkg/repos"

if [ -z "${1}" ]; then
  echo "ERROR: repo action not provided"
  exit 1
fi

enable_threatpatrols_repo()
{
  repo_enable="${1}"
  mv ${repos_path}/${repo_enable}.conf.disabled ${repos_path}/${repo_enable}.conf
  sed -i "" "s/enabled:.*/enabled: yes/g" ${repos_path}/${repo_enable}.conf
  pkg update --force
}

disable_threatpatrols_repos_all()
{
  for f in ${repos_path}/ThreatPatrol*.conf; do
    mv -- "${f}" "${f%.conf}.conf.disabled"
    sed -i "" "s/enabled:.*/enabled: no/g" "${f%.conf}.conf.disabled"
  done
}

inuse_threatpatrols_repo() {
  ls -1 ${repos_path}/ThreatPatrol* | grep '\.conf$' | rev | cut -d'/' -f1 | rev | cut -d'.' -f1
}

manage_threatpatrols_repo()
{
  repo_name="${1}"
  if [ "$(inuse_threatpatrols_repo)" != "${repo_name}" ]; then
    disable_threatpatrols_repos_all
    enable_threatpatrols_repo "${repo_name}"
  fi
}

if [ "${1}" = "inuse" ]; then
  inuse_threatpatrols_repo
elif [ "${1}" = "stable" ]; then
  manage_threatpatrols_repo "ThreatPatrols"
elif [ "${1}" = "testing" ]; then
  manage_threatpatrols_repo "ThreatPatrolsTesting"
elif [ "${1}" = "develop" ]; then
  manage_threatpatrols_repo "ThreatPatrolsDevelop"
else
  echo "ERROR: unknown repo action requested"
  exit 1
fi
