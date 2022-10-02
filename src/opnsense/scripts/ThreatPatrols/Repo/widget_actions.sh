#!/bin/sh

set -e
config_file="/conf/config.xml"

threatpatrols_insert_widget() {
  _first_position=$(__current_widget_sequence | tr ',' '\n' | grep ':00000000-' | cut -d':' -f2 | head -n1)
  _new_list_item="threatpatrols-container:${_first_position:="00000000-col1"}:show"
  _new_widget_sequence="${_new_list_item},$(__current_widget_sequence_wo_threatpatrols)"
  __replace_sequence_tag "${_new_widget_sequence}"
  echo "OK"
  exit 0
}

threatpatrols_remove_widget() {
  _new_widget_sequence="$(__current_widget_sequence_wo_threatpatrols)"
  __replace_sequence_tag "${_new_widget_sequence}"
  echo "OK"
  exit 0
}

__replace_sequence_tag() {
  _sequence_content="${1}"
  if [ $(grep -c '<sequence>' "${config_file}") -ne 1 ]; then
    echo "ERROR: unexpected number of sequence tags, exiting."
    exit 1
  fi
  _temp_config="/tmp/config_temp_$(head /dev/urandom | sha256 | head -c8).xml"
  awk '{sub("<sequence>.*</sequence>", "<sequence>'"${_sequence_content}"'</sequence>"); print}' "${config_file}" > "${_temp_config}"
  xmlwf "${_temp_config}" || (echo "ERROR: new XML config file does not pass xml well-formed test, exiting.")
  mv "${_temp_config}" "${config_file}"
}

__current_widget_sequence() {
  _sequence="$(grep '<sequence>' ${config_file} | head -n1 | cut -d'>' -f2 | cut -d'<' -f1)"
  echo "${_sequence}"
}

__current_widget_sequence_wo_threatpatrols() {
  _sequence="$(__current_widget_sequence | tr ',' '\n' | grep -v threatpatrols | tr '\n' ',')"
  echo "${_sequence%,}"
}

__test_required_files() {
  _binaries="tr awk cut head grep xmlwf sha256"
  for _binary in ${_binaries}; do
    which "${_binary}" > /dev/null || (echo "ERROR: unable to locate required binary \"${_binary}\", exiting."; exit 1)
  done
  if [ ! -f "${config_file}" ]; then
    echo "ERROR: unable to locate config file \"${config_file}\", exiting."
    exit 1
  fi
}

__test_required_files

case ${1} in
  insert)
    threatpatrols_insert_widget
    ;;
  remove)
    threatpatrols_remove_widget
    ;;
  *)
    echo "usage: widget_actions.sh [ insert | remove ]"
    exit 1

esac
