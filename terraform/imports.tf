# The oci_* workspace variables were seeded via the TFE API (the plan needs
# OCI credentials before tfe_variable.infra_variables can create them), so
# adopt them into state instead of recreating. These blocks are no-ops once
# imported and can be removed afterwards.
import {
  to = tfe_variable.infra_variables["oci_tenancy_ocid"]
  id = "toof-infra/toof-infra/var-KibjxGmV3jbQ9xGj"
}

import {
  to = tfe_variable.infra_variables["oci_user_ocid"]
  id = "toof-infra/toof-infra/var-bwqQzYvXe6m22thf"
}

import {
  to = tfe_variable.infra_variables["oci_fingerprint"]
  id = "toof-infra/toof-infra/var-SGpkNx4JuYsujqUv"
}

import {
  to = tfe_variable.infra_variables["oci_private_key"]
  id = "toof-infra/toof-infra/var-dCM1vTTHcz6G7JM6"
}
