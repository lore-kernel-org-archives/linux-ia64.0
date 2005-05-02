From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 02 May 2005 12:49:15 +0000
Subject: [PATCH 4/6]: SN Hotplug Driver - new SN PROM version code
Message-Id: <427621CB.8080902@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000606030006050306000001"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------000606030006050306000001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------000606030006050306000001
Content-Type: text/plain;
 name="sn_version4.patch-4"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sn_version4.patch-4"

This patch is a rewrite of the code to check the PROM version.  The current
code has some deficiences in the way PROM comparisons were made.  The minimum
value of PROM that will boot has also been changed to 4.04.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

 arch/ia64/sn/kernel/setup.c  |   13 ++++++-------
 include/asm-ia64/sn/sn_sal.h |   39 ++++++++++++---------------------------
 2 files changed, 18 insertions(+), 34 deletions(-)

diff -urNp pci_search/arch/ia64/sn/kernel/setup.c sn_version/arch/ia64/sn/kernel/setup.c
--- pci_search/arch/ia64/sn/kernel/setup.c	2005-04-07 11:36:41.000000000 -0400
+++ sn_version/arch/ia64/sn/kernel/setup.c	2005-04-08 13:30:21.000000000 -0400
@@ -249,7 +249,7 @@ void __init sn_setup(char **cmdline_p)
 {
 	long status, ticks_per_sec, drift;
 	int pxm;
-	int major = sn_sal_rev_major(), minor = sn_sal_rev_minor();
+	u32 version = sn_sal_rev();
 	extern void sn_cpu_init(void);
 
 	/*
@@ -282,22 +282,21 @@ void __init sn_setup(char **cmdline_p)
 	 * support here so we don't have to listen to failed keyboard probe
 	 * messages.
 	 */
-	if ((major < 2 || (major == 2 && minor <= 9)) &&
-	    acpi_kbd_controller_present) {
+	if (version <= 0x0209 && acpi_kbd_controller_present) {
 		printk(KERN_INFO "Disabling legacy keyboard support as prom "
 		       "is too old and doesn't provide FADT\n");
 		acpi_kbd_controller_present = 0;
 	}
 
-	printk("SGI SAL version %x.%02x\n", major, minor);
+	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
 
 	/*
 	 * Confirm the SAL we're running on is recent enough...
 	 */
-	if ((major < SN_SAL_MIN_MAJOR) || (major == SN_SAL_MIN_MAJOR &&
-					   minor < SN_SAL_MIN_MINOR)) {
+	if (version <= SN_SAL_MIN_VERSION) {
 		printk(KERN_ERR "This kernel needs SGI SAL version >= "
-		       "%x.%02x\n", SN_SAL_MIN_MAJOR, SN_SAL_MIN_MINOR);
+		       "%x.%02x\n", SN_SAL_MIN_VERSION >> 8,
+		        SN_SAL_MIN_VERSION & 0x00FF);
 		panic("PROM version too old\n");
 	}
 
diff -urNp pci_search/include/asm-ia64/sn/sn_sal.h sn_version/include/asm-ia64/sn/sn_sal.h
--- pci_search/include/asm-ia64/sn/sn_sal.h	2005-04-07 11:36:40.000000000 -0400
+++ sn_version/include/asm-ia64/sn/sn_sal.h	2005-04-08 13:28:01.000000000 -0400
@@ -122,43 +122,28 @@
 #define SALRET_INVALID_ARG	(-2)
 #define SALRET_ERROR		(-3)
 
-
 /**
- * sn_sal_rev_major - get the major SGI SAL revision number
- *
- * The SGI PROM stores its version in sal_[ab]_rev_(major|minor).
- * This routine simply extracts the major value from the
- * @ia64_sal_systab structure constructed by ia64_sal_init().
- */
-static inline int
-sn_sal_rev_major(void)
+  * sn_sal_revision - get the SGI SAL revision number
+  *
+  * The SGI PROM stores its version in the sal_[ab]_rev_(major|minor).
+  * This routine simply extracts the major and minor values and 
+  * presents them in a u32 format.
+  *
+  * For example, version 4.05 would be represented at 0x0405.
+  */
+static inline u32
+sn_sal_rev(void)
 {
 	struct ia64_sal_systab *systab = efi.sal_systab;
 
-	return (int)systab->sal_b_rev_major;
-}
-
-/**
- * sn_sal_rev_minor - get the minor SGI SAL revision number
- *
- * The SGI PROM stores its version in sal_[ab]_rev_(major|minor).
- * This routine simply extracts the minor value from the
- * @ia64_sal_systab structure constructed by ia64_sal_init().
- */
-static inline int
-sn_sal_rev_minor(void)
-{
-	struct ia64_sal_systab *systab = efi.sal_systab;
-	
-	return (int)systab->sal_b_rev_minor;
+	return (u32)(systab->sal_b_rev_major << 8 | systab->sal_b_rev_minor);
 }
 
 /*
  * Specify the minimum PROM revsion required for this kernel.
  * Note that they're stored in hex format...
  */
-#define SN_SAL_MIN_MAJOR	0x4  /* SN2 kernels need at least PROM 4.0 */
-#define SN_SAL_MIN_MINOR	0x0
+#define SN_SAL_MIN_VERSION	0x0404
 
 /*
  * Returns the master console nasid, if the call fails, return an illegal

--------------000606030006050306000001--
