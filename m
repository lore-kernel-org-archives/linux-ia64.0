From: Terry Loftin <terry.loftin@hp.com>
Date: Thu, 12 Jul 2007 23:23:22 +0000
Subject: [PATCH][IA64][kdump] use machvec=dig on hpzx1 platforms
Message-Id: <4696B7EA.6030009@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, tony.luck@intel.com
Cc: prarit@redhat.com, bwalle@suse.de, kexec@lists.infradead.org

Tony,

This is a cleaned up version of the machvec=dig patch:
* added CONFIG_IA64_GENERIC to avoid the compile problems, and
   test built with different config combinations
* moved include declaration to be consistent
* got review and sign off from Alex Williamson as well.
* +extern int swiotlb_late_init_with_default_size (size_t size);
   I left this because there is no applicable header file.
   I'm no fan of extern declarations either, but I didn't want to
   add a header just for this declaration, nor modify the machvec
   headers just to accommodate this hack.

Thanks!

-T

Patch Description:

On HP zx1 machines, the 'machvec=dig' parameter is needed for the
kdump kernel to avoid problems with the HP sba iommu.  The problem
is that during the boot of the kdump kernel, the iommu is re-initialized,
so in-flight DMA from improperly shutdown drivers causes an IOTLB
miss which leads to an MCA.  With kdump, the idea is to get into the
kdump kernel with as little code as we can, so shutting down drivers
properly is not an option.

The workaround is to add 'machvec=dig' to the kdump kernel boot
parameters.  This makes the kdump kernel avoid using the sba iommu
altogether, leaving the IOTLB intact.  Any ongoing DMA falls
harmlessly outside the kdump kernel.  After the kdump kernel reboots,
all devices will have been shutdown properly and DMA stopped.

This patch pushes that functionality into the sba iommu
initialization code, so that users won't have to find the obscure
documentation telling them about 'machvec=dig'.

This patch only affects HP platforms.  It still includes one
extern declaration in the file, because no applicable header file
exists.

Signed-off-by: Terry Loftin <terry.loftin@hp.com>
Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index c1dca22..6abc080 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -34,6 +34,7 @@ #include <linux/acpi.h>
  #include <linux/efi.h>
  #include <linux/nodemask.h>
  #include <linux/bitops.h>         /* hweight64() */
+#include <linux/crash_dump.h>

  #include <asm/delay.h>		/* ia64_get_itc() */
  #include <asm/io.h>
@@ -43,6 +44,8 @@ #include <asm/system.h>		/* wmb() */

  #include <asm/acpi-ext.h>

+extern int swiotlb_late_init_with_default_size (size_t size);
+
  #define PFX "IOC: "

  /*
@@ -2026,11 +2029,24 @@ sba_init(void)
  	if (!ia64_platform_is("hpzx1") && !ia64_platform_is("hpzx1_swiotlb"))
  		return 0;

+#if defined(CONFIG_IA64_GENERIC) && defined(CONFIG_CRASH_DUMP)
+	/* If we are booting a kdump kernel, the sba_iommu will
+	 * cause devices that were not shutdown properly to MCA
+	 * as soon as they are turned back on.  Our only option for
+	 * a successful kdump kernel boot is to use the swiotlb.
+	 */
+	if (elfcorehdr_addr < ELFCORE_ADDR_MAX) {
+		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
+			panic("Unable to initialize software I/O TLB:"
+				  " Try machvec=dig boot option");
+		machvec_init("dig");
+		return 0;
+	}
+#endif
+
  	acpi_bus_register_driver(&acpi_sba_ioc_driver);
  	if (!ioc_list) {
  #ifdef CONFIG_IA64_GENERIC
-		extern int swiotlb_late_init_with_default_size (size_t size);
-
  		/*
  		 * If we didn't find something sba_iommu can claim, we
  		 * need to setup the swiotlb and switch to the dig machvec.


