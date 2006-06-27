From: Aaron Young <ayoung@google.engr.sgi.com>
Date: Tue, 27 Jun 2006 19:46:36 +0000
Subject: [PATCH] fix prom revision checks in SN kernel
Message-Id: <200606271946.MAA19328@google.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



The following patch fixes a few spots in the SN kernel
that check a fixed prom revision number to determine prom
feature support. These checks are only valid on shub1 systems.
They are invalid on shub2 systems which have a different prom
with different revision numbers.

Signed-off-by: Aaron Young <ayoung@sgi.com>


Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2006-04-11 00:33:26.000000000 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2006-06-26 14:33:33.674551229 -0500
@@ -458,7 +458,7 @@
 	 * support here so we don't have to listen to failed keyboard probe
 	 * messages.
 	 */
-	if (version <= 0x0209 && acpi_kbd_controller_present) {
+	if (is_shub1() && version <= 0x0209 && acpi_kbd_controller_present) {
 		printk(KERN_INFO "Disabling legacy keyboard support as prom "
 		       "is too old and doesn't provide FADT\n");
 		acpi_kbd_controller_present = 0;
Index: linux/arch/ia64/sn/pci/tioca_provider.c
=================================--- linux.orig/arch/ia64/sn/pci/tioca_provider.c	2006-04-11 00:33:26.000000000 -0500
+++ linux/arch/ia64/sn/pci/tioca_provider.c	2006-06-26 14:52:26.166211993 -0500
@@ -589,7 +589,7 @@
 
 	/* sanity check prom rev */
 
-	if (sn_sal_rev() < 0x0406) {
+	if (is_shub1() && sn_sal_rev() < 0x0406) {
 		printk
 		    (KERN_ERR "%s:  SGI prom rev 4.06 or greater required "
 		     "for tioca support\n", __FUNCTION__);
Index: linux/drivers/pci/hotplug/sgi_hotplug.c
=================================--- linux.orig/drivers/pci/hotplug/sgi_hotplug.c	2006-04-11 00:33:26.000000000 -0500
+++ linux/drivers/pci/hotplug/sgi_hotplug.c	2006-06-26 14:53:15.693480748 -0500
@@ -553,7 +553,7 @@
 	int rc;
 	int registered = 0;
 
-	if (sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {
+	if (is_shub1() && sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {
 		printk(KERN_ERR "%s: PROM version must be greater than 4.30\n",
 		       __FUNCTION__);
 		return -EPERM;
