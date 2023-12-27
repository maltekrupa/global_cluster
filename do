#!/usr/bin/env bash

set -euo pipefail

readonly MIX_ENV="${MIX_ENV:-test}"
readonly DEPLOY_TARGET_HOST="$1"
readonly DEPLOY_TARGET_USER="globalcluster"
readonly DEPLOY_TARGET_SSH_CONFIG="/usr/local/github-runner/.ssh/config"
readonly DEPLOY_TARGET_SSH="${DEPLOY_TARGET_USER}@$DEPLOY_TARGET_HOST"
readonly DEPLOY_TARGET_SCP="${DEPLOY_TARGET_USER}@[$DEPLOY_TARGET_HOST]"

function do_help {
  echo "Usage: ./do <thing>"
  echo ""
  echo "  things:"
  echo "  help            -- Show this help"
  echo "  test            -- Run tests"
  echo "  format          -- Check format"
  echo "  static          -- Run a static analysis via credo"
  echo "  build           -- Build tarball"
  echo "  deploy          -- Deploy tarball"
}

function do_test {
  mix test
}

function do_format {
  mix format --check-formatted
}

function do_static {
  mix credo --strict
}

function do_build {
  mix release webtools
}

function do_deploy {
  # Remote
  local r
  r="$(_ssh uname -mo)"
  # Local
  local l
  l="$(uname -mo)"

  if [[ "$r" != "$l" ]]
  then
    echo "Remote target: $r"
    echo "You have: $l"
    echo "These must be equal for a deployment to work"
    exit 1
  fi

  local timestamp
  timestamp="$(date -Iseconds)"
  local version
  version="${GITHUB_SHA::7}"
  local filename
  filename="webtools-${version}-${timestamp}"

  _scp _build/prod/webtools*tar.gz "${DEPLOY_TARGET_SCP}:/tmp/${filename}.tar.gz"
  _ssh "mkdir -p /usr/local/webtools/$filename"
  _ssh "tar xzf /tmp/${filename}.tar.gz -C /usr/local/webtools/$filename"
  _ssh sudo service webtools stop || true
  _ssh "ln -sFf /usr/local/webtools/${filename} /usr/local/webtools/active"
  _ssh "sudo service webtools start > /dev/null 2>&1"
}

function _ssh {
  local cmd="$*"

  if [[ -f "$DEPLOY_TARGET_SSH_CONFIG" ]]; then
    ssh -F /usr/local/github-runner/.ssh/config ${DEPLOY_TARGET_SSH} "$cmd"
  else
    ssh ${DEPLOY_TARGET_SSH} "$cmd"
  fi
}

function _scp {
  if [[ -f "$DEPLOY_TARGET_SSH_CONFIG" ]]; then
    scp -6 -F /usr/local/github-runner/.ssh/config "$@"
  else
    scp -6 "$@"
  fi
}

function main {
  echo "Environment: $MIX_ENV"
  case "$1" in
  "help")
      do_help
      ;;
  "test")
      do_test
      ;;
  "format")
      do_format
      ;;
  "static")
      do_static
      ;;
  "build")
      do_build
      ;;
  "deploy")
      do_deploy
      ;;
  *)
      do_help
      ;;
  esac
  exit 0
}

# Run command or default to help
main "${1:-help}"
