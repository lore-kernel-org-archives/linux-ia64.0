From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 14 Apr 2003 22:36:20 +0000
Subject: [Linux-ia64] [PATCH] 2.5.67 GENERIC kernel fixes
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------6BD0F424CE03F42A318C9EBD"
Message-Id: <marc-linux-ia64-105590723705500@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------6BD0F424CE03F42A318C9EBD
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   This fixes a couple problems with the generic target in the latest
2.5.67 kernel.  First is simply a fix for the addition of readX in
the machvec.  The second gets things to link in roughly the same order
when using a generic vs zx1 flavor.  With the current code, sba_init()
is called in the right place when using a zx1 flavor kernel, but
happens way too early on a generic kernel.  Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------6BD0F424CE03F42A318C9EBD
Content-Type: text/plain; charset=us-ascii;
 name="machvec_fix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="machvec_fix.diff"

--- linux-2.5.67.clean/include/asm-ia64/machvec_init.h	Mon Apr 14 14:13:06 2003
+++ linux-2.5.67/include/asm-ia64/machvec_init.h	Mon Apr 14 15:20:59 2003
@@ -16,6 +16,10 @@
 extern ia64_mv_outb_t __ia64_outb;
 extern ia64_mv_outw_t __ia64_outw;
 extern ia64_mv_outl_t __ia64_outl;
+extern ia64_mv_readb_t __ia64_readb;
+extern ia64_mv_readw_t __ia64_readw;
+extern ia64_mv_readl_t __ia64_readl;
+extern ia64_mv_readq_t __ia64_readq;
 
 #define MACHVEC_HELPER(name)									\
  struct ia64_machine_vector machvec_##name __attribute__ ((unused, __section__ (".machvec")))	\

--------------6BD0F424CE03F42A318C9EBD
Content-Type: text/plain; charset=us-ascii;
 name="link_order.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="link_order.diff"

--- linux-2.5.67.clean/arch/ia64/Makefile	Mon Apr 14 14:13:06 2003
+++ linux-2.5.67/arch/ia64/Makefile	Mon Apr 14 16:06:07 2003
@@ -48,14 +48,14 @@
 core-y				+= arch/ia64/kernel/ arch/ia64/mm/
 core-$(CONFIG_IA32_SUPPORT)	+= arch/ia64/ia32/
 core-$(CONFIG_IA64_DIG) 	+= arch/ia64/dig/
-core-$(CONFIG_IA64_GENERIC) 	+= arch/ia64/dig/ arch/ia64/hp/common/ arch/ia64/hp/zx1/ \
-				   arch/ia64/hp/sim/
+core-$(CONFIG_IA64_GENERIC) 	+= arch/ia64/dig/ 
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN)	+= arch/ia64/sn/
 
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
+drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
 
 boot := arch/ia64/boot
 tools := arch/ia64/tools

--------------6BD0F424CE03F42A318C9EBD--


