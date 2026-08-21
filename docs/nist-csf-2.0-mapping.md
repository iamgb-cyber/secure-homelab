# NIST Cybersecurity Framework 2.0 mapping

## Purpose

This high-level mapping uses the six NIST CSF 2.0 Functions to organize improvement work. It is not a certification, formal profile, or claim of compliance. Category references are based on the [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework).

| Function / category | Current evidence | Status | Next measurable outcome |
|---|---|---|---|
| GOVERN — GV.OC Organizational Context | Lab purpose and public/private boundary are documented | Partial | Define service criticality, stakeholders, RPO and RTO |
| GOVERN — GV.RM Risk Management Strategy | Qualitative risk register and priorities exist | Partial | Approve risk criteria, owners and exception process |
| GOVERN — GV.RR Roles, Responsibilities and Authorities | Change and restore records require an owner | Planned | Assign backup, patching, access and incident owners |
| GOVERN — GV.PO Policy | Publication and evidence rules are documented | Partial | Approve access, backup, patch and logging policies |
| GOVERN — GV.OV Oversight | Evidence register supports periodic review | Planned | Establish monthly control review and quarterly recovery review |
| IDENTIFY — ID.AM Asset Management | Node, storage and workload inventory verified | Partial | Add accountable owner, purpose and lifecycle for each asset |
| IDENTIFY — ID.RA Risk Assessment | Recovery, segmentation, access and monitoring risks recorded | Partial | Verify firewall/SSH exposure and reassess likelihood |
| IDENTIFY — ID.IM Improvement | Gap-to-roadmap traceability exists | Partial | Update status after every tested control change |
| PROTECT — PR.AA Identity Management, Authentication and Access Control | Effective administrative authentication not inspected | Not verified | Test individual key-based access and remove unsafe paths |
| PROTECT — PR.DS Data Security | Separate local backup media exists | Partial | Add independent copy, retention protection and restore evidence |
| PROTECT — PR.PS Platform Security | Modern VM baseline is verified; patching and hardening are not | Partial | Establish patch cadence and configuration baseline |
| PROTECT — PR.IR Technology Infrastructure Resilience | Single node, no disk redundancy, stale recovery points | Gap | Meet approved RPO/RTO through tested recovery controls |
| DETECT — DE.CM Continuous Monitoring | No monitoring evidence collected | Not verified | Alert on backup, capacity, service and login events |
| DETECT — DE.AE Adverse Event Analysis | No triage workflow documented | Planned | Define severity, evidence collection and escalation workflow |
| RESPOND — RS.MA Incident Management | No tested incident workflow | Planned | Create roles, decision points and incident record template |
| RESPOND — RS.AN Incident Analysis | Logs and retention not yet verified | Not verified | Confirm authoritative log sources and analysis procedure |
| RESPOND — RS.CO Incident Response Reporting and Communication | No communication plan documented | Planned | Define internal and external notification responsibilities |
| RESPOND — RS.MI Incident Mitigation | Isolation zones are target architecture only | Planned | Prove containment through firewall and network tests |
| RECOVER — RC.RP Incident Recovery Plan Execution | Restore runbook exists but has not been executed | Partial | Complete isolated restore and record RPO/RTO |
| RECOVER — RC.CO Incident Recovery Communication | Recovery reporting template exists | Planned | Define recovery status and stakeholder update cadence |

## Profile interpretation

The environment is strongest in **IDENTIFY** because current infrastructure facts and known gaps are documented. **PROTECT**, **DETECT**, **RESPOND**, and **RECOVER** require implementation and testing. **GOVERN** is emerging through explicit ownership, evidence, and acceptance gates.

The mapping will change only when new evidence is collected; documentation alone does not mark a technical control complete.
