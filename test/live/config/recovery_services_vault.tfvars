# config/recovery_services_vault.tfvars
# Tracked, ready-to-run fixture for the test/live harness - one representative
# real-usage instance exercising the module's common path.
#
# Mirrors what an actual landing-zone consumer deploys today: a single vault
# with one daily backup policy schedule, Standard SKU. No for_each fan-out -
# one instance is enough to prove a breaking-change gate.
#
# Maintained by whoever adds a new optional input to the module: update this
# file in the same PR if you want live coverage of it, same discipline as
# updating tests/recovery_services_vault.tftest.hcl.

env = "livetest"

recovery_services_vault = {
  schedules = {
    daily = {
      retention_daily = { count = 7 }
    }
  }
}
