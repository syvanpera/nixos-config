NIX_HOST ?= nixos
NIX_USER ?= tuomo

# NIX_ISO ?= https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
# NIX_ISO ?= https://channels.nixos.org/nixos-22.11/latest-nixos-minimal-x86_64-linux.iso
NIX_ISO ?= /home/tuomo/Downloads/latest-nixos-minimal-x86_64-linux.iso

PROTOCOL_HTTPS ?= https://github.com/
PROTOCOL_GIT ?= git@github.com:

NIX_CONFIG_FLAKE_URI ?= github:syvanpera/nixos-config\#nixos

NIX_CONF_REPO_PROTOCOL ?= $(PROTOCOL_HTTPS)
NIX_CONF_REPO ?= syvanpera/nixos-config.git
NIX_CONF_REPO_BRANCH ?= main
NIX_CONF_DIR ?= /etc/nix-config

VM_IP ?= unset
VM_DISK_IMAGE ?= /data/libvirt/$(NIX_HOST).qcow2
# VM_DISK_SIZE ?= 50
# VM_CPUS ?= 4
# VM_MEMORY ?= 8196
VM_DISK_SIZE ?= 20
VM_CPUS ?= 2
VM_MEMORY ?= 4096
# The block device prefix to use.
#   - sda for SATA/IDE
#   - vda for virtio
#   ...
VM_BLOCK_DEVICE ?= vda

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Creates a new VM and boots to the latest NixOS minimal install ISO.
vm/create:
	virt-install --name $(NIX_HOST) \
		--memory=$(VM_MEMORY) \
		--vcpus=$(VM_CPUS) \
		--video qxl,vgamem=65536 \
		--disk path=$(VM_DISK_IMAGE),device=disk,bus=virtio,size=$(VM_DISK_SIZE) \
		--cdrom $(NIX_ISO) \
		--osinfo detect=on,require=on \
		--network network=default
		# --nographics \
		# --console=pty,target_type=virtio
		# --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,loader.readonly=yes,loader.secure='no',loader.type=pflash,nvram=/usr/share/edk2/ovmf/OVMF_VARS.fd

# Install NixOS on a brand new VM. The VM should have NixOS minimal ISO in the CD drive
# and just set the password of the root user to "root". This will install NixOS.
# After installing NixOS, you must reboot and set the root password for the next step.

nixos/install:
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
		parted /dev/$(VM_BLOCK_DEVICE) -- mklabel msdos; \
		parted /dev/$(VM_BLOCK_DEVICE) -- mkpart primary 1MB -8GB; \
		parted /dev/$(VM_BLOCK_DEVICE) -- mkpart primary linux-swap -8GB 100%; \
		mkfs.ext4 -L nixos /dev/$(VM_BLOCK_DEVICE)1; \
		mkswap -L swap /dev/$(VM_BLOCK_DEVICE)2; \
		swapon /dev/$(VM_BLOCK_DEVICE)2; \
		mount /dev/disk/by-label/nixos /mnt; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a\\\n\
  nix.package = pkgs.nixUnstable;\n\
  nix.extraOptions = \"experimental-features = nix-command flakes\";\n\
  boot.loader.grub.device = \"/dev/$(VM_BLOCK_DEVICE)\";\n\
  environment.systemPackages = [ pkgs.git ];\n\
  services.openssh.enable = true;\n\
  services.openssh.passwordAuthentication = true;\n\
  services.openssh.permitRootLogin = \"yes\";\n\
  users.users.root.initialPassword = \"root\";\n\
		' /mnt/etc/nixos/configuration.nix;\
		nixos-install; \
		reboot; \
	"

nixos/install-uefi:
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
		parted /dev/$(VM_BLOCK_DEVICE) -- mklabel gpt; \
		parted /dev/$(VM_BLOCK_DEVICE) -- mkpart primary 512MB -8GB; \
		parted /dev/$(VM_BLOCK_DEVICE) -- mkpart primary linux-swap -8GB 100%; \
		parted /dev/$(VM_BLOCK_DEVICE) -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/$(VM_BLOCK_DEVICE) -- set 3 esp on; \
		mkfs.ext4 -L nixos /dev/$(VM_BLOCK_DEVICE)1; \
		mkswap -L swap /dev/$(VM_BLOCK_DEVICE)2; \
		swapon /dev/$(VM_BLOCK_DEVICE)2; \
		mkfs.fat -F 32 -n boot /dev/$(VM_BLOCK_DEVICE)3; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		nixos-install --no-root-password; \
		reboot; \
	"

# After nixos/install, run this to finalize the base setup.
nixos/bootstrap:
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
		nixos-rebuild switch --flake $(NIX_CONFIG_FLAKE_URI); \
		reboot; \
	"






nixos/usersetup:
	$(MAKE) nixos/secrets
	NIX_CONF_DIR=/home/$(NIX_USER)/nix-config NIX_CONF_REPO_PROTOCOL=$(PROTOCOL_GIT) $(MAKE) nixos/clone
	ssh $(SSH_OPTIONS) $(NIX_USER)@$(VM_IP) " \
		cd /home/$(NIX_USER)/nix-config; \
		nix build .#homeConfigurations.$(NIX_USER).activationPackage; \
		./result/activate; \
	"
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
		reboot; \
	"

# Checkout my Nix configurations repo into the VM.
nixos/clone:
	ssh $(SSH_OPTIONS) $(NIX_USER)@$(VM_IP) " \
		git clone --branch $(NIX_CONF_REPO_BRANCH) $(NIX_CONF_REPO_PROTOCOL)$(NIX_CONF_REPO) $(NIX_CONF_DIR); \
		cp /etc/nixos/hardware-configuration.nix $(NIX_CONF_DIR)/system/$(NIX_HOST); \
	"

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run nixos/clone before.
nixos/switch:
	ssh $(SSH_OPTIONS) root@$(VM_IP) " \
		cd $(NIX_CONF_DIR) && nixos-rebuild switch --flake .#$(NIX_HOST) \
	"

# Copy secrets from the host into the VM
nixos/secrets:
	# GPG keyring
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIX_USER)@$(VM_IP):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIX_USER)@$(VM_IP):~/.ssh

# Build an ISO image
iso/nixos.iso:
	cd iso; ./build.sh
