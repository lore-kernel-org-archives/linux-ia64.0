From: Matthew Wilcox <willy@debian.org>
Date: Thu, 29 Jan 2004 18:18:07 +0000
Subject: [PATCH] Extended PCI config space
Message-Id: <20040129181807.GF18725@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


SAL 3.2 defines a mechanism for accessing extended PCI configuration
space (registers 256 to 4095).  Those with bigger boxes may be interested
to know that it also allows up to 65536 independent PCI domains.

This patch would be one way to take advantage of the new SAL call.
It tries to use the old format SAL calls if it can, and if not it will
use the new format.  I can imagine people might prefer to examine the
EFI SAL version and have a boot-time switch from one to the other.
I've only compile-tested it since I think it's plausible people might
disagree with me on this.  Plus, I don't have a SAL 3.2 box just yet.

diff -urpNX build-tools/dontdiff linus-2.6/arch/ia64/pci/pci.c pciexp-2.6/arch/ia64/pci/pci.c
--- linus-2.6/arch/ia64/pci/pci.c	2004-01-27 21:05:17.000000000 -0500
+++ pciexp-2.6/arch/ia64/pci/pci.c	2004-01-29 12:37:27.000000000 -0500
@@ -53,10 +53,13 @@ struct pci_fixup pcibios_fixups[1];
  * synchronization mechanism here.
  */
 
-#define PCI_SAL_ADDRESS(seg, bus, devfn, reg) \
+#define PCI_SAL_ADDRESS_0(seg, bus, devfn, reg) \
 	((u64)(seg << 24) | (u64)(bus << 16) | \
 	 (u64)(devfn << 8) | (u64)(reg))
 
+#define PCI_SAL_ADDRESS_1(seg, bus, devfn, reg) \
+	((u64)(seg << 28) | (u64)(bus << 20) | \
+	 (u64)(devfn << 12) | (u64)(reg))
 
 static int
 pci_sal_read (int seg, int bus, int devfn, int reg, int len, u32 *value)
@@ -64,10 +67,14 @@ pci_sal_read (int seg, int bus, int devf
 	int result = 0;
 	u64 data = 0;
 
-	if (!value || (seg > 255) || (bus > 255) || (devfn > 255) || (reg > 255))
+	if (!value || (seg > 65535) || (bus > 255) || (devfn > 255) || (reg > 4095))
 		return -EINVAL;
 
-	result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS(seg, bus, devfn, reg), len, &data);
+	if ((seg < 256) && (reg < 256)) {
+		result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS_0(seg, bus, devfn, reg), len, &data, 0);
+	} else {
+		result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS_1(seg, bus, devfn, reg), len, &data, 1);
+	}
 
 	*value = (u32) data;
 
@@ -77,13 +84,17 @@ pci_sal_read (int seg, int bus, int devf
 static int
 pci_sal_write (int seg, int bus, int devfn, int reg, int len, u32 value)
 {
-	if ((seg > 255) || (bus > 255) || (devfn > 255) || (reg > 255))
+	if ((seg > 65535) || (bus > 255) || (devfn > 255) || (reg > 4095))
 		return -EINVAL;
 
-	return ia64_sal_pci_config_write(PCI_SAL_ADDRESS(seg, bus, devfn, reg), len, value);
+	if ((seg < 256) && (reg < 256)) {
+		return ia64_sal_pci_config_write(PCI_SAL_ADDRESS_0(seg, bus, devfn, reg), len, value, 0);
+	} else {
+		return ia64_sal_pci_config_write(PCI_SAL_ADDRESS_1(seg, bus, devfn, reg), len, value, 1);
+	}
 }
 
-struct pci_raw_ops pci_sal_ops = {
+static struct pci_raw_ops pci_sal_ops = {
 	.read = 	pci_sal_read,
 	.write =	pci_sal_write
 };
diff -urpNX build-tools/dontdiff linus-2.6/include/asm-ia64/sal.h pciexp-2.6/include/asm-ia64/sal.h
--- linus-2.6/include/asm-ia64/sal.h	2004-01-07 18:02:59.000000000 -0500
+++ pciexp-2.6/include/asm-ia64/sal.h	2004-01-29 12:24:48.000000000 -0500
@@ -741,10 +741,10 @@ ia64_sal_mc_set_params (u64 param_type, 
 
 /* Read from PCI configuration space */
 static inline s64
-ia64_sal_pci_config_read (u64 pci_config_addr, u64 size, u64 *value)
+ia64_sal_pci_config_read (u64 pci_config_addr, u64 size, u64 *value, int type)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size, 0, 0, 0, 0, 0);
+	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size, type, 0, 0, 0, 0);
 	if (value)
 		*value = isrv.v0;
 	return isrv.status;
@@ -752,11 +752,11 @@ ia64_sal_pci_config_read (u64 pci_config
 
 /* Write to PCI configuration space */
 static inline s64
-ia64_sal_pci_config_write (u64 pci_config_addr, u64 size, u64 value)
+ia64_sal_pci_config_write (u64 pci_config_addr, u64 size, u64 value, int type)
 {
 	struct ia64_sal_retval isrv;
 	SAL_CALL(isrv, SAL_PCI_CONFIG_WRITE, pci_config_addr, size, value,
-	         0, 0, 0, 0);
+	         type, 0, 0, 0);
 	return isrv.status;
 }
 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
