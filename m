From: Andrew Morton <akpm@osdl.org>
Date: Sat, 12 Mar 2005 10:25:01 +0000
Subject: msi build error on ia64
Message-Id: <20050312022501.252adeb7.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Doing a `make allmodconfig' with Linus's latest tree:

drivers/built-in.o(.text+0x10302): In function `msi_init':
drivers/pci/msi.c:373: undefined reference to `pci_msi_quirk'
drivers/built-in.o(.text+0x10320):drivers/pci/msi.c:373: undefined reference to `pci_msi_quirk'

This is because drivers/pci/quirks.c:pci_msi_quirk is only defined if
CONFIG_X86_IO_APIC, but msi_init() unconditionally uses it.

Is this fix appropriate?


--- 25/drivers/pci/pci.h~ia64-msi-build-fix	Sat Mar 12 18:13:37 2005
+++ 25-akpm/drivers/pci/pci.h	Sat Mar 12 18:14:23 2005
@@ -64,8 +64,13 @@ extern void pci_remove_legacy_files(stru
 /* Lock for read/write access to pci device and bus lists */
 extern spinlock_t pci_bus_lock;
 
-extern int pcie_mch_quirk;
+#ifdef CONFIG_X86_IO_APIC
 extern int pci_msi_quirk;
+#else
+#define pci_msi_quirk 0
+#endif
+
+extern int pcie_mch_quirk;
 extern struct device_attribute pci_dev_attrs[];
 extern struct class_device_attribute class_device_attr_cpuaffinity;
 
_


