From: Aaron Young <ayoung@google.engr.sgi.com>
Date: Wed, 28 Jun 2006 15:34:55 +0000
Subject: [PATCH] RESEND - fix prom revision checks in SN kernel
Message-Id: <200606281534.IAA17348@google.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


(Resend #1 - patch is now based off the aegl/linux-2.6.git tree)

The following patch fixes a few spots in the SN kernel
that check a fixed prom revision number to determine prom
feature support. These checks are only valid on shub1 systems.
They are invalid on shub2 systems which have a different prom
with different revision numbers.

Signed-off-by: Aaron Young <ayoung@sgi.com>

---
 arch/ia64/sn/kernel/setup.c       |    2 +-
 arch/ia64/sn/pci/tioca_provider.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 93577ab..eeb9b66 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -458,7 +458,7 @@ #endif				/* def(CONFIG_VT) && def(CONFI
 	 * support here so we don't have to listen to failed keyboard probe
 	 * messages.
 	 */
-	if (version <= 0x0209 && acpi_kbd_controller_present) {
+	if (is_shub1() && version <= 0x0209 && acpi_kbd_controller_present) {
 		printk(KERN_INFO "Disabling legacy keyboard support as prom "
 		       "is too old and doesn't provide FADT\n");
 		acpi_kbd_controller_present = 0;
diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
index 20de727..e4aa839 100644
--- a/arch/ia64/sn/pci/tioca_provider.c
+++ b/arch/ia64/sn/pci/tioca_provider.c
@@ -595,7 +595,7 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 
 	/* sanity check prom rev */
 
-	if (sn_sal_rev() < 0x0406) {
+	if (is_shub1() && sn_sal_rev() < 0x0406) {
 		printk
 		    (KERN_ERR "%s:  SGI prom rev 4.06 or greater required "
 		     "for tioca support\n", __FUNCTION__);
