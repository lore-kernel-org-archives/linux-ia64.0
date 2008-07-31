From: Simon Horman <horms@verge.net.au>
Date: Thu, 31 Jul 2008 01:22:12 +0000
Subject: [patch 4/6] kdump: use is_kdump_kernel() in sba_init()
Message-Id: <20080731012927.629185400@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080731012208.115225969@vergenet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@gmail.com>

o Make use of is_kdump_kernel() rather than checking elfcorehdr_addr directly.

o Remove CONFIG_CRASH_DUMP as is_kdump_kernel() is safe to call anywhere

o Remove CONFIG_PROC_FS as it is bogus, the check
  should occur regardless of if CONFIG_PROC_FS is set or not.

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Vivek Goyal <vgoyal@redhat.com>

--- 
Andrew, this patch fixes bug in the (unlikely) case where
an ia64 crashdump kernel does not have CONFIG_PROC_FS set.
I think it is worth including in 2.6.27. But breakage cases are
likely to be minimal to non-existent, so I am comfortable
with post 2.6.27 too.

Index: linux-2.6/arch/ia64/hp/common/sba_iommu.c
=================================--- linux-2.6.orig/arch/ia64/hp/common/sba_iommu.c	2008-07-29 10:57:17.000000000 +1000
+++ linux-2.6/arch/ia64/hp/common/sba_iommu.c	2008-07-29 10:57:51.000000000 +1000
@@ -2070,14 +2070,13 @@ sba_init(void)
 	if (!ia64_platform_is("hpzx1") && !ia64_platform_is("hpzx1_swiotlb"))
 		return 0;
 
-#if defined(CONFIG_IA64_GENERIC) && defined(CONFIG_CRASH_DUMP) && \
-        defined(CONFIG_PROC_FS)
+#if defined(CONFIG_IA64_GENERIC)
 	/* If we are booting a kdump kernel, the sba_iommu will
 	 * cause devices that were not shutdown properly to MCA
 	 * as soon as they are turned back on.  Our only option for
 	 * a successful kdump kernel boot is to use the swiotlb.
 	 */
-	if (elfcorehdr_addr < ELFCORE_ADDR_MAX) {
+	if (is_kdump_kernel()) {
 		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
 			panic("Unable to initialize software I/O TLB:"
 				  " Try machvec=dig boot option");

-- 

-- 
Horms

