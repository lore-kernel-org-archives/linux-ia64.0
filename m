From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 19 Nov 2003 16:30:39 +0000
Subject: [PATCH] 2.4 make hpzx1 fake pci device safer
Message-Id: <marc-linux-ia64-106925945515887@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   The fake PCI devices created in the 2.4 zx1 machvec provide PCI-like
config space access to the chipset.  However, there are some registers
in there that have side effects that you don't just want to stumble
across.  These are all out beyond the configuration header space, so
nothing should rely on them.  This patch prevents access to the
dangerous one that you'd touch looking through /proc/bus/pci.  You can
probably still shoot yourself in the foot, but you shouldn't be able to
do it by reading through the proc files.  2.6 has removed these fake
devices, so the patch is not applicable.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

=== arch/ia64/hp/zx1/hpzx1_misc.c 1.7 vs edited ==--- 1.7/arch/ia64/hp/zx1/hpzx1_misc.c	Thu Oct 16 15:56:24 2003
+++ edited/arch/ia64/hp/zx1/hpzx1_misc.c	Wed Nov 19 09:16:57 2003
@@ -50,7 +50,14 @@
 		fake_dev->sizing = 0; \
 		return PCIBIOS_SUCCESSFUL; \
 	} \
-	*value = read##sz(fake_dev->mapped_csrs + where); \
+	switch (where & ~0x7) { \
+		case 0x48: /* initiates config cycles */ \
+		case 0x78: /* elroy suspend mode register */ \
+			*value = 0; \
+			break; \
+		default: \
+			*value = read##sz(fake_dev->mapped_csrs + where); \
+	} \
 	if (where = PCI_COMMAND) \
 		*value |= PCI_COMMAND_MEMORY; /* SBA omits this */ \
 	return PCIBIOS_SUCCESSFUL; \
@@ -68,8 +75,14 @@
 		if (value = (u##bits) ~0) \
 			fake_dev->sizing = 1; \
 		return PCIBIOS_SUCCESSFUL; \
-	} else \
-		write##sz(value, fake_dev->mapped_csrs + where); \
+	} \
+	switch (where & ~0x7) { \
+		case 0x48: /* initiates config cycles */ \
+		case 0x78: /* elroy suspend mode register */ \
+			break; \
+		default: \
+			write##sz(value, fake_dev->mapped_csrs + where); \
+	} \
 	return PCIBIOS_SUCCESSFUL; \
 }
 


