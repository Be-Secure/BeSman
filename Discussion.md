June 21
----

1. Have individual env scripts created for all the tools required for the BeSLab. eg- Gitlab, artifactory. (Refe. from Line 13 BeSLab discussion notes)
2. Have individual env scripts for projects under remediation pipleine.
3. Env script should always map to a OSSPOI.
4. Run a playbook after env installation and capture success status of env installation and push the data to the BeSLab datastore. This is going to be used for aggregating the results of the playbook runs.
  - From the playbook result - The user should be able to identify - env, playbook and status(all the tools are up and running) and timestamp.
  - The result will be published to the dashboard.
  - The result is gonna come back to the end user.
