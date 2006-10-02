From: Horms <horms@verge.net.au>
Date: Mon, 02 Oct 2006 04:10:33 +0000
Subject: [patch 1/3] [IA64] kexec/kdump: Remove ioc_iova_disable()
Message-Id: <20061002041031.GB3034@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Date: Fri, 29 Sep 2006 14:46:23 -0700
> From: Tony Luck <tony.luck@intel.com>
> Message-Id: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
> To: linux-ia64@vger.kernel.org
> Subject: kexec/kdump and the ia64 test tree
> Cc: akpm@osdl.org, horms@verge.net.au
>
> The kexec/kdump patch in my test tree is very stale, plus it is time
> for some git maintenance on the test tree (to clean away all the
> "Auto-update from upstream" commits that my workflow generates). So
> I'm planning on resetting my "test" branch to Linus-latest + kdump/kexec
> (so git pull/fetch will barf on my test tree, you'll need to re-clone).
>
> Below I've include what I believe to be the latest version of the
> patch produced by:
>
> 1) Take 2.6.18
> 2) Apply Nan Hai patch for 2.6.18 (posted Sept 20th)
> 3) Pull in Linus-latest (c972398b ...) and resolve conflicts in smp.h, sysctl.h
> 4) Apply Nan hai's "Fix OS_INIT" patch that fixed Indou-san's deadlock issue
> +(Sept 28th)
> 5) Fix a few warnings:
>         arch/ia64/kernel/iosapic.c:
>                 `vec' may be used before set in kexec_disable_iosapic() ... I'm
>                 not totally confident that I fixed this right. Please look
> +closely
>                 at what I did.
>         arch/ia64/kernel/smp.c:
>                 Trivial fixes to stop compiler complaining that
> +kdump_smp_send_stop()
>                 and kdump_smp_send_init() definitions were not prototypes.
> 6) Lots of white-space cleanup (mostly multiple spaces that should be tabs, but
> +I
>    also threw the whole kdump_find_rsvd_region() in arch/ia64/kernel/efi.c
> +through
>    scripts/Lindent as it was only using two-spaces for indentation.)
>
> Let me know if I've goofed up the patch during this process.
>
> I'm planning to reset my test tree on Monday (Oct 2nd).
>
> -Tony

This is the portion of the above patch that removes ioc_iova_disable()

Cc: Tony Luck <tony.luck@intel.com>
Cc: Zou Nan hai <nanhai.zou@intel.com>
Signed-Off-By: Simon Horman <horms@verge.net.au>

 arch/ia64/hp/common/sba_iommu.c  |   22 ----------------------
 include/asm-ia64/machvec_hpzx1.h |    2 --
 2 files changed, 24 deletions(-)

ccf29557dd63bf591af772205d4cf3ed2281add4
diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index aa4ef60..db8e1fc 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1623,28 +1623,6 @@ #endif
 	READ_REG(ioc->ioc_hpa + IOC_IBASE);
 }
 
-#ifdef CONFIG_KEXEC
-void
-ioc_iova_disable(void)
-{
-	struct ioc *ioc;
-
-	ioc = ioc_list;
-
-	while (ioc != NULL) {
-		/* Disable IOVA translation */
-		WRITE_REG(ioc->ibase & 0xfffffffffffffffe, ioc->ioc_hpa + IOC_IBASE);
-		READ_REG(ioc->ioc_hpa + IOC_IBASE);
-
-		/* Clear I/O TLB of any possible entries */
-		WRITE_REG(ioc->ibase | (get_iovp_order(ioc->iov_size) + iovp_shift), ioc->ioc_hpa + IOC_PCOM);
-		READ_REG(ioc->ioc_hpa + IOC_PCOM);
-
-		ioc = ioc->next;
-	}
-}
-#endif
-
 static void __init
 ioc_resource_init(struct ioc *ioc)
 {
diff --git a/include/asm-ia64/machvec_hpzx1.h b/include/asm-ia64/machvec_hpzx1.h
index 2ae54c3..e90daf9 100644
--- a/include/asm-ia64/machvec_hpzx1.h
+++ b/include/asm-ia64/machvec_hpzx1.h
@@ -34,6 +34,4 @@ #define platform_dma_sync_sg_for_device	
 #define platform_dma_supported			sba_dma_supported
 #define platform_dma_mapping_error		sba_dma_mapping_error
 
-extern void ioc_iova_disable(void);
-
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */
