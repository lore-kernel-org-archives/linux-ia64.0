From: Khoa Nguyen <khoan@rsn.hp.com>
Date: Wed, 30 Aug 2000 19:45:03 +0000
Subject: [Linux-ia64] BigSur on the LAN
Message-Id: <marc-linux-ia64-105590678205419@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I've been monitoring this list for a few days now and everyone seems to
have the IA64 box on the lan. To date, we have not been able to put our
bigsur on the lan. I've tried RedHat, and Turbo linux distribution to 
no avail. If you know of any step that I might have missed, please let 
me know. We'd like to put our box on the lan for every one to play with.

Here is what I've tried so far:
	1. Installed Turbo linux (one version older than the lastest).
	   Configured network params.
	   Successfully pinged itself, but couldn't ping any other IP
	   eth0 listed as eepro100: IRQ 10, base addr 0x1000
	   Periodically got: "eth0: Transmit timed out: status f088 
	                      0c00 at 28/56 command 0001a000"

	2. Installed latest RedHat.
	   Configured network params.
	   Successfully pinged itself, but couldn't ping any other IP
	   eth0 listed as eepro100: IRQ 10, base addr 0x1000
	   Periodically got: "eth0: Transmit timed out: status f088 
	                      0c00 at 28/56 command 0001a000"

	3. Used RedHat latest as a base and rebuild the kernel with 
	   module support.
	   Compiled eepro100 as modules
	   Copied System.map and vmlinux and rename them appropriately
	   to /boot and /boot/efi respectively.
	   Tried 'modprobe eepro100' and got these errors:
	   "..../eepro100.o: unresolved symbol pci_unmap_single"
	   "..../eepro100.o: unresolved symbol pci_map_single"
	   "..../eepro100.o: unresolved symbol pci_dma_sync_single"

I thought that the built-in ethernet card is bad. So, we bought a PCI
Intel Pro/100+. After installing it, the box continually reboots.

Here is the system config:
	SDV Pre-Qual
	A-3 stepping processor
	1G RAM.

Any help is greatly appreciated.

Thanks,

Khoa.

