From: Mark Maule <maule@sgi.com>
Date: Wed, 16 Mar 2005 22:48:59 +0000
Subject: [PATCH 2.6.12 1/1] altix: disable TIOCA GART TLB prefetching
Message-Id: <20050316224859.11870.56864.89665@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch to disable SGI TIOCA GART TLB prefetching due to hw bug.

Signed-off-by: Mark Maule <maule@sgi.com>

=== arch/ia64/sn/pci/tioca_provider.c 1.1 vs 1.2 ==--- 1.1/arch/ia64/sn/pci/tioca_provider.c	2005-03-10 16:33:04 -06:00
+++ 1.2/arch/ia64/sn/pci/tioca_provider.c	2005-03-16 16:28:48 -06:00
@@ -171,15 +171,15 @@
 	 *      use agp op-combining
 	 *      use GET semantics to fetch memory
 	 *      participate in coherency domain
-	 *      prefetch TLB entries
+	 * 	DISABLE GART PREFETCHING due to hw bug tracked in SGI PV930029
 	 */
 
 	ca_base->ca_control1 |= CA_AGPDMA_OP_ENB_COMBDELAY;	/* PV895469 ? */
 	ca_base->ca_control2 &= ~(CA_GART_MEM_PARAM);
 	ca_base->ca_control2 |= (0x2ull << CA_GART_MEM_PARAM_SHFT);
 	tioca_kern->ca_gart_iscoherent = 1;
-	ca_base->ca_control2 |-	    (CA_GART_WR_PREFETCH_ENB | CA_GART_RD_PREFETCH_ENB);
+	ca_base->ca_control2 &+	    ~(CA_GART_WR_PREFETCH_ENB | CA_GART_RD_PREFETCH_ENB);
 
 	/*
 	 * Unmask GART fetch error interrupts.  Clear residual errors first.
