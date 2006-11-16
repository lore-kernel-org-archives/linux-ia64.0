From: Andrew Morton <akpm@osdl.org>
Date: Thu, 16 Nov 2006 20:29:25 +0000
Subject: Re: [patch 4/4] ia64: fix allmodconfig build
Message-Id: <20061116122925.7f7c61fd.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200611160843.kAG8hCf3017752@shell0.pdx.osdl.net>
In-Reply-To: <200611160843.kAG8hCf3017752@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Nov 2006 11:23:13 -0800
"Luck, Tony" <tony.luck@intel.com> wrote:

> Some bit of infiniband is
> now also breaking allmodconfig, so it is not like this patch is the
> only thing stopping allmodconfig from working.

I sent the below to Linus yesterday - it should fix that.



From: "Bryan O'Sullivan" <bos@serpentine.com>

The PCI Express and Hypertransport chip-specific source files should only
be built when the kernel has the capability of actually compiling them.

This fixes the driver build on, for example, ia64.

Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Roland Dreier <rolandd@cisco.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/infiniband/hw/ipath/Kconfig        |    2 +-
 drivers/infiniband/hw/ipath/Makefile       |    5 +++--
 drivers/infiniband/hw/ipath/ipath_driver.c |    4 ++++
 3 files changed, 8 insertions(+), 3 deletions(-)

diff -puN drivers/infiniband/hw/ipath/Kconfig~ib-ipath-fix-driver-build-for-platforms-with-pci-but-not-ht drivers/infiniband/hw/ipath/Kconfig
--- a/drivers/infiniband/hw/ipath/Kconfig~ib-ipath-fix-driver-build-for-platforms-with-pci-but-not-ht
+++ a/drivers/infiniband/hw/ipath/Kconfig
@@ -1,6 +1,6 @@
 config INFINIBAND_IPATH
 	tristate "QLogic InfiniPath Driver"
-	depends on PCI_MSI && 64BIT && INFINIBAND
+	depends on (PCI_MSI || HT_IRQ) && 64BIT && INFINIBAND
 	---help---
 	This is a driver for QLogic InfiniPath host channel adapters,
 	including InfiniBand verbs support.  This driver allows these
diff -puN drivers/infiniband/hw/ipath/Makefile~ib-ipath-fix-driver-build-for-platforms-with-pci-but-not-ht drivers/infiniband/hw/ipath/Makefile
--- a/drivers/infiniband/hw/ipath/Makefile~ib-ipath-fix-driver-build-for-platforms-with-pci-but-not-ht
+++ a/drivers/infiniband/hw/ipath/Makefile
@@ -10,8 +10,6 @@ ib_ipath-y := \
 	ipath_eeprom.o \
 	ipath_file_ops.o \
 	ipath_fs.o \
-	ipath_iba6110.o \
-	ipath_iba6120.o \
 	ipath_init_chip.o \
 	ipath_intr.o \
 	ipath_keys.o \
@@ -31,5 +29,8 @@ ib_ipath-y := \
 	ipath_verbs_mcast.o \
 	ipath_verbs.o
 
+ib_ipath-$(CONFIG_HT_IRQ) += ipath_iba6110.o
+ib_ipath-$(CONFIG_PCI_MSI) += ipath_iba6120.o
+
 ib_ipath-$(CONFIG_X86_64) += ipath_wc_x86_64.o
 ib_ipath-$(CONFIG_PPC64) += ipath_wc_ppc64.o
diff -puN drivers/infiniband/hw/ipath/ipath_driver.c~ib-ipath-fix-driver-build-for-platforms-with-pci-but-not-ht drivers/infiniband/hw/ipath/ipath_driver.c
--- a/drivers/infiniband/hw/ipath/ipath_driver.c~ib-ipath-fix-driver-build-for-platforms-with-pci-but-not-ht
+++ a/drivers/infiniband/hw/ipath/ipath_driver.c
@@ -390,12 +390,16 @@ static int __devinit ipath_init_one(stru
 
 	/* setup the chip-specific functions, as early as possible. */
 	switch (ent->device) {
+#ifdef CONFIG_HT_IRQ
 	case PCI_DEVICE_ID_INFINIPATH_HT:
 		ipath_init_iba6110_funcs(dd);
 		break;
+#endif
+#ifdef CONFIG_PCI_MSI
 	case PCI_DEVICE_ID_INFINIPATH_PE800:
 		ipath_init_iba6120_funcs(dd);
 		break;
+#endif
 	default:
 		ipath_dev_err(dd, "Found unknown QLogic deviceid 0x%x, "
 			      "failing\n", ent->device);
_

