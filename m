From: Bernhard Walle <bwalle@suse.de>
Date: Thu, 08 May 2008 16:05:24 +0000
Subject: [PATCH] [IA64] Don't reserve crashkernel memory > 4 GB
Message-Id: <20080508180524.27cb2e8d@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, kexec@lists.infradead.org

Some IA64 machines map all cell-local memory above 4 GB (32 bit limit).
However, in most cases, the kernel needs some memory below that limit that is
DMA-capable. So in this machine configuration, the crashkernel will be reserved
above 4 GB.

For machines that use SWIOTLB implementation because they lack an I/O MMU
the low memory is required by the SWIOTLB implementation. In that case,
it doesn't make sense to reserve the crashkernel at all because it's unusable
for kdump.

A special case is the "hpzx1" machine vector. In theory, it has a I/O MMU, so
it can be booted above 4 GB. However, in the kdump case that is not possible
because of changeset 51b58e3e26ebfb8cd56825c4b396ed251f51dec9:

    On HP zx1 machines, the 'machvec=dig' parameter is needed for the kdump
    kernel to avoid problems with the HP sba iommu.  The problem is that during
    the boot of the kdump kernel, the iommu is re-initialized, so in-flight DMA
    from improperly shutdown drivers causes an IOTLB miss which leads to an
    MCA.  With kdump, the idea is to get into the kdump kernel with as little
    code as we can, so shutting down drivers properly is not an option.
    
    The workaround is to add 'machvec=dig' to the kdump kernel boot parameters.
    This makes the kdump kernel avoid using the sba iommu altogether, leaving
    the IOTLB intact.  Any ongoing DMA falls harmlessly outside the kdump
    kernel.  After the kdump kernel reboots, all devices will have been
    shutdown properly and DMA stopped.
    
    This patch pushes that functionality into the sba iommu initialization
    code, so that users won't have to find the obscure documentation telling
    them about 'machvec=dig'.

This means that also for hpzx1 it's not possible to boot when all
memory is above the 4 GB limit. So the only machine vector that can handle
this case is "sn2".

The patch is against 2.6.25. For 2.6.26, "uv" from SGI has probably added to
the patch.


Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 arch/ia64/kernel/setup.c |   29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

Index: linux-2.6.25/arch/ia64/kernel/setup.c
=================================--- linux-2.6.25.orig/arch/ia64/kernel/setup.c
+++ linux-2.6.25/arch/ia64/kernel/setup.c
@@ -215,6 +215,25 @@ __initcall(register_memory);
 
 
 #ifdef CONFIG_KEXEC
+
+/*
+ * This function checks if the reserved crashkernel is allowed on the specific
+ * IA64 machine flavour. Machines without an IO TLB use swiotlb and require
+ * some memory below 4 GB (i.e. in 32 bit area), see the implementation of
+ * lib/swiotlb.c. The hpzx1 architecture has an IO TLB but cannot use that
+ * in kdump case. See the comment in sba_init() in sba_iommu.c.
+ *
+ * So, the only machvec that really supports loading the kdump kernel
+ * over 4 GB is "sn2".
+ */
+static int __init check_crashkernel_memory(unsigned long pbase, size_t size)
+{
+	if (ia64_platform_is("sn2"))
+		return 1;
+	else
+		return pbase < (1UL << 32);
+}
+
 static void __init setup_crashkernel(unsigned long total, int *n)
 {
 	unsigned long long base = 0, size = 0;
@@ -228,6 +247,16 @@ static void __init setup_crashkernel(uns
 			base = kdump_find_rsvd_region(size,
 					rsvd_region, *n);
 		}
+
+		if (!check_crashkernel_memory(base, size)) {
+			pr_warning("crashkernel: There would be kdump memory "
+				"at %ld GB but this is unusable because it "
+				"must\nbe below 4 GB. Change the memory "
+				"configuration of the machine.\n",
+				(unsigned long)(base >> 30));
+			return;
+		}
+
 		if (base != ~0UL) {
 			printk(KERN_INFO "Reserving %ldMB of memory at %ldMB "
 					"for crashkernel (System RAM: %ldMB)\n",
