From: Jack Steiner <steiner@sgi.com>
Date: Thu, 11 Aug 2005 17:27:36 +0000
Subject: [PATCH 6/7] - New SN hardware support - cpu_relax
Message-Id: <20050811172736.GA18809@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Add a few missing calls to "hint @pause".


	Signed-off-by: Jack Steiner <steiner@sgi.com>


 arch/ia64/sn/kernel/bte.c          |    1 +
 arch/ia64/sn/kernel/huberror.c     |    2 +-
 arch/ia64/sn/pci/pcibr/pcibr_dma.c |    3 ++-
 include/asm-ia64/sn/sn_sal.h       |    3 ++-
 4 files changed, 6 insertions(+), 3 deletions(-)




Index: linux/arch/ia64/sn/kernel/bte.c
=================================--- linux.orig/arch/ia64/sn/kernel/bte.c	2005-08-10 15:25:01.132347903 -0500
+++ linux/arch/ia64/sn/kernel/bte.c	2005-08-10 15:25:06.130870140 -0500
@@ -215,6 +215,7 @@ retry_bteop:
 	}
 
 	while ((transfer_stat = *bte->most_rcnt_na) = BTE_WORD_BUSY) {
+		cpu_relax();
 		if (ia64_get_itc() > itc_end) {
 			BTE_PRINTK(("BTE timeout nasid 0x%x bte%d IBLS = 0x%lx na 0x%lx\n",
 				NASID_GET(bte->bte_base_addr), bte->bte_num,
Index: linux/arch/ia64/sn/kernel/huberror.c
=================================--- linux.orig/arch/ia64/sn/kernel/huberror.c	2005-08-10 15:25:01.132347903 -0500
+++ linux/arch/ia64/sn/kernel/huberror.c	2005-08-10 15:25:06.131846604 -0500
@@ -76,7 +76,7 @@ void hubiio_crb_free(struct hubdev_info 
 	 */
 	REMOTE_HUB_S(hubdev_info->hdi_nasid, IIO_ICDR, (IIO_ICDR_PND | crbnum));
 	while (REMOTE_HUB_L(hubdev_info->hdi_nasid, IIO_ICDR) & IIO_ICDR_PND)
-		udelay(1);
+		cpu_relax();
 
 }
 
Index: linux/arch/ia64/sn/pci/pcibr/pcibr_dma.c
=================================--- linux.orig/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-08-10 15:25:01.133324368 -0500
+++ linux/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-08-10 15:25:06.136728927 -0500
@@ -306,7 +306,8 @@ void sn_dma_flush(uint64_t addr)
 		*(volatile uint32_t *)(p->sfdl_force_int_addr) = 1;
 
 		/* wait for the interrupt to come back. */
-		while (*(p->sfdl_flush_addr) != 0x10f) ;
+		while (*(p->sfdl_flush_addr) != 0x10f)
+			cpu_relax();
 
 		/* okay, everything is synched up. */
 		spin_unlock_irqrestore((spinlock_t *)&p->sfdl_flush_lock, flags);
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-08-10 15:25:01.133324368 -0500
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-08-10 15:25:06.147470038 -0500
@@ -749,7 +749,8 @@ ia64_sn_power_down(void)
 {
 	struct ia64_sal_retval ret_stuff;
 	SAL_CALL(ret_stuff, SN_SAL_SYSTEM_POWER_DOWN, 0, 0, 0, 0, 0, 0, 0);
-	while(1);
+	while(1)
+		cpu_relax();
 	/* never returns */
 }
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


