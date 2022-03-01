From: Christoph Hellwig <hch@lst.de>
Date: Tue, 01 Mar 2022 10:53:07 +0000
Subject: [PATCH 08/12] x86: centralize setting SWIOTLB_FORCE when guest memory encryption is enabled
Message-Id: <20220301105311.885699-9-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de>
In-Reply-To: <20220301105311.885699-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

Move enabling SWIOTLB_FORCE for guest memory encryption into common code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/kernel/cpu/mshyperv.c | 8 --------
 arch/x86/kernel/pci-dma.c      | 7 +++++++
 arch/x86/mm/mem_encrypt_amd.c  | 3 ---
 3 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/arch/x86/kernel/cpu/mshyperv.c b/arch/x86/kernel/cpu/mshyperv.c
index 5a99f993e6392..568274917f1cd 100644
--- a/arch/x86/kernel/cpu/mshyperv.c
+++ b/arch/x86/kernel/cpu/mshyperv.c
@@ -336,14 +336,6 @@ static void __init ms_hyperv_init_platform(void)
 			swiotlb_unencrypted_base = ms_hyperv.shared_gpa_boundary;
 #endif
 		}
-
-#ifdef CONFIG_SWIOTLB
-		/*
-		 * Enable swiotlb force mode in Isolation VM to
-		 * use swiotlb bounce buffer for dma transaction.
-		 */
-		swiotlb_force = SWIOTLB_FORCE;
-#endif
 	}
 
 	if (hv_max_functions_eax >= HYPERV_CPUID_NESTED_FEATURES) {
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 2ac0ef9c2fb76..7ab7002758396 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -53,6 +53,13 @@ static void __init pci_swiotlb_detect(void)
 	if (cc_platform_has(CC_ATTR_HOST_MEM_ENCRYPT))
 		x86_swiotlb_enable = true;
 
+	/*
+	 * Guest with guest memory encryption must always do I/O through a
+	 * bounce buffer as the hypervisor can't access arbitrary VM memory.
+	 */
+	if (cc_platform_has(CC_ATTR_GUEST_MEM_ENCRYPT))
+		swiotlb_force = SWIOTLB_FORCE;
+
 	if (swiotlb_force = SWIOTLB_FORCE)
 		x86_swiotlb_enable = true;
 }
diff --git a/arch/x86/mm/mem_encrypt_amd.c b/arch/x86/mm/mem_encrypt_amd.c
index 2b2d018ea3450..a72942d569cf9 100644
--- a/arch/x86/mm/mem_encrypt_amd.c
+++ b/arch/x86/mm/mem_encrypt_amd.c
@@ -191,9 +191,6 @@ void __init sme_early_init(void)
 	/* Update the protection map with memory encryption mask */
 	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
 		protection_map[i] = pgprot_encrypted(protection_map[i]);
-
-	if (cc_platform_has(CC_ATTR_GUEST_MEM_ENCRYPT))
-		swiotlb_force = SWIOTLB_FORCE;
 }
 
 void __init sev_setup_arch(void)
-- 
2.30.2
