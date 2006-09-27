From: Keith Owens <kaos@sgi.com>
Date: Wed, 27 Sep 2006 02:45:50 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <5239.1159325150@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Tue, 26 Sep 2006 13:54:30 CST."
             <200609261354.30722.bjorn.helgaas@hp.com> 
References: <200609261354.30722.bjorn.helgaas@hp.com>
In-Reply-To: <200609261354.30722.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Bjorn Helgaas (on Tue, 26 Sep 2006 13:54:30 -0600) wrote:
>get_kbd_char() in arch/ia64/kdb/kdba_io.c does "inb(KBD_STATUS_REG)".
>
>But we don't know whether there's even an i8042 keyboard controller
>present.  On HP ia64 boxes, there is no i8042, and trying to read
>from it can cause an MCA.
>
>This depends on the specific platform and how it is configured.  I
>observed this MCA while booting the SLES10 install kernel on an
>HP rx7620 in "default" acpiconfig mode.  The supported acpiconfig
>mode on this box is "single-pci-domain", which also puts some
>legacy ports into "soft-fail" mode, where the read will just return
>0xff instead of causing an MCA.  But I think it's wrong to blindly
>poke around in I/O port space.

No support for legacy I/O ports could be a bigger problem than just
KDB.  To fix just KDB, apply this patch over kdb-v4.4-2.6.18-common-1 and add
'kdb_skip_keyboard' to the boot command line on the offending hardware.

---
 arch/ia64/kdb/kdba_io.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

Index: linux/arch/ia64/kdb/kdba_io.c
=================================--- linux.orig/arch/ia64/kdb/kdba_io.c
+++ linux/arch/ia64/kdb/kdba_io.c
@@ -38,6 +38,7 @@
 #else
 #undef	KDB_BLINK_LED
 #endif
+static int kdb_skip_keyboard;
 
 #ifdef CONFIG_KDB_USB
 struct kdb_usb_exchange kdb_usb_infos;
@@ -334,7 +335,8 @@ static int get_kbd_char(void)
 		if (kbd_exists = 0)
 			return -1;
 
-		if (inb(KBD_STATUS_REG) = 0xff && inb(KBD_DATA_REG) = 0xff) {
+		if (kdb_skip_keyboard ||
+		    (inb(KBD_STATUS_REG) = 0xff && inb(KBD_DATA_REG) = 0xff)) {
 			kbd_exists = 0;
 			return -1;
 		}
@@ -561,3 +563,14 @@ get_char_func poll_funcs[] = {
 
 void kdba_local_arch_setup(void) {}
 void kdba_local_arch_cleanup(void) {}
+
+/* Some hardware gets an MCA instead of returning 0xff when we read
+ * KBD_STATUS_REG.  If these systems boot a kernel with CONFIG_VT=y then they
+ * need to add 'kdb_skip_keyboard' to the boot line.
+ */
+static int __init kdb_skip_keyboard_setup(char * str)
+{
+	kdb_skip_keyboard = 1;
+	return 1;
+}
+__setup("kdb_skip_keyboard", kdb_skip_keyboard_setup);

