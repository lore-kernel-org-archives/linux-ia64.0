From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 07 Jun 2004 16:22:25 +0000
Subject: [PATCH] time to delete McKinley A-stepping code?
Message-Id: <1086625345.4713.8.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   The patch below removes the config option and one bit of code for
McKinley A0/A1 CPU workarounds.  These CPUs were never used in
production, and IIRC this workaround really only affected X11.  If you
happen to still be running X11 on an very, very early McKinley prototype
box, speakup or your graphics are going to start looking a little
strange.  Thanks,

	Alex

=== arch/ia64/Kconfig 1.74 vs edited ==--- 1.74/arch/ia64/Kconfig	Mon May 24 17:05:32 2004
+++ edited/arch/ia64/Kconfig	Mon Jun  7 10:03:19 2004
@@ -149,20 +149,6 @@
 	default "6" if ITANIUM
 
 # align cache-sensitive data to 64 bytes
-config MCKINLEY_ASTEP_SPECIFIC
-	bool "McKinley A-step specific code"
-	depends on MCKINLEY
-	help
-	  Select this option to build a kernel for an IA-64 McKinley prototype
-	  system with any A-stepping CPU.
-
-config MCKINLEY_A0_SPECIFIC
-	bool "McKinley A0/A1-step specific code"
-	depends on MCKINLEY_ASTEP_SPECIFIC
-	help
-	  Select this option to build a kernel for an IA-64 McKinley prototype
-	  system with an A0 or A1 stepping CPU.
-
 config NUMA
 	bool "NUMA support"
 	depends on !IA64_HP_SIM
=== include/asm-ia64/pgtable.h 1.41 vs edited ==--- 1.41/include/asm-ia64/pgtable.h	Thu May 27 11:12:04 2004
+++ edited/include/asm-ia64/pgtable.h	Mon Jun  7 10:07:59 2004
@@ -297,11 +297,7 @@
  * works bypasses the caches, but does allow for consecutive writes to
  * be combined into single (but larger) write transactions.
  */
-#ifdef CONFIG_MCKINLEY_A0_SPECIFIC
-# define pgprot_writecombine(prot)	prot
-#else
-# define pgprot_writecombine(prot)	__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK) | _PAGE_MA_WC)
-#endif
+#define pgprot_writecombine(prot)	__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK) | _PAGE_MA_WC)
 
 static inline unsigned long
 pgd_index (unsigned long address)


