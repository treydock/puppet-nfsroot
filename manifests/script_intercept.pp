#
define nfsroot::script_intercept (
  $path = $name,
  $after = '#!/bin/sh',
  $fact_name = 'hostname',
  $fact_value = $::hostname,
) {

  $_line = "[ \"x\$(/opt/puppetlabs/bin/facter ${fact_name})\" = \"x${fact_value}\" ] || exit"

  file_line { "intercept ${name}":
    path  => $path,
    after => $after,
    line  => $_line,
    match => '^\[ "x\$\(',
  }

}
