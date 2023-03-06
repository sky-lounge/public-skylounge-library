## common

> Collection of scripts used by various SkyLounge actions

### label-issue.sh

```
Usage: label-issue.sh [JSON|-] [-h]

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
```
