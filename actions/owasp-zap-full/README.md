# SkyLounge OWASP ZAP Full Scan

> An action to run an [OWASP ZAP Full Scan](https://github.com/marketplace/actions/owasp-zap-full-scan) on a specified target

## About

This [custom GitHub action](https://docs.github.com/en/actions/creating-actions/about-custom-actions) runs an [OWASP ZAP Full scan](https://www.zaproxy.org/docs/docker/full-scan/) on the repository, creating an issue entitled "OWASP ZAP Full Scan" and adds a "SkyLounge" label to help track it. The action accepts and passes the following subset of inputs to OWASP's official GitHub Action [OWASP ZAP Full Scan](https://github.com/marketplace/actions/owasp-zap-full-scan) : `target`, `rules_file_name`, `cmd_options`, `fail`. It also accepts the standard SkyLounge input `quiet` to suppress creation / maintenance of a GitHub issue showing summary results, and `issue_title` to change the title of that issue. The underlying OWASP action "runs the ZAP spider against the specified target (by default with no time limit) followed by an optional ajax spider scan and then a full active scan before reporting the results" and maintains an issue entitled "OWASP ZAP Full Scan" in the GitHub repository for the identified alerts. This action's output `issue_num` contains the GitHub issue number of the issue that was maintained.

### ToDo

- [ ] Extend to scan an array of targets
- [ ] Prevent issue writing to reduce data leakage: use reports in "zap_scan" to assess results?
- [ ] Remove scan artifacts (possibly after assessment) to reduce data leakage

## Usage

Basic use with defaults just requires specifying the target:

```yaml
steps:
- name: Scan my target
  uses: skylounge/actions/owasp-zap-full
  with:
    target: 'https://www.example.com'
```

More complex use with a config file of rules (requiring repo check-out) and command options specifying "silence" and alerts only for "WARN" or above:

```yaml
steps:
# Check out the repo
- uses: actions/checkout@v3
# Run the scan
- name: Scan my target
  uses: skylounge/actions/owasp-zap-full
  with:
    target: 'https://www.example.com'
    rules_file_name: './ci/test/owasp-zap.cfg'
    cmd_options: '-s -l WARN'
```

## Inputs

### `target`

*Required* string containing complete URL of the web application to be scanned.

### `rules_file_name`

*Optional* relative filepath within the repo to a [config file](https://github.com/marketplace/actions/owasp-zap-full-scan#inputs) specifying tab-separated-value (TSV) rules to manage alerts from the scan, as described for the underlying [action](https://github.com/marketplace/actions/owasp-zap-full-scan). Defaults to empty. **Requires first checking out the repository.**

### `cmd_options`

*Optional* string or additional command line options to OWASP's [Baseline script](https://www.zaproxy.org/docs/docker/full-scan/). Defaults to empty.

### `fail`

*Optional* boolean whether to fail the action if the scan generates any alerts, corresponding to the `fail_action` input to the underlying [action](https://github.com/marketplace/actions/owasp-zap-full-scan). Defaults to "false."

### `quiet`

*Optional* boolean whether **not** to leave a GitHub issue summarizing results. Defaults to "false".

### `issue_title`

*Optional* string to be the title of the GitHub issue maintained by the action. Defaults to "OWASP ZAP Full Scan".

## Further Reading

For further information please see the following:

Topic | Documentation
------|--------------
GitHub actions | https://docs.github.com/en/actions/quickstart
GitHub issues  | https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues
OWASP ZAP Baseline Scan | https://www.zaproxy.org/docs/docker/full-scan/
OWASP ZAP Baseline GitHub Action | https://github.com/marketplace/actions/owasp-zap-full-scan
