# puppet-nfsroot

## Overview

The nfsroot module manages NFS root systems. This module is somewhat specific to The Ohio Supercomputer Center.

## Usage

Define partition schemas after including `nfsroot::rw` class.

```yaml
nfsroot::rw::rw_label: 'rw'
nfsroot::rw::state_label: 'state'
nfsroot::rw::partition_schemas:
  default:
    disks:
      - /dev/sda
    physical_volumes:
      - /dev/sda1
    volume_groups:
      vg0:
        pv: /dev/sda1
    logical_volumes:
      lv_state:
        vg: vg0
        size: 8g
        fs_type: ext4
        label: "%{hiera('nfsroot::rw::state_label')}"
        order: 1
      lv_rw:
        vg: vg0
        size: 8g
        fs_type: ext4
        label: "%{hiera('nfsroot::rw::rw_label')}"
        order: 2
      lv_swap:
        vg: vg0
        size: 48g
        fs_type: swap
        label: swap
        order: 3
      lv_tmp:
        vg: vg0
        extents: 100%FREE
        fs_type: xfs
        label: tmp
        order: 4
  rw:
    disks:
      - /dev/sda
    physical_volumes:
      - /dev/sda1
    volume_groups:
      vg0:
        pv: /dev/sda1
    logical_volumes:
      lv_swap:
        vg: vg0
        size: 8g
        fs_type: swap
        label: swap
        order: 1
      lv_tmp:
        vg: vg0
        extents: 100%FREE
        fs_type: xfs
        label: tmp
        order: 2
```