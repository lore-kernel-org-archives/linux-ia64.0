From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 13 May 2005 00:45:58 +0000
Subject: [PATCH 4/6]: hotplug/ia64: SN Hotplug Driver - new SN PROM version code
Message-Id: <20050513004556.17135.91561.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42835E91.2080403@sgi.com>
In-Reply-To: <42835E91.2080403@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch is a rewrite of the code to check the PROM version.  The current
code has some deficiences in the way PROM comparisons were made.  The minimum
value of PROM that will boot has also been changed to 4.04.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit a4c6ca89d0e410957323fb88e57421aaf1ca621b
tree 94b3c225a19fb0e688da58fa7c9239db0a743e9c
parent b1fcf8446e48103abd7521df7024036d0b877735
author Prarit Bhargava <prarit@sgi.com> 1810126553 -0400
committer Prarit Bhargava <prarit@sgi.com> 1810126553 -0400

Index: arch/ia64/sn/kernel/setup.c
=================================--- 3a3b6bc7d6665ede97ab69549f9f82675bf8b9e4/arch/ia64/sn/kernel/setup.c  (mode:100644 sha1:4fb44984afe61198a5f3c4c62795a6ced91eb265)
+++ 94b3c225a19fb0e688da58fa7c9239db0a743e9c/arch/ia64/sn/kernel/setup.c  (mode:100644 sha1:6fd5512e003f8988783d95af32ea46acc195fe5e)
@@ -268,7 +268,7 @@
 {
 	long status, ticks_per_sec, drift;
 	int pxm;
-	int major = sn_sal_rev_major(), minor = sn_sal_rev_minor();
+	u32 version = sn_sal_rev();
 	extern void sn_cpu_init(void);
 
 	/*
@@ -301,22 +301,21 @@
 	 * support here so we don't have to listen to failed keyboard probe
 	 * messages.
 	 */
-	if ((major < 2 || (major = 2 && minor <= 9)) &&
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
-	if ((major < SN_SAL_MIN_MAJOR) || (major = SN_SAL_MIN_MAJOR &&
-					   minor < SN_SAL_MIN_MINOR)) {
+	if (version < SN_SAL_MIN_VERSION) {
 		printk(KERN_ERR "This kernel needs SGI SAL version >= "
-		       "%x.%02x\n", SN_SAL_MIN_MAJOR, SN_SAL_MIN_MINOR);
+		       "%x.%02x\n", SN_SAL_MIN_VERSION >> 8,
+		        SN_SAL_MIN_VERSION & 0x00FF);
 		panic("PROM version too old\n");
 	}
 
Index: arch/ia64/sn/pci/tioca_provider.c
=================================--- 3a3b6bc7d6665ede97ab69549f9f82675bf8b9e4/arch/ia64/sn/pci/tioca_provider.c  (mode:100644 sha1:8dae9eb45456d97525a6745a766f903eee2323d6)
+++ 94b3c225a19fb0e688da58fa7c9239db0a743e9c/arch/ia64/sn/pci/tioca_provider.c  (mode:100644 sha1:0452d7ba0e2a14a98df893e6bab5ebd3c7203ad6)
@@ -589,8 +589,7 @@
 
 	/* sanity check prom rev */
 
-	if (sn_sal_rev_major() < 4 ||
-	    (sn_sal_rev_major() = 4 && sn_sal_rev_minor() < 6)) {
+	if (sn_sal_rev() < 0x0406) {
 		printk
 		    (KERN_ERR "%s:  SGI prom rev 4.06 or greater required "
 		     "for tioca support\n", __FUNCTION__);
Index: include/asm-ia64/sn/sn_sal.h
=================================--- 3a3b6bc7d6665ede97ab69549f9f82675bf8b9e4/include/asm-ia64/sn/sn_sal.h  (mode:100644 sha1:56d74ca76b5d0b9f4fc809c4f05c6152655b1311)
+++ 94b3c225a19fb0e688da58fa7c9239db0a743e9c/include/asm-ia64/sn/sn_sal.h  (mode:100644 sha1:6ad6a885f9aba3fa8be23f369224a037d4080407)
@@ -125,43 +125,28 @@
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
