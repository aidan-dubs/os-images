## Fedora Silverblue image

Todos:

- [ ] MoreWaita and accent colors setup
- [ ] Enable Syncthing for all users
- [ ] Set tailscale operator
- [ ] Flatpak autoinstall at boot

## Local Testing

```
sudo podman build -t localhost/my-silverblue:latest -f Containerfile .
```

```
sudo image-builder build \
  --bootc-ref localhost/my-silverblue:latest \
  --bootc-default-fs btrfs \
  --output-dir /var/lib/libvirt/images/ \
  qcow2
```

```
sudo virt-install --name sb-test --memory 12288 --vcpus 8 \
  --import --disk path=/var/lib/libvirt/images/bootc-fedora-45-qcow2-x86_64.qcow2 \
  --os-variant fedora-unknown --boot uefi --graphics spice
```

```
sudo virsh --connect qemu:///system destroy sb-test
sudo virsh --connect qemu:///system undefine sb-test --nvram
```
