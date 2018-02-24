#
class nfsroot::foreman (
  $site_data_dir = undef,
  $foreman_user = 'node-api',
  $foreman_build_param = 'nfsroot_build',
  $foreman_conf_group = 'root',
) inherits nfsroot::params {

  include ::osc

  $foreman_url          = lookup('foreman::foreman_url', {'default_value' => undef})
  $foreman_oauth_key    = lookup('foreman::oauth_consumer_key', {'default_value' => undef})
  $foreman_oauth_secret = lookup('foreman::oauth_consumer_secret', {'default_value' => undef})

  $data_dir = pick($site_data_dir, $::osc::base_dir)
  $_etc  = $::osc::etc_dir
  $_sbin = $::osc::sbin_dir
  $_foreman_host_param_conf_path   = "${_etc}/foreman.yaml"
  $_foreman_host_param_script_path = "${_sbin}/host-parameter.py"
  $_foreman_get_host_param_path = "${_sbin}/get-host-parameter.py"
  $_foreman_set_host_param_path = "${_sbin}/set-host-parameter.py"

  ensure_packages(['python-osc-foreman'])

  file { $_foreman_get_host_param_path:
    ensure  => 'absent',
  }

  file { $_foreman_set_host_param_path:
    ensure  => 'absent',
  }

  file { $_foreman_host_param_conf_path:
    ensure  => 'file',
    owner   => 'root',
    group   => $foreman_conf_group,
    mode    => '0640',
    content => template('nfsroot/foreman.yaml.erb'),
  }

  file { $_foreman_host_param_script_path:
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/nfsroot/host-parameter.py',
  }

  file { "${::osc::sbin_dir}/hostgroup-parameter.py":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/nfsroot/hostgroup-parameter.py',
  }

}
