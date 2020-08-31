From: Nicolin Chen <nicoleotsuka@gmail.com>
Date: Mon, 31 Aug 2020 20:38:07 +0000
Subject: [RESEND][PATCH 3/7] ia64/sba_iommu: Avoid overflow at boundary_size
Message-Id: <20200831203811.8494-4-nicoleotsuka@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200831203811.8494-1-nicoleotsuka@gmail.com>
In-Reply-To: <20200831203811.8494-1-nicoleotsuka@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, tony.luck@intel.com, fenghua.yu@intel.com, schnelle@linux.ibm.com, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de
Cc: sfr@canb.auug.org.au, hch@lst.de, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org

The boundary_size might be as large as ULONG_MAX, which means
that a device has no specific boundary limit. So either "+ 1"
or passing it to ALIGN() would potentially overflow.

According to kernel defines:
    #define ALIGN_MASK(x, mask) (((x) + (mask)) & ~(mask))
    #define ALIGN(x, a)	ALIGN_MASK(x, (typeof(x))(a) - 1)

We can simplify the logic here:
  ALIGN(boundary + 1, 1 << shift) >> shift
= ALIGN_MASK(b + 1, (1 << s) - 1) >> s
= {[b + 1 + (1 << s) - 1] & ~[(1 << s) - 1]} >> s
= [b + 1 + (1 << s) - 1] >> s
= [b + (1 << s)] >> s
= (b >> s) + 1

So fixing a potential overflow with the safer shortcut.

Signed-off-by: Nicolin Chen <nicoleotsuka@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/hp/common/sba_iommu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 656a4888c300..945954903bb0 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -485,8 +485,8 @@ sba_search_bitmap(struct ioc *ioc, struct device *dev,
 	ASSERT(((unsigned long) ioc->res_hint & (sizeof(unsigned long) - 1UL)) = 0);
 	ASSERT(res_ptr < res_end);
 
-	boundary_size = (unsigned long long)dma_get_seg_boundary(dev) + 1;
-	boundary_size = ALIGN(boundary_size, 1ULL << iovp_shift) >> iovp_shift;
+	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
+	boundary_size = (dma_get_seg_boundary(dev) >> iovp_shift) + 1;
 
 	BUG_ON(ioc->ibase & ~iovp_mask);
 	shift = ioc->ibase >> iovp_shift;
-- 
2.17.1
