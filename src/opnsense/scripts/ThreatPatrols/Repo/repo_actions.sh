#!/bin/sh

set -e
repos_path="/usr/local/etc/pkg/repos"

threatpatrols_repo_enable()
{
  if [ -f ${repos_path}/ThreatPatrols.conf ]; then
    sed -i "" "s/enabled:.*/enabled: yes/g" ${repos_path}/ThreatPatrols.conf
    if [ $? ]; then
      pkg update --force
    fi
  fi
}

threatpatrols_repo_disable()
{
  if [ -f ${repos_path}/ThreatPatrols.conf ]; then
    sed -i "" "s/enabled:.*/enabled: no/g" ${repos_path}/ThreatPatrols.conf
    if [ $? ]; then
      pkg update --force
    fi
  fi
}

threatpatrols_repo_in_use() {
  if [ -f ${repos_path}/ThreatPatrols.conf ]; then
    grep ': {' ${repos_path}/ThreatPatrols.conf | cut -d':' -f1
  fi
}

threatpatrols_repo_info() {
  if [ -f ${repos_path}/ThreatPatrols.conf ]; then
    echo '{'
    echo '  "name": "'$(threatpatrols_repo_in_use)'",'
    echo '  "url": "'$(cat /usr/local/etc/pkg/repos/ThreatPatrols.conf | grep 'url:' | cut -d '"' -f2)'",'
    echo '  "system_abi": "'$(uname -s):$(uname -r | cut -d'.' -f1):$(uname -p)'"'
    echo '}'
  fi
}

threatpatrols_repo_update_template()
{
  __RepoName__="${1}"
  __RepoPluginAbi__="$(/usr/local/sbin/opnsense-version -a)"

  if [ "${__RepoName__}" = "ThreatPatrolsDevelop" ]; then
    __RepoStreamPath__="develop"
    __RepoPriority__=60
  elif [ "${__RepoName__}" = "ThreatPatrolsTesting" ]; then
    __RepoStreamPath__="testing"
    __RepoPriority__=55
  else
    __RepoName__="ThreatPatrols"
    __RepoStreamPath__="stable"
    __RepoPriority__=50
  fi

  cp "${repos_path}/ThreatPatrols.conf.template" "/tmp/ThreatPatrols.conf"
  sed -i "" "s|__RepoName__|${__RepoName__}|g" "/tmp/ThreatPatrols.conf"
  sed -i "" "s|__RepoPluginAbi__|${__RepoPluginAbi__}|g" "/tmp/ThreatPatrols.conf"
  sed -i "" "s|__RepoStreamPath__|${__RepoStreamPath__}|g" "/tmp/ThreatPatrols.conf"
  sed -i "" "s|__RepoPriority__|${__RepoPriority__}|g" "/tmp/ThreatPatrols.conf"

  if [ ! -f ${repos_path}/ThreatPatrols.conf ]; then
    mv /tmp/ThreatPatrols.conf ${repos_path}/ThreatPatrols.conf
    return 0
  elif [ $(diff /tmp/ThreatPatrols.conf ${repos_path}/ThreatPatrols.conf | wc -l | tr -d '[:blank:]') -gt 0 ]; then
    mv /tmp/ThreatPatrols.conf ${repos_path}/ThreatPatrols.conf
    return 0
  fi
  rm -f /tmp/ThreatPatrols.conf
  return 1
}

threatpatrols_repo_update() {
  if threatpatrols_repo_update_template "${1}"; then
    pkg update --force
  fi
  configctl firmware resync
}

case ${1} in
  enable)
    threatpatrols_repo_enable
    ;;
  disable)
    threatpatrols_repo_disable
    ;;
  in_use)
    threatpatrols_repo_in_use
    ;;
  info)
    threatpatrols_repo_info
    ;;
  update)
    threatpatrols_repo_update "$(threatpatrols_repo_in_use)"
    ;;
  use_stable)
    threatpatrols_repo_update "ThreatPatrols"
    ;;
  use_testing)
    threatpatrols_repo_update "ThreatPatrolsTesting"
    ;;
  use_develop)
    threatpatrols_repo_update "ThreatPatrolsDevelop"
    ;;
  *)
    echo "usage: repo_actions.sh [ enable | disable | in_use | info | update | use_stable | use_testing | use_develop ]"
    exit 1

esac
