From: Matthew Wilcox <willy@debian.org>
Date: Mon, 01 Mar 2004 16:20:47 +0000
Subject: [PATCH] Add support for extended PCI config space
Message-Id: <20040301162047.GZ25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Support for extended config space on ia64.

 - Add the new parameter 'type' to ia64_sal_pci_config_{read,write}
 - Change callers to match.
 - Don't check `value' for NULL -- drivers/pci/access.c guarantees it isn't.
 - Make pci_sal_ops static.
 - Add pci_sal_ext_ops.
 - Introduce pci_set_sal_ops() as an arch_initcall to ensure the raw_pci_ops
   get set before we walk the ACPI namespace to discover PCI root bridges

Index: arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/pci/pci.c,v
retrieving revision 1.6
diff -u -p -r1.6 pci.c
--- a/arch/ia64/pci/pci.c	28 Feb 2004 01:49:51 -0000	1.6
+++ b/arch/ia64/pci/pci.c	1 Mar 2004 16:06:22 -0000
@@ -57,17 +57,16 @@ struct pci_fixup pcibios_fixups[1];
 	((u64)(seg << 24) | (u64)(bus << 16) | \
 	 (u64)(devfn << 8) | (u64)(reg))
 
-
 static int
 pci_sal_read (int seg, int bus, int devfn, int reg, int len, u32 *value)
 {
 	int result = 0;
 	u64 data = 0;
 
-	if (!value || (seg > 255) || (bus > 255) || (devfn > 255) || (reg > 255))
+	if ((seg > 255) || (bus > 255) || (devfn > 255) || (reg > 255))
 		return -EINVAL;
 
-	result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS(seg, bus, devfn, reg), len, &data);
+	result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS(seg, bus, devfn, reg), 0, len, &data);
 
 	*value = (u32) data;
 
@@ -80,15 +79,61 @@ pci_sal_write (int seg, int bus, int dev
 	if ((seg > 255) || (bus > 255) || (devfn > 255) || (reg > 255))
 		return -EINVAL;
 
-	return ia64_sal_pci_config_write(PCI_SAL_ADDRESS(seg, bus, devfn, reg), len, value);
+	return ia64_sal_pci_config_write(PCI_SAL_ADDRESS(seg, bus, devfn, reg), 0, len, value);
 }
 
-struct pci_raw_ops pci_sal_ops = {
+static struct pci_raw_ops pci_sal_ops = {
 	.read = 	pci_sal_read,
 	.write =	pci_sal_write
 };
 
-struct pci_raw_ops *raw_pci_ops = &pci_sal_ops;	/* default to SAL */
+/* SAL 3.2 adds support for extended config space. */
+
+#define PCI_SAL_EXT_ADDRESS(seg, bus, devfn, reg) \
+	((u64)(seg << 28) | (u64)(bus << 20) | \
+	 (u64)(devfn << 12) | (u64)(reg))
+
+static int
+pci_sal_ext_read (int seg, int bus, int devfn, int reg, int len, u32 *value)
+{
+	int result = 0;
+	u64 data = 0;
+
+	if ((seg > 65535) || (bus > 255) || (devfn > 255) || (reg > 4095))
+		return -EINVAL;
+
+	result = ia64_sal_pci_config_read(PCI_SAL_EXT_ADDRESS(seg, bus, devfn, reg), 1, len, &data);
+
+	*value = (u32) data;
+
+	return result;
+}
+
+static int
+pci_sal_ext_write (int seg, int bus, int devfn, int reg, int len, u32 value)
+{
+	if ((seg > 65535) || (bus > 255) || (devfn > 255) || (reg > 4095))
+		return -EINVAL;
+
+	return ia64_sal_pci_config_write(PCI_SAL_EXT_ADDRESS(seg, bus, devfn, reg), 1, len, value);
+}
+
+static struct pci_raw_ops pci_sal_ext_ops = {
+	.read = 	pci_sal_ext_read,
+	.write =	pci_sal_ext_write
+};
+
+struct pci_raw_ops *raw_pci_ops = &pci_sal_ops;	/* default to SAL < 3.2 */
+
+static int __init pci_set_sal_ops(void)
+{
+	if (sal_version >= SAL_VERSION_CODE(3, 2)) {
+		raw_pci_ops = &pci_sal_ext_ops;
+	}
+	return 0;
+}
+
+arch_initcall(pci_set_sal_ops);
 
 
 static int
Index: include/asm-ia64/sal.h
=================================RCS file: /var/cvs/linux-2.6/include/asm-ia64/sal.h,v
retrieving revision 1.4
diff -u -p -r1.4 sal.h
--- a/include/asm-ia64/sal.h	7 Jan 2004 21:30:42 -0000	1.4
+++ b/include/asm-ia64/sal.h	1 Mar 2004 16:06:30 -0000
@@ -741,10 +746,10 @@ ia64_sal_mc_set_params (u64 param_type, 
 
 /* Read from PCI configuration space */
 static inline s64
-ia64_sal_pci_config_read (u64 pci_config_addr, u64 size, u64 *value)
+ia64_sal_pci_config_read (u64 pci_config_addr, int type, u64 size, u64 *value)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size, 0, 0, 0, 0, 0);
+	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size, type, 0, 0, 0, 0);
 	if (value)
 		*value = isrv.v0;
 	return isrv.status;
@@ -752,11 +757,11 @@ ia64_sal_pci_config_read (u64 pci_config
 
 /* Write to PCI configuration space */
 static inline s64
-ia64_sal_pci_config_write (u64 pci_config_addr, u64 size, u64 value)
+ia64_sal_pci_config_write (u64 pci_config_addr, int type, u64 size, u64 value)
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
