#
class nfsroot::files (
  $remove = [],
  $setuid = [],
  $capabilities = {},
) inherits nfsroot::params {

  each($remove) |$_remove| {
    if defined(File[$_remove]) {
      File <| title == $_remove |> {
        ensure => 'absent',
      }
    } else {
      file { $_remove:
        ensure => 'absent',
      }
    }
  }

  each($setuid) |$_setuid| {
    if defined(File[$_setuid]) {
      File <| title == $_setuid |> {
        mode => 'u+s',
      }
    } else {
      file { $_setuid:
        mode => 'u+s',
      }
    }
  }

}
