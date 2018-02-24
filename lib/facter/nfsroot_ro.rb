# Fact: nfsroot_ro
#
# Purpose: Return boolean if system is NFS root read-only.
#

Facter.add('nfsroot_ro') do
  #confine :nfsroot => [:true, 'true', true]
  setcode do
    value = false
    cmdline_out = Facter::Util::Resolution.exec('cat /proc/cmdline 2>/dev/null')
    if cmdline_out =~ /\sreadonlyroot/
      value = true
    end

    value
  end
end
