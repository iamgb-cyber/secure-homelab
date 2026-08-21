# Backup and isolated restore-test runbook

## Document status

This is a **planned validation procedure**. It records how recovery should be tested; it is not evidence that a restore has already succeeded.

## Objectives

- Demonstrate that a backup is readable and operationally useful.
- Measure actual recovery point and recovery time.
- Validate the workload without connecting a duplicate system to the normal LAN.
- Produce repeatable evidence for future recovery drills.

## Provisional service targets

These targets are illustrative for the lab and require business-owner approval before use for a production service.

| Metric | Provisional target |
|---|---|
| Recovery point objective (RPO) | 24 hours |
| Recovery time objective (RTO) | 4 hours |
| Restore-test frequency | Quarterly and after major platform changes |
| Backup failure notification | Same day |

## Target retention

| Copy | Frequency | Example retention | Failure domain |
|---|---|---|---|
| Local VM backup | Daily | 7 daily, 4 weekly, 3 monthly | Separate local disk |
| Independent recovery copy | Weekly | 4 weekly, 6 monthly | Offline or off-site destination |
| Configuration evidence | After approved changes | Current plus version history | Encrypted private storage |

Retention must be adjusted to capacity, legal requirements, service criticality, and measured change rate.

## Prerequisites

- Authorized maintenance window and named test owner.
- Current storage-health and free-space review.
- Selected backup archive and its creation time recorded.
- Isolated bridge or test VLAN with no route to production services.
- New, non-conflicting test identity for the restored VM.
- Validation checklist for the workload.
- Clear cleanup plan for the restored test instance.

## Restore procedure

1. **Select evidence.** Record the backup date, workload role, storage location, and expected recovery point without copying identifiers into public notes.
2. **Prepare isolation.** Confirm the destination network cannot reach production and cannot advertise duplicate addresses, names, or services.
3. **Create the test restore.** Restore under a new temporary identity. Do not overwrite or attach the original workload disks.
4. **Inspect before boot.** Confirm disk target, virtual network placement, boot order, resources, and absence of unintended passthrough devices.
5. **Boot in isolation.** Observe console boot and capture start/end times.
6. **Validate the operating system.** Check filesystem availability, system time, critical logs, and expected service state.
7. **Validate the application.** Perform approved read-only or test-data checks; never contact real customers or external production integrations.
8. **Measure recovery.** Record recovered data timestamp, actual RPO, elapsed RTO, warnings, and manual steps.
9. **Stop and remove the test instance.** Follow the approved cleanup process only after evidence is retained and the original workload is confirmed unaffected.
10. **Close findings.** Create remediation items for every failed or ambiguous validation step.

## Validation record

| Field | Result |
|---|---|
| Test date and owner | Pending |
| Backup creation time | Pending |
| Isolation method | Pending |
| Restore start/end | Pending |
| Measured RPO | Pending |
| Measured RTO | Pending |
| OS boot result | Pending |
| Application checks | Pending |
| Original workload unaffected | Pending |
| Overall result | Not executed |

## Pass criteria

A restore passes only when:

- the restored disk is readable and the OS boots without unresolved filesystem errors;
- required application data exists at the expected recovery point;
- approved service checks succeed in isolation;
- the original workload and network remain unaffected;
- actual RPO and RTO meet approved targets;
- evidence and lessons are recorded.

An archive count, successful backup job, snapshot, or file checksum alone is not a completed recovery test.
