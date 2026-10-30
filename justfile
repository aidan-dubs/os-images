image    := "localhost/my-silverblue:latest"
vm       := "sb-test"
out_dir  := "/var/lib/libvirt/images"
qcow     := out_dir / "bootc-fedora-45-qcow2-x86_64.qcow2"
memory   := "12288"
vcpus    := "8"

# List available recipes
default:
    @just --list

# Build the container image
build:
    podman build --target base -t {{image}} -f Containerfile ./fedora-silverblue/

# Convert the container image into a qcow2 disk
disk:
    image-builder build \
      --bootc-ref {{image}} \
      --bootc-default-fs btrfs \
      --output-dir {{out_dir}}/ \
      qcow2

# Create and boot the test VM
vm:
    virt-install --name {{vm}} --memory {{memory}} --vcpus {{vcpus}} \
      --import --disk path={{qcow}} \
      --os-variant fedora-unknown --boot uefi --graphics spice

# Tear down the test VM (ignores errors if it is not running or does not exist)
destroy:
    -virsh --connect qemu:///system destroy {{vm}}
    -virsh --connect qemu:///system undefine {{vm}} --nvram

# Full build pipeline, then launch the VM
all: build disk vm

# Tear down any old VM, rebuild everything, and relaunch
rebuild: destroy build disk vm
