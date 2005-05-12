From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 12 May 2005 13:45:37 +0000
Subject: [PATCH 0/6]: hotplug/ia64: SN Hotplug Driver: Overview
Message-Id: <42835E01.5020701@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patchset adds the SN Hotplug Driver to Linux.  The patches are git
patches against 2.6.12-rc4.

The patches are

[PATCH 1/6]: hotplug/ia64: SN Hotplug Driver: SN IRQ fixes
[PATCH 2/6]: hotplug/ia64: SN Hotplug Driver: moving of header files
[PATCH 3/6]: hotplug/ia64: SN Hotplug Driver: pci_find_next_bus export
[PATCH 4/6]: hotplug/ia64: SN Hotplug Driver: new SN PROM version code
[PATCH 5/6]: hotplug/ia64: SN Hotplug Driver: SN Hotplug Driver code
[PATCH 6/6]: hotplug/ia64: SN Hotplug Driver: PREEMPT/pcibus_info fix

The patches are incremental, however, the kernel will still compile
after applying each patch.

The first patch fixes the SN IRQ code such that cpu affinity and
Hotplug can modify IRQ values.  The sn_irq_info structures are now locked
using a RCU lock mechanism to avoid lock contention in the lost interrupt
WAR code.

The second patch above moves header files out of the arch/ia64/sn
directories and into include/asm-ia64/sn.  These files were being included by
other subsystems and should be under include/asm-ia64/sn.

The third patch exports the pci_find_next_bus function to the
rest of the kernel.

The fourth patch above is a modification to the method in which the SN PROM
information is examined in the kernel.

The fifth patch is the SN Hotplug Driver and some additional required
modifications.  These modifications include changes to the SN io_init.c code
for memory management, the inclusion of new SAL calls to enable and disable
PCI slots, and a hotplug-style driver.

The final patch fixes an issue with the PROM and a kernel running with
CONFIG_PREEMPT enabled.  When CONFIG_PREEMPT is enabled, the size of a
spinlock_t changes -- resulting in the PROM writing to an incorrect location.



