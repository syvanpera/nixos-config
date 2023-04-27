# Tinimini's NixOS Configuration

This is very much inspired by (at least) the following configurations:

- https://github.com/vereis/nixos.git
- [Mitchell Hashimoto](https://github.com/mitchellh/nixos-config)
- [Gabriel Volpe](https://github.com/gvolpe/nix-config)
- [Henrik Lissner](https://github.com/hlissner/dotfiles)

## Setup

1. Create and start the virtual machine
   In a terminal window run:

   ```sh
   make vm/create
   ```

   This will create and start the VM.
   The default name for the VM is `nixos`, to use a different name you can
   provide the name in the `NIX_HOST` environment variable:

   ```sh
   NIX_HOST=my-awesome-box make vm/create
   ```

   Wait for the VM to start (this might take a while as it downloads the ISO
   and boots the installer). If you want to save some time, you can also give
   the path to the installer ISO using the environment variable `NIX_ISO`:

   ```sh
   NIX_ISO=/tmp/nixos-minimal.iso make vm/create
   ```

2. Change the root password
   After the VM is created and ready, you should be dropped into the VM console.
   In the VM, switch to root user: `sudo su` and change the password: `passwd`
   (the new password must be _root_)

3. Install NixOS

   ```sh
   VM_IP=xxx.xxx.xxx.xxx make nixos/install
   ```

   You can find out the IP address of the VM either by running `ip a` in the VM
   or from your hosts terminal by running:

   ```sh
   virsh net-dhcp-leases default | grep nixos | awk '{ print $5 }' | sed 's/\/.\*//'
   ```

   Depending on whether you're using a local ISO image or downloading it from the internet, this will take a few minutes.
   After it's done it will end up in an error:
   `make: *** [Makefile:39: nixos/install] Error 255`
   but you can safely ignore this, it's just because the VM is rebooting.

4. Take a snapshot of the VM (optional)
   At this point you can take a snapshot of the VM if you want, just so you
   have a good base to return to in case you mess something up.
   See: [snapshot management](#snapshot-management)

5. Bootstrap the nix configuration

   ```sh
   VM_IP=xxx.xxx.xxx.xxx make nixos/bootstrap
   ```

   This will rebuild the system using the flake set in `NIX_CONFIG_FLAKE_URI`.

6. Change your user's password
   Login as the normal user (password is `password`) and change the password to
   whatever you want.

   You might also want to change the root password and disable ssh for root.

---

7. Finalize the user setup

   ```sh
   VM_IP=xxx.xxx.xxx.xxx make nixos/usersetup
   ```

   This will install Home Manager and apply user configurations.

8. Enjoy!
   After making any changes to the `home-manager` configs, (in the nix-config repo folder) run:

   ```sh
   home-manager switch --flake .#tuomo
   ```

   And after any system wide changes, (in the nix-config repo folder) run:

   ```sh
   sudo nixos-rebuild switch --flake .#
   ```

## Snapshot management

- Create snapshot

  ```sh
  virsh shutdown --domain nixos
  virsh snapshot-create-as --domain nixos --name "pre-bootstrap"
  virsh start nixos
  ```

  replace `nixos` with the name of your VM if you changed it.

- Reverting back to the snapshot

  ```sh
  virsh shutdown --domain nixos
  virsh snapshot-revert --domain nixos --snapshotname "pre-bootstrap" --running
  ```

- Listing snapshots

  ```sh
  virsh snapshot-list nixos
  ```

- Deleting a snapshot
  ```sh
  virsh snapshot-delete --domain nixos --snapshotname "pre-bootstrap"
  ```

## Other stuff

### Configure a static IP to the VM

1. Find out the MAC address of the VM:

   ```sh
   virsh dumpxml nixos |grep -i '<mac'
   ```

2. Edit the default network:

   ```sh
   virsh net-edit default
   ```

3. Find the following section:

   ```xml
   <dhcp>
     <range start='xxx.xxx.xxx.xxx' end='xxx.xxx.xxx.xxx' />
   ```

   And append the static IP after the range:

   ```xml
   <dhcp>
     <range start='xxx.xxx.xxx.xxx' end='xxx.xxx.xxx.xxx' />
     <host mac='XX:XX:XX:XX:XX:XX' name='nixos' ip='xxx.xxx.xxx.xxx' />
   ```

4. Restart the DHCP service:
   ```sh
   virsh net-destroy default
   virsh net-start default
   ```

### Connecting to a running VM

```sh
virsh --connect qemu:///system console nixos
```

### Deleting everything and starting over

1. Stop the VM with `virsh destroy nixos`
2. Remove the domain with `virsh undefine nixos --nvram` (deletes the VM)
3. Remove the disk image
