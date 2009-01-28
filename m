From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 28 Jan 2009 01:00:11 +0000
Subject: RE: [PATCH -tip] IA64: fix the compile error on IA64_DIG_VTD
Message-Id: <20090128100040J.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090127144602.GA12183@elte.hu>
	<20090127144637.GA14728@elte.hu>
	<57C9024A16AD2D4C97DC78E552063EA35F1F9A94@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA35F1F9A94@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: mingo@elte.hu, fujita.tomonori@lab.ntt.co.jp, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 27 Jan 2009 09:17:58 -0800
"Luck, Tony" <tony.luck@intel.com> wrote:

> > > > ---
> > > >  arch/ia64/kernel/dma-mapping.c |    3 +++
> > > >  arch/ia64/kernel/pci-swiotlb.c |    3 ---
> > > >  2 files changed, 3 insertions(+), 3 deletions(-)
> > >
> > > Applied to tip/core/iommu, thanks!
> >
> > Tony, is this fix fine with you too?
> 
> It works ... and dma-mapping.c is OK as a location for the
> definition.  But there seemes to be some small scope for a
> related cleanup:
> 
> There are "extern" declarations for "iommu_detected" in both
> <asm/iommu.h> (x86 and ia64) and also in <linux/dmar.h>

We can remove them in dmar.h. X86 exported iommu_detected and no_iommu
in several IOMMU code and we merged them into dmar.h. Seems that we
forgot to clean up dmar.h.


> Does having both of these avoid some #include hell?

I think we could. The root problem is that X86 sets up IOMMU in a very
hacky way. When we added VT-d support to IA64, we needed to add the
hacky code to IA64 even though IA64 doesn't need it.

We need to clean up the code to set up IOMMUs. I'll try later.

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -tip] intel-iommu: no need to export iommu_detected and no_iommu in dmar.h

The users of intel-iommu (x86 and IA64) export iommu_detected and
no_iommu in their own iommu.h.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 include/linux/dmar.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/dmar.h b/include/linux/dmar.h
index f284407..3e82a13 100644
--- a/include/linux/dmar.h
+++ b/include/linux/dmar.h
@@ -129,7 +129,6 @@ extern void dmar_msi_write(int irq, struct msi_msg *msg);
 extern int dmar_set_interrupt(struct intel_iommu *iommu);
 extern int arch_setup_dmar_msi(unsigned int irq);
 
-extern int iommu_detected, no_iommu;
 extern struct list_head dmar_rmrr_units;
 struct dmar_rmrr_unit {
 	struct list_head list;		/* list of rmrr units	*/
-- 
1.6.0.6

