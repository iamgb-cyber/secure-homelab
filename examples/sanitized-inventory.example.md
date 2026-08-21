# Sanitized Proxmox Inventory — Example Only

> This file is fictitious. It demonstrates the collector's output style and is not an inventory of a real environment.

- Collector version: 0.1.0
- Generated: 20XX-01-01T12:00:00+00:00
- Privilege context: root
- Privacy: hostnames, addresses, identifiers, serials and object names are intentionally excluded.
- Mutation policy: this collector only reads system state and creates this report file.

## Platform

### Proxmox release

```text
pve-manager/9.x.x/example
```

### Kernel

```text
6.x.x-pve
```

### CPU summary

```text
CPU(s): 8
Model name: Example 4-Core Processor
Thread(s) per core: 2
Core(s) per socket: 4
Socket(s): 1
```

### Memory summary

```text
Mem: 46Gi total, 40Gi available
Swap: 8Gi total, 8Gi available
```

## Physical storage

### Disk summary without device names or serials

```text
disk-01 size_bytes=1000000000000 medium=solid-state-or-virtual transport=sata
disk-02 size_bytes=1000000000000 medium=rotational transport=sata
```

### ZFS pool summary

```text
No ZFS pools detected.
```

### Linux software RAID

```text
Detected md arrays: 0
```

## Proxmox storage configuration

```text
storage_definitions=3
type=dir count=2
type=lvmthin count=1
status=active count=3
```

## Virtual workloads

```text
virtual_machines=1
status=stopped count=1
configured_memory_mb=12288
configured_boot_disk_gb=100
lxc_containers=0
```

## Network structure

```text
interface-01 role=physical-or-passthrough state=up
interface-02 role=bridge state=up
vlan_aware_bridges=0
explicit_vlan_devices=0
```

## Interpretation

This report demonstrates inventory format only. Security conclusions require an authorized reviewer, effective-configuration checks and functional testing.
