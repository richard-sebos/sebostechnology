
## Build VM
```bash
#!/bin/bash
## Created for Proxmox
# Variables

# Define the MAC address generator function
generate_mac_address() {
  printf '52:54:%02X:%02X:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256))
}

# Assign parameters to variables
VMID=300
MAC=$(generate_mac_address)
VM_NAME="JumpServer"

# Validate VMID (numeric and positive)
if ! [[ "$VMID" =~ ^[0-9]+$ ]]; then
  echo "Error: VMID must be a positive integer."
  exit 1
fi

# Validate MAC address (format: XX:XX:XX:XX:XX:XX)
if ! [[ "$MAC" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
  echo "Error: Invalid MAC address format. Must be in the format XX:XX:XX:XX:XX:XX."
  exit 1
fi

# Validate VM Name (non-empty and alphanumeric with optional hyphens/underscores)
if ! [[ "$VM_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: VM Name must be alphanumeric and can include hyphens or underscores."
  exit 1
fi

# Main logic to create the vpn VM
# Example VM creation command (replace with actual implementation)
# e.g., proxmox_vm_create or any other logic
echo "Creating vpn VM..."
echo "VMID: $VMID"
echo "MAC Address: $MAC"
echo "VM Name: $VM_NAME"

## Linux to Install
ISO_STORAGE="ISOs"           # Replace with your ISO storage name
ISO_FILE="OracleLinux-R9-U4-x86_64-dvd.iso"
## Hard Dive Size
DISK_STORAGE="vm_storage"    # Replace with your disk storage name
SYSTEM_DISK="30G"

## Memory Size 
MEMORY=4
MEMORY_SIZE=$(( MEMORY * 1024 ))

## Process 
CORES=2
SOCKETS=1
## Nextork
VLAN_TAG=20
INTERFACE="vmbr0"

## If existing, remove
if qm list | awk '{print $1}' | grep -q "^$VMID$"; then
    qm stop $VMID
    qm destroy $VMID
fi

## Create VM
qm create $VMID --name $VM_NAME 

## Setup Memory and CPUs
qm set $VMID --memory ${MEMORY_SIZE}
qm set $VMID --balloon ${MEMORY_SIZE}
qm set $VMID --cpu cputype=host
qm set $VMID --cores ${CORES} --sockets ${SOCKETS} --numa 1

## Install ISO and Hard Drives
qm set $VMID --cdrom $ISO_STORAGE:iso/$ISO_FILE

### OS Drive
pvesm alloc vm_storage $VMID vm-${VMID}-disk-0 ${SYSTEM_DISK}
qm set $VMID --scsihw virtio-scsi-single --scsi0 vm_storage:vm-${VMID}-disk-0,iothread=1

### Boot Order
qm set $VMID --boot order='ide2;scsi0'

## Network 
qm set $VMID --net0 virtio,bridge=${INTERFACE},tag=${VLAN_TAG},queues=4,macaddr=${MAC}

## Other setting
qm set $VMID --agent enabled=1
qm set $VMID --ostype l26
qm start $VMID
```

- started and did updates