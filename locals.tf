# =========================
# Naming convention helpers
# service-environment_type-location_code-environment_name
# Example: adb-np-uks-dev
# =========================

locals {
  svc = {
    rg    = "rg"
    vnet  = "vnet"
    snet  = "snet"
    nsg   = "nsg"
    vm    = "vm"
    pip   = "pip"
    nic   = "nic"
    adb   = "adb"
    adf   = "adf"
    sa    = "st" # storage account uses 'st' to comply with naming rules
    kv    = "kv"
    law   = "law"
    appi  = "appi"
    acr   = "acr"
    sql   = "sql"
    sqldb = "sqldb"
    bast  = "bast"
  }

  # base segment builder
  seg = "${var.environment_type}-${var.location_code}-${var.environment_name}"

  names = {
    rg   = "${local.svc.rg}-${local.seg}"
    vnet = "${local.svc.vnet}-${local.seg}"
    adb  = "${local.svc.adb}-${local.seg}"
    adf  = "${local.svc.adf}-${local.seg}"
    sa   = "${local.svc.sa}-${local.seg}"
    kv   = "${local.svc.kv}-${local.seg}"
    law  = "${local.svc.law}-${local.seg}"
    appi = "${local.svc.appi}-${local.seg}"
    acr  = "${local.svc.acr}-${local.seg}"
    sql  = "${local.svc.sql}-${local.seg}"
    bast = "${local.svc.bast}-${local.seg}"
  }
}
