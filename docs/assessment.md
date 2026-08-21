# Sanitized current-state assessment

## Assessment scope

This register covers one authorized Proxmox lab node and its locally configured workloads, storage, backup inventory, and hypervisor-level network structure. Verification occurred on **2026-08-20** using read-only commands.

The assessment intentionally excludes real hostnames, IP and MAC addresses, disk models and serials, VM names and IDs, user accounts, domains, firewall rules, credentials, and customer information.

## Evidence definitions

| Status | Test |
|---|---|
| Verified | Current command output directly supports the finding |
| Verified gap | Current command output confirms the missing or insufficient control |
| Partial | A component exists, but effectiveness or completeness is unproven |
| Not verified | No current evidence supports a conclusion |
| Planned | Desired future state; no implementation claim |

## Evidence register

| ID | Domain | Sanitized observation | Status | Portfolio conclusion |
|---|---|---|---|---|
| EV-001 | Platform | Proxmox VE 9.x was running on a single node | Verified | Platform is suitable for the case study |
| EV-002 | Compute | 4 physical cores, 8 threads and approximately 46 GiB usable RAM | Verified | Capacity is documented without publishing hardware identity |
| EV-003 | Storage | Approximately 1 TB SSD hosts the OS and LVM-thin VM storage | Verified | Primary storage layout is understood |
| EV-004 | Storage | Separate approximately 1 TB rotational disk is mounted as backup storage | Verified | Recovery has a separate physical destination |
| EV-005 | Resilience | No ZFS pool or Linux software RAID was present | Verified gap | Disk failure remains a material availability risk |
| EV-006 | Workloads | One QEMU/KVM VM and zero LXC containers were configured | Verified | Current workload scope is small and known |
| EV-007 | VM baseline | Linux guest profile uses UEFI, Q35, VirtIO SCSI/network and configured guest-agent support | Verified | Modern virtual hardware baseline is documented |
| EV-008 | VM resources | VM has 4 vCPU, 12 GiB fixed memory and a 100 GiB virtual SSD | Verified | Resource allocation is known |
| EV-009 | VM lifecycle | VM was stopped during verification | Verified | No runtime service claim is made |
| EV-010 | Snapshots | Two historical VM snapshots were present | Verified | Rollback points exist but are not treated as backups |
| EV-011 | Backup inventory | 32 backup archives totaling approximately 133 GiB were found | Verified | Backup material exists |
| EV-012 | Backup freshness | Newest observed archive was older than 90 days at assessment time | Verified gap | Recovery point objective is not being maintained |
| EV-013 | Backup scheduling | Cluster backup job count was zero | Verified gap | Backups were not automated through Proxmox scheduling |
| EV-014 | Restore testing | No dated restore-test evidence was available | Not verified | Archive integrity and recovery time remain unknown |
| EV-015 | Network | One active bridge connects the management interface and VM uplink | Verified | Current trust boundary is documented |
| EV-016 | Segmentation | No VLAN-aware bridge setting or per-VM VLAN tag was observed | Verified gap | Management and workload separation is not demonstrated |
| EV-017 | Secondary NIC | Configuration references a second interface not present in the live link list | Partial | Treat as unavailable until hardware/configuration is reconciled |
| EV-018 | VM firewall | VM NIC configuration did not show its firewall flag enabled | Partial | Effective filtering requires a dedicated policy and traffic test |
| EV-019 | Administrative access | Effective SSH authentication settings were not inspected in this assessment | Not verified | No public hardening claim is allowed |
| EV-020 | Monitoring | Health, capacity and security alerting were not evidenced | Not verified | Monitoring is a roadmap item |

## Risk summary

| Risk | Likelihood | Impact | Priority | Rationale |
|---|---|---|---|---|
| Unrecoverable or stale data after failure | High | High | P0 | Backups are not scheduled and restoration is untested |
| Management/workload lateral movement | Medium | High | P1 | Hypervisor and VM share the same untagged bridge |
| Single-disk or single-node outage | Medium | High | P1 | No storage redundancy or alternate node is present |
| Unauthorized administrative access | Unknown | High | P1 | Effective SSH and firewall controls remain unverified |
| Silent service or capacity degradation | Medium | Medium | P1 | No monitoring evidence is available |
| Public disclosure of infrastructure details | Low | High | P1 | Controlled through sanitization and review gates |

Likelihood is a qualitative assessment for prioritization; it is not a measured probability.

## Claims deliberately excluded

This repository does not claim that:

- the environment is high availability;
- VLAN segmentation is currently active;
- a firewall applies least-privilege rules;
- SSH is key-only or root login is disabled;
- backups meet a defined RPO or RTO;
- any backup has passed a restore test;
- monitoring, IDS/IPS, DNSSEC, or Zero Trust is implemented;
- the design is production-ready or compliant with a specific standard.

## Assessment decision

The environment is appropriate for a security improvement case study. Before it could support a business-critical workload, the release gates are recoverability, verified administrative access, network separation, effective firewall policy, and monitoring.
