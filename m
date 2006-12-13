From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Dec 2006 18:44:27 +0000
Subject: HP rx2620 broken in 2.6.19+
Message-Id: <200612131844.kBDIiR8E013826@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

My rx2620 won't boot a current linus-git kernel (2.6.19 worked).  It
dies with a NULL dereference:

pci_hotplug: PCI Hot Plug PCI Core version: 0.5
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
Unable to handle kernel NULL pointer dereference (address 0000000000000000)
swapper[1]: Oops 4294967296 [1]
Modules linked in:

Pid: 1, CPU 1, comm:              swapper
psr : 0000101008026018 ifs : 8000000000000002 ip  : [<0000000000000000>]
Not tainted
ip is at ia64_ivt+0x5fffffff00000000/0x400

Running git bisect points to this commit (and dropping out that call to
acpiphp_glue_exit() from latest git does make the kernel boot).

-Tony

commit 0a9dee2739fd4385e83c3316e3f3bee641796638
Author: Akinobu Mita <akinobu.mita@gmail.com>
Date:   Mon Oct 30 13:08:04 2006 -0800

    acpiphp: fix missing acpiphp_glue_exit()
    
    acpiphp_glue_exit() needs to be called to unwind when no slots found.
    (It fixes data corruption when reloading acpiphp driver with no such devices)
    
    Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
    Signed-off-by: Kristen Carlson Accardi <kristen.c.accardi@intel.com>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

diff --git a/drivers/pci/hotplug/acpiphp_core.c b/drivers/pci/hotplug/acpiphp_core.c
index c57d9d5..c8b6907 100644
--- a/drivers/pci/hotplug/acpiphp_core.c
+++ b/drivers/pci/hotplug/acpiphp_core.c
@@ -303,8 +303,10 @@ static int __init init_acpi(void)
 	/* read initial number of slots */
 	if (!retval) {
 		num_slots = acpiphp_get_num_slots();
-		if (num_slots = 0)
+		if (num_slots = 0) {
+			acpiphp_glue_exit();
 			retval = -ENODEV;
+		}
 	}
 
 	return retval;
