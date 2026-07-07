# The vultr_api_key workspace variable was seeded by hand (bootstrap) before
# tfe_variable.infra_variables could manage it, so the first run after PR #93
# failed with "Key has already been taken". Adopt the existing variable into
# state instead of recreating it. This block is a no-op once imported and can
# be removed afterwards.
import {
  to = tfe_variable.infra_variables["vultr_api_key"]
  id = "toof-infra/toof-infra/var-ygj974GHfRFxUyzU"
}
