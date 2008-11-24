From: Fenghua Yu <fenghua.yu@intel.com>
Date: Mon, 24 Nov 2008 19:53:27 +0000
Subject: [PATCH 2/2] Enable Pass Through Feature in Intel IOMMU
Message-Id: <20081124195327.GA29471@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <A6AD88C3F2289247BE726C37303E1EB884780E2A@orsmsx505.amr.corp.intel.com> <48F62C0E.2060705@redhat.com> <A6AD88C3F2289247BE726C37303E1EB884876541@orsmsx505.amr.corp.intel.com> <1224236501.6770.1256.camel@macbook.infradead.org>
In-Reply-To: <1224236501.6770.1256.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Avi Kivity <avi@redhat.com>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, iommu@lists.linux-foundation.org, kvm@vger.kernel.org

The patch set adds kernel parameter intel_iommu=pt to set up pass through mode in
context mapping entry. This disables DMAR in linux kernel; but KVM still runs on
VT-d. In this mode, kernel uses swiotlb for DMA API functions but other VT-d
functionalities are enabled for KVM. By default, pass though mode is disabled in
kernel.

This second patch changes context mapping interface called in KVM vtd.c. KVM
always uses multi level translation page table in VT-d.


Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Weidong Han <weidong.han@intel.com>
Signed-off-by: Allen Kay <allen.m.kay@intel.com>
Signed-off-by: David Woodhouse <david.woodhouse@intel.com>

---

 vtd.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff --git a/virt/kvm/vtd.c b/virt/kvm/vtd.c
index a770874..7b753d7 100644
--- a/virt/kvm/vtd.c
+++ b/virt/kvm/vtd.c
@@ -124,7 +124,7 @@ int kvm_iommu_map_guest(struct kvm *kvm,
 			       pdev->bus->number, pdev->devfn);
 
 	r = intel_iommu_context_mapping(kvm->arch.intel_iommu_domain,
-					pdev);
+					pdev, CONTEXT_TT_MULTI_LEVEL);
 	if (r) {
 		printk(KERN_ERR "Domain context map for %s failed",
 		       pci_name(pdev));
