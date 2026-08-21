#!/usr/bin/env bash

# Secure Homelab — Proxmox inventory collector
#
# Purpose:
#   Create a sanitized, read-only inventory report for portfolio verification.
#
# Safety properties:
#   - Does not install packages, restart services, or edit system configuration.
#   - Does not read environment files, private keys, tokens, or passwords.
#   - Does not print hostnames, IP addresses, MAC addresses, disk serials,
#     VM IDs, VM names, container IDs, container names, or storage names.
#   - Creates exactly one local Markdown report with permissions 0600.
#
# Usage:
#   bash collect-proxmox-inventory.sh
#   bash collect-proxmox-inventory.sh --output /tmp/proxmox-inventory.md

set -uo pipefail
umask 077

SCRIPT_VERSION="0.1.0"
DEFAULT_REPORT="${TMPDIR:-/tmp}/secure-homelab-proxmox-inventory-$(date +%Y%m%d-%H%M%S).md"
REPORT_PATH="$DEFAULT_REPORT"

usage() {
  printf '%s\n' \
    "Usage: bash collect-proxmox-inventory.sh [--output PATH]" \
    "" \
    "Creates one sanitized Markdown inventory report." \
    "No system settings are changed."
}

while (($# > 0)); do
  case "$1" in
    --output)
      if (($# < 2)); then
        printf 'Error: --output requires a path.\n' >&2
        exit 2
      fi
      REPORT_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Error: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

REPORT_DIR="$(dirname -- "$REPORT_PATH")"
if [[ ! -d "$REPORT_DIR" ]]; then
  printf 'Error: output directory does not exist: %s\n' "$REPORT_DIR" >&2
  exit 2
fi

if [[ -e "$REPORT_PATH" ]]; then
  printf 'Error: refusing to overwrite existing file: %s\n' "$REPORT_PATH" >&2
  exit 2
fi

if ! (set -o noclobber; : > "$REPORT_PATH") 2>/dev/null; then
  printf 'Error: could not create report: %s\n' "$REPORT_PATH" >&2
  exit 1
fi
chmod 0600 "$REPORT_PATH"

sanitize_stream() {
  sed -E \
    -e 's/([0-9]{1,3}\.){3}[0-9]{1,3}/[REDACTED_IPV4]/g' \
    -e 's/([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}/[REDACTED_MAC]/g' \
    -e 's/[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}/[REDACTED_EMAIL]/g'
}

append_line() {
  printf '%s\n' "$1" >> "$REPORT_PATH"
}

append_section() {
  append_line ""
  append_line "## $1"
  append_line ""
}

append_code() {
  local output="$1"
  append_line '```text'
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output" | sanitize_stream >> "$REPORT_PATH"
  else
    append_line "No data returned."
  fi
  append_line '```'
}

capture_command() {
  local label="$1"
  shift
  local output
  append_line "### $label"
  append_line ""
  if output=$("$@" 2>/dev/null); then
    append_code "$output"
  else
    append_code "Unavailable, unsupported, or permission denied."
  fi
  append_line ""
}

command_available() {
  command -v "$1" >/dev/null 2>&1
}

append_line "# Sanitized Proxmox Inventory"
append_line ""
append_line "- Collector version: $SCRIPT_VERSION"
append_line "- Generated: $(date --iso-8601=seconds 2>/dev/null || date)"
append_line "- Privilege context: $([[ $(id -u) -eq 0 ]] && printf 'root' || printf 'non-root; some checks may be incomplete')"
append_line "- Privacy: hostnames, addresses, identifiers, serials and object names are intentionally excluded."
append_line "- Mutation policy: this collector only reads system state and creates this report file."

append_section "Platform"

if command_available pveversion; then
  capture_command "Proxmox release" pveversion
else
  append_line "Proxmox command not detected. This system may not be a Proxmox VE host."
  append_line ""
fi

capture_command "Kernel" uname -r

if [[ -r /etc/os-release ]]; then
  os_summary=$(awk -F= '
    $1 == "PRETTY_NAME" {
      value=$2
      gsub(/^\"|\"$/, "", value)
      print value
    }
  ' /etc/os-release)
  append_line "### Operating system"
  append_line ""
  append_code "$os_summary"
  append_line ""
fi

if command_available lscpu; then
  cpu_summary=$(lscpu 2>/dev/null | awk -F: '
    /^(Model name|Socket\(s\)|Core\(s\) per socket|Thread\(s\) per core|CPU\(s\)):/ {
      key=$1
      value=$2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      print key ": " value
    }
  ')
  append_line "### CPU summary"
  append_line ""
  append_code "$cpu_summary"
  append_line ""
fi

if command_available free; then
  capture_command "Memory summary" free -h
fi

if command_available timedatectl; then
  capture_command "Time synchronization" timedatectl show --property=Timezone --property=NTPSynchronized
fi

append_section "Physical storage"

if command_available lsblk; then
  disk_summary=$(lsblk -b -dn -o TYPE,SIZE,ROTA,TRAN 2>/dev/null | awk '
    $1 == "disk" {
      count++
      transport=$4
      if (transport == "") transport="unknown"
      medium=($3 == 0 ? "solid-state-or-virtual" : "rotational")
      printf "disk-%02d size_bytes=%s medium=%s transport=%s\n", count, $2, medium, transport
    }
    END {
      if (count == 0) print "No physical disks reported by lsblk."
    }
  ')
  append_line "### Disk summary without device names or serials"
  append_line ""
  append_code "$disk_summary"
  append_line ""
fi

if command_available zpool; then
  zfs_summary=$(zpool list -H -o size,alloc,free,cap,health 2>/dev/null | awk '
    {
      count++
      printf "zpool-%02d size=%s allocated=%s free=%s capacity=%s health=%s\n", count, $1, $2, $3, $4, $5
    }
    END {
      if (count == 0) print "No ZFS pools detected."
    }
  ')
  append_line "### ZFS pool summary without pool names"
  append_line ""
  append_code "$zfs_summary"
  append_line ""
else
  append_line "### ZFS pool summary"
  append_line ""
  append_code "zpool command not installed or unavailable."
  append_line ""
fi

if [[ -r /proc/mdstat ]]; then
  md_count=$(awk '/^md[0-9]+[[:space:]]*:/ {count++} END {print count+0}' /proc/mdstat)
  append_line "### Linux software RAID"
  append_line ""
  append_code "Detected md arrays: $md_count"
  append_line ""
fi

append_section "Proxmox storage configuration"

if command_available pvesm; then
  pvesm_summary=$(pvesm status 2>/dev/null | awk '
    NR > 1 {
      total++
      type[$2]++
      state[$3]++
      total_bytes += $4
      used_bytes += $5
      available_bytes += $6
    }
    END {
      print "storage_definitions=" total+0
      for (key in type) print "type=" key " count=" type[key]
      for (key in state) print "status=" key " count=" state[key]
      print "aggregate_total=" total_bytes
      print "aggregate_used=" used_bytes
      print "aggregate_available=" available_bytes
    }
  ')
  append_line "### Storage definitions without storage names or paths"
  append_line ""
  append_code "$pvesm_summary"
  append_line ""
else
  append_code "pvesm command not installed or unavailable."
  append_line ""
fi

append_section "Virtual workloads"

if command_available qm; then
  vm_summary=$(qm list 2>/dev/null | awk '
    NR > 1 {
      total++
      status[$3]++
      memory_mb += $4
      disk_gb += $5
    }
    END {
      print "virtual_machines=" total+0
      for (key in status) print "status=" key " count=" status[key]
      print "configured_memory_mb=" memory_mb+0
      print "configured_boot_disk_gb=" disk_gb+0
    }
  ')
  append_line "### QEMU/KVM summary without VM IDs or names"
  append_line ""
  append_code "$vm_summary"
  append_line ""
else
  append_code "qm command not installed or unavailable."
  append_line ""
fi

if command_available pct; then
  container_summary=$(pct list 2>/dev/null | awk '
    NR > 1 {
      total++
      status[$2]++
    }
    END {
      print "lxc_containers=" total+0
      for (key in status) print "status=" key " count=" status[key]
    }
  ')
  append_line "### LXC summary without container IDs or names"
  append_line ""
  append_code "$container_summary"
  append_line ""
else
  append_code "pct command not installed or unavailable."
  append_line ""
fi

append_section "Network structure"

interface_summary=""
interface_index=0
for interface_path in /sys/class/net/*; do
  [[ -e "$interface_path" ]] || continue
  interface_name="$(basename -- "$interface_path")"
  [[ "$interface_name" == "lo" ]] && continue
  interface_index=$((interface_index + 1))
  state="unknown"
  [[ -r "$interface_path/operstate" ]] && state="$(<"$interface_path/operstate")"
  if [[ -d "$interface_path/bridge" ]]; then
    role="bridge"
  elif [[ -e "$interface_path/device" ]]; then
    role="physical-or-passthrough"
  else
    role="virtual"
  fi
  interface_summary+=$(printf 'interface-%02d role=%s state=%s' "$interface_index" "$role" "$state")
  interface_summary+=$'\n'
done
if [[ -z "$interface_summary" ]]; then
  interface_summary="No non-loopback interfaces detected."
fi
append_line "### Interface summary without names, addresses or MACs"
append_line ""
append_code "$interface_summary"
append_line ""

if [[ -r /etc/network/interfaces ]]; then
  network_config_summary=$(awk '
    /^[[:space:]]*iface[[:space:]]+/ {iface++}
    /^[[:space:]]*auto[[:space:]]+/ {auto++}
    /^[[:space:]]*bridge-ports[[:space:]]+/ {bridge_ports++}
    /^[[:space:]]*bridge-vlan-aware[[:space:]]+yes/ {vlan_aware++}
    /^[[:space:]]*vlan-raw-device[[:space:]]+/ {vlan_devices++}
    END {
      print "iface_stanzas=" iface+0
      print "auto_stanzas=" auto+0
      print "bridge_port_definitions=" bridge_ports+0
      print "vlan_aware_bridges=" vlan_aware+0
      print "explicit_vlan_devices=" vlan_devices+0
    }
  ' /etc/network/interfaces)
  append_line "### Network configuration counts"
  append_line ""
  append_code "$network_config_summary"
  append_line ""
fi

if command_available ss; then
  listener_summary=$(ss -H -lnt 2>/dev/null | awk '
    {
      address=$4
      if (address ~ /:22$/) ssh=1
      if (address ~ /:80$/) http=1
      if (address ~ /:443$/) https=1
      if (address ~ /:8006$/) pveui=1
      total++
    }
    END {
      print "tcp_listeners_total=" total+0
      print "ssh_port_22_listening=" (ssh ? "yes" : "no")
      print "http_port_80_listening=" (http ? "yes" : "no")
      print "https_port_443_listening=" (https ? "yes" : "no")
      print "proxmox_ui_port_8006_listening=" (pveui ? "yes" : "no")
    }
  ')
  append_line "### Selected listening services without bind addresses"
  append_line ""
  append_code "$listener_summary"
  append_line ""
fi

append_section "SSH security baseline"

if command_available sshd; then
  ssh_summary=$(sshd -T -C user=root,host=localhost,addr=127.0.0.1 2>/dev/null | awk '
    $1 == "permitrootlogin" ||
    $1 == "passwordauthentication" ||
    $1 == "pubkeyauthentication" ||
    $1 == "kbdinteractiveauthentication" ||
    $1 == "permitemptypasswords" ||
    $1 == "maxauthtries" {
      print $1 " " $2
    }
  ')
  append_line "### Effective SSH settings"
  append_line ""
  append_code "$ssh_summary"
  append_line ""
else
  append_code "sshd command not installed or unavailable."
  append_line ""
fi

append_section "Firewall evidence"

if command_available pve-firewall; then
  capture_command "Proxmox firewall service status" pve-firewall status
else
  append_code "pve-firewall command not installed or unavailable."
  append_line ""
fi

cluster_rules=0
node_rule_files=0
guest_rule_files=0
if [[ -r /etc/pve/firewall/cluster.fw ]]; then
  cluster_rules=$(grep -Ev '^[[:space:]]*(#|$|\[)' /etc/pve/firewall/cluster.fw 2>/dev/null | wc -l)
fi
for rule_file in /etc/pve/nodes/*/host.fw; do
  [[ -s "$rule_file" ]] && node_rule_files=$((node_rule_files + 1))
done
for rule_file in /etc/pve/firewall/*.fw; do
  [[ -s "$rule_file" ]] && guest_rule_files=$((guest_rule_files + 1))
done
firewall_summary=$(printf '%s\n' \
  "cluster_noncomment_rule_lines=$cluster_rules" \
  "node_firewall_files=$node_rule_files" \
  "guest_firewall_files=$guest_rule_files")
append_line "### Firewall configuration presence without rule contents"
append_line ""
append_code "$firewall_summary"
append_line ""

append_section "Core service health"

if command_available systemctl; then
  services=(pveproxy pvedaemon pvestatd ssh chrony systemd-timesyncd)
  service_summary=""
  systemd_state=$(systemctl is-system-running 2>/dev/null | head -n 1 || true)
  case "$systemd_state" in
    running|degraded|starting|maintenance)
      service_summary+="systemd_state=$systemd_state"$'\n'
      for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" >/dev/null 2>&1; then
          state="active"
        elif systemctl is-failed --quiet "$service" >/dev/null 2>&1; then
          state="failed"
        else
          state="inactive-or-unavailable"
        fi
        service_summary+="$service=$state"$'\n'
      done
      ;;
    *)
      service_summary="systemd_state=unavailable-in-current-runtime"$'\n'
      ;;
  esac
  append_code "$service_summary"
  append_line ""
fi

append_section "Backup job evidence"

if command_available pvesh && command_available python3; then
  backup_json=$(pvesh get /cluster/backup --output-format json 2>/dev/null || true)
  if [[ -n "$backup_json" ]]; then
    backup_summary=$(BACKUP_JSON="$backup_json" python3 - <<'PY'
import json
import os

try:
    jobs = json.loads(os.environ.get("BACKUP_JSON", "[]"))
except json.JSONDecodeError:
    print("Backup job data could not be parsed.")
else:
    if not isinstance(jobs, list):
        jobs = []
    enabled = sum(1 for job in jobs if not bool(job.get("disable", 0)))
    disabled = len(jobs) - enabled
    print(f"backup_jobs={len(jobs)}")
    print(f"enabled_jobs={enabled}")
    print(f"disabled_jobs={disabled}")
PY
    )
    append_code "$backup_summary"
  else
    append_code "No backup job data returned."
  fi
else
  append_code "pvesh or python3 unavailable; backup jobs were not inspected."
fi
append_line ""

append_section "Collector assessment"

append_line "- This report is an inventory snapshot, not a security certification."
append_line "- A configured backup job is not considered validated until a restore test succeeds."
append_line "- Firewall files or flags are not considered effective controls until policies and reachability are tested."
append_line "- VLAN counts do not prove isolation; traffic and policy tests are required."
append_line "- Review this report before sharing it outside the private project workspace."

if grep -Eq '([0-9]{1,3}\.){3}[0-9]{1,3}|([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}|[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}' "$REPORT_PATH"; then
  append_line "- Privacy self-check: WARNING — a sensitive-looking pattern remains and requires manual review."
else
  append_line "- Privacy self-check: passed for IPv4, MAC-address and email patterns."
fi

printf 'Sanitized report created: %s\n' "$REPORT_PATH"
