red="\e[0;31m"
green="\e[0;32m"
yellow="\e[0;33m"
blue="\e[0;34m"
TOA="\e[0m" # No Color

if [[ $cfg_log_level == "" ]]; then
  cfg_log_level=4
fi

function logError () {
  if [[ $cfg_log_level == "1" ]] || [[ $cfg_log_level == "2" ]] || [[ $cfg_log_level == "3" ]] || [[ $cfg_log_level == "4" ]]; then
    echo -e "${red}$1${TOA}" 1>&2
  fi
}

function logWarn () {
  if [[ $cfg_log_level == "2" ]] || [[ $cfg_log_level == "3" ]] || [[ $cfg_log_level == "4" ]]; then
    echo -e "${yellow}$1${TOA}" 1>&2
  fi
}

function logInfo () {
  if [[ $cfg_log_level == "3" ]] || [[ $cfg_log_level == "4" ]]; then
    echo -e "${green}$1${TOA}" 1>&2
  fi
}

function logDebug () {
  if [[ $cfg_log_level == "4" ]]; then
    echo -e "${blue}$1${TOA}" 1>&2
  fi
}
