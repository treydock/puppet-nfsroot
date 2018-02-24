require 'spec_helper'

describe 'nfsroot_ro Fact' do
  context 'readonlyroot in cmdline' do
    before :each do
      Facter.clear
      #Facter.fact(:nfsroot).stubs(:value).returns(true)
      Facter::Util::Resolution.stubs(:exec).with('cat /proc/cmdline 2>/dev/null').returns('initrd=boot/RedHat-7.2-x86_64-initrd.img network net.ifnames=0 biosdevname=0 root=nfs:10.11.200.3:/owens_root_rhel72_0,vers=3,tcp,rw,nfsvers=3,async,rsize=65536,wsize=65536 readonlyroot console=tty console=ttyS1,115200 nosmap build=true BOOT_IMAGE=boot/RedHat-7.2-x86_64-vmlinuz BOOTIF=01-7c-d3-0a-b1-61-02')
    end

    it "should return true" do
      expect(Facter.fact(:nfsroot_ro).value).to eq(true)
    end
  end

  context 'readonlyroot not in cmdline' do
    before :each do
      Facter.clear
      #Facter.fact(:nfsroot).stubs(:value).returns(true)
      Facter::Util::Resolution.stubs(:exec).with('cat /proc/cmdline 2>/dev/null').returns('initrd=boot/RedHat-7.2-x86_64-initrd.img network net.ifnames=0 biosdevname=0 root=nfs:10.11.200.3:/owens_root_rhel72_0,vers=3,tcp,rw,nfsvers=3,async,rsize=65536,wsize=65536 noreadonlyroot console=tty console=ttyS1,115200 nosmap build=true BOOT_IMAGE=boot/RedHat-7.2-x86_64-vmlinuz BOOTIF=01-7c-d3-0a-b1-61-02')
    end

    it "should return false" do
      expect(Facter.fact(:nfsroot_ro).value).to eq(false)
    end
  end
end
