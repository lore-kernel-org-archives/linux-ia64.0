From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 02 May 2005 12:46:23 +0000
Subject: [PATCH 0/6]: SN Hotplug Driver: Overview
Message-Id: <4276211F.6050409@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050809040102070207080001"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050809040102070207080001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------050809040102070207080001
Content-Type: text/plain;
 name="overview-0"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="overview-0"

This patchset adds the SN Hotplug Driver to Linux.  The patches are
based on 2.6.12-rc1 (I haven't tried git yet ...) .

The patches are

[PATCH 1/6]: SN Hotplug Driver: SN IRQ fixes
[PATCH 2/6]: SN Hotplug Driver: moving of header files
[PATCH 3/6]: SN Hotplug Driver: pci_find_next_bus export
[PATCH 4/6]: SN Hotplug Driver: new SN PROM version code
[PATCH 5/6]: SN Hotplug Driver: SN Hotplug Driver code
[PATCH 6/6]: SN Hotplug Driver: PREEMPT/pcibus_info fix

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

--------------050809040102070207080001--
