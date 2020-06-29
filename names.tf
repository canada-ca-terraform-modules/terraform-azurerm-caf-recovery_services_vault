# This locals implement the resource correct names based on GC CAF naming convention rules

locals {
  postfix                            = "-rsv"
  maxLenght                          = var.maxLength > 50 ? 50 : var.maxLength # Make sure provided maxLenght does not exceed resource max lenght
  env_4                              = substr(var.env, 0, 4)                   # Make sure env lenght does not exceed 4
  regex                              = "/[^0-9A-Za-z-]/"                       # Anti-pattern to match all characters not in: 0-9, a-z, A-Z, -, _, .
  userDefinedString_replaced         = replace(var.userDefinedString, "-", "_")
  userDefinedString_replaced_shorten = substr(local.userDefinedString_replaced, 0, local.maxLenght - length(local.postfix) - length(local.env_4) - 4)
  name                               = substr(replace("${local.env_4}CNR-${local.userDefinedString_replaced_shorten}${local.postfix}", local.regex, ""), 0, local.maxLenght)
}