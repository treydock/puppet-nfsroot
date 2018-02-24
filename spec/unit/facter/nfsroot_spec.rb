require 'spec_helper'

describe 'nfsroot Fact' do
  context 'nfsroot in cmdline' do
    before :each do
      Facter.clear
      Facter::Util::Resolution.stubs(:exec).with('cat /proc/cmdline 2>/dev/null').returns('initrd=boot/RedHat-7.2-x86_64-initrd.img network net.ifnames=0 biosdevname=0 root=nfs:10.11.200.3:/owens_root_rhel72_0,vers=3,tcp,rw,nfsvers=3,async,rsize=65536,wsize=65536 readonlyroot console=tty console=ttyS1,115200 nosmap build=true BOOT_IMAGE=boot/RedHat-7.2-x86_64-vmlinuz BOOTIF=01-7c-d3-0a-b1-61-02')
    end

    it "should return true" do
      expect(Facter.fact(:nfsroot).value).to be(true)
    end
  end

  context 'nfsroot not in cmdline' do
    before :each do
      Facter.clear
      Facter::Util::Resolution.stubs(:exec).with('cat /proc/cmdline 2>/dev/null').returns('ro root=/dev/mapper/vg0-lv_root rd_NO_LUKS rd_LVM_LV=vg0/lv_root LANG=en_US.UTF-8 rd_NO_MD rd_LVM_LV=vg0/lv_swap SYSFONT=latarcyrheb-sun16 crashkernel=129M@0M  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet')
    end

    it "should return false" do
      expect(Facter.fact(:nfsroot).value).to be(false)
    end
  end
end
