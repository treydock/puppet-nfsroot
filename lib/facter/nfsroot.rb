# Fact: nfsroot
#
# Purpose: Return boolean if system is NFS root.
#

Facter.add('nfsroot') do
  setcode do
    value = false
    cmdline_out = Facter::Util::Resolution.exec('cat /proc/cmdline 2>/dev/null')
    if cmdline_out =~ /root=nfs:/ || cmdline_out =~ /nfsroot=/
      value = true
    end
    value
  end
end
