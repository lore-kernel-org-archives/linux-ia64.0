From: Terry Loftin <terry.loftin@hp.com>
Date: Thu, 21 Jun 2007 20:41:04 +0000
Subject: Re: [IA64] [kdump] machveg=dig on hpzx1 platforms
Message-Id: <467AE260.7030906@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070621182441.GA21840@suse.de>
In-Reply-To: <20070621182441.GA21840@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bwalle@suse.de>
Cc: linux-ia64@vger.kernel.org, Khalid Aziz <khalid_aziz@hp.com>, kexec@lists.infradead.org

Bernhard Walle wrote:
> Hello,
> 
> on most HP machines, the 'machveg=dig' parameter is needed for the
> kdump kernel to avoid problems with the HP ioc. In the original kdump
> patches, a function ioc_iova_disable() was used, which (as I
> understand) disabled the IOC before executing the new kernel. However,
> that function wasn't added to mainline [2].
ioc_iova_disable() was used during the initial development of kexec.
In-flight DMA from improperly shutdown drivers would land on the
booting kexec kernel and cause all sorts of hard to find problems.
An MCA was actually preferred, to help identify errant drivers.

Some of kdump was based on this initial work and included
ioc_iova_disable().  This function was later dropped - a kdump
kernel boots in it's own memory space and shouldn't get incoming
DMA dropped on it.  The problem now is that during the boot of
the kdump kernel, the ioc is re-initialized, so in-flight DMA
causes an ioc IOTLB miss which leads to an MCA.  With kdump, the
idea is to get to the new kernel with as little code as we can,
so shutting down drivers properly is not an option.

Two possible solutions are:
   Fix the ioc to handle this situation, maybe by not clearing the
   IOTLB, and by reserving a few entries for the kdump kernel.  I
   personally don't understand the IOC well enough to implement this.
Or
   Use machvec=dig and avoid using the ioc altogether for the kdump
   kernel, (leaving the IOTLB intact).  This is something of a hack,
   but it works.

Because this ioc is HP specific hardware, the machvec=dig hack is only
needed for HP platforms.

> 
> However, with a 2.6.22-rc kernel, booting into the kdump kernel works
> surprisingly. I haven't found a fix in the git history that could be
> responsible. Was there a fix? Or is it just a random result on a
> machine I tested that it works?

In our testing, a lot of DMA was needed to cause this problem to show
up.  We would usually load the system with a lot of filesystem and
network activity, then use a debug module to cause the kernel to
oops within an interrupt handler.  On a quiet system, kdump would
usually work.

> Are there any plans to bring back ioc_iova_disable(), or would some
> automatic kernel code that uses machvec=dig in the kernel without
> forcing the user to pass an additional command line work?

Here is a patch to do that.  We use this internally, but
I had forgotten to post it.

-T

---
diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -42,6 +42,9 @@ #include <asm/dma.h>
  #include <asm/system.h>		/* wmb() */

  #include <asm/acpi-ext.h>
+#include <linux/crash_dump.h>
+
+extern int swiotlb_late_init_with_default_size (size_t size);

  #define PFX "IOC: "

@@ -2026,11 +2029,24 @@ sba_init(void)
  	if (!ia64_platform_is("hpzx1") && !ia64_platform_is("hpzx1_swiotlb"))
  		return 0;

+#ifdef CONFIG_CRASH_DUMP
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
