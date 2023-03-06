#! /bin/bash

set -e

usage () {
  cat <<EOF
Usage: $(basename "$0") [JSON|-] [-h]

Uses 'gh' to set the label of a given GitHub issue to LABEL (def: SkyLounge).

Optional arguments:
  JSON       fallback structure of environment variables (see below)
  -          take fallback JSON structure from standard input (see below)
  -h|--help  print this usage

The following environment variables control the behavior:
  NUM     the number of the GitHub issue to edit
  TITLE   the title of the GitHub issue to edit if NUM is empty
          (default: 'SkyLounge')
  LABEL   the label to apply to the issue (default: 'SkyLounge')
  COLOR   the color to apply to the issue (default: '575757')
  QUIET   whether NOT to log progress to stdout (default: 'true')

For any empty variables, the script falls back to a JSON structure of init-
capped fields corresponding to the environment variables, taken as a string
argument or from standard input if the argument is '-'.

Returns the GitHub issue number of the edited issue as a GitHub action output.
EOF
}

die () { if [ "$QUIET" = false ]; then echo "$1"; usage; fi; exit 1; }
log () { if [ "$QUIET" = false ]; then echo "$1"; fi; }
check_nums () {
  if [ "${#1}" -gt 0 ] && [ "${1//[0-9]/}" != "" ]; then
    die "Don't recognize number $1"
  fi
}
check_bools () {
  while [ "$#" -gt 0 ]; do
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
      'true'|'false') shift;;
      *)  die "Don't recognize boolean $1";;
    esac
  done
}

# Load any fallback JSON
if [ "$1" == '-' ]; then
  read -r JS || die "Can't read from stdin";
elif [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
  usage
  exit 0
elif [ "$#" -eq 1 ]; then
  JS="$1"
elif [ "$#" -gt 1 ]; then
  die "Too many arguments"
fi

JSON=$(echo "$JS" | jq '.' || die "Can't parse as JSON: $JS")

# Set up environment
# [ -n "$GH_TOKEN" ] || die "Requires GH_TOKEN to be set"
JNUM=$(echo "$JSON" | jq -r '.Num // ""')
JTITLE=$(echo "$JSON" | jq -r '.Title // ""')
JLABEL=$(echo "$JSON" | jq -r '.Label // ""')
JCOLOR=$(echo "$JSON" | jq -r '.Color // ""')
JQUIET=$(echo "$JSON" | jq -r '.Quiet // ""')

NUM=${NUM:=${JNUM:=0}}
TITLE=${TITLE:=${JTITLE:=SkyLounge}}
LABEL=${LABEL:=${JLABEL:=${TITLE}}}
COLOR=${COLOR:=${JCOLOR:=575757}}
QUIET=$(echo "${QUIET:=${JQUIET:=true}}" | tr '[:upper:]' '[:lower:]')

check_nums "$NUM" "$COLOR"
check_bools "$QUIET"

log "::group::Variables Seen by $(basename "$0")"
log "NUM=${NUM}"
log "TITLE=${TITLE}"
log "LABEL=${LABEL}"
log "COLOR=${COLOR}"
log "QUIET=${QUIET}"
log "::endgroup::"

# Ensure repo has the desired label
if ! gh label list | grep -q "$LABEL"; then
  gh label create "$LABEL" -c "$COLOR" -d 'Issue created and managed by SkyLounge' 2>/dev/null || die "Can't create label $LABEL"
fi

# Infer the issue number from title
if [ "$NUM" -eq 0 ]; then
  NUM=$(gh issue list -S "is:open $TITLE in:title" --json 'number' -q '[.[].number // 0]|max' 2>/dev/null)
  if [ "$NUM" -gt 0 ]; then
    log "Working on issue $NUM based on title $TITLE"
  else
    NUM=$(gh issue list -S "is:closed $TITLE in:title" --json 'number' -q '[.[].number // 0]|max' 2>/dev/null);
    if [ "$NUM" -gt 0 ]; then
      log "Warning: working on closed issue $NUM based on title $TITLE"
    else
      log "Warning: no issue found"
    fi
  fi
fi

# Label the issue
if [ "${NUM:=0}" -gt 0 ]; then
  gh issue edit "$NUM" --add-label "$LABEL" 2>/dev/null || die "Can't add label to $NUM"
  log "Added label $LABEL to issue $NUM"
fi

# Output the issue_num
echo "::set-output name=issue_num::${NUM:=0}"
