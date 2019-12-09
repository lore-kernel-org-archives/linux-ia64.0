From: Logan Gunthorpe <logang@deltatee.com>
Date: Mon, 09 Dec 2019 19:13:43 +0000
Subject: [PATCH 3/6] powerpc/mm: Thread pgprot_t through create_section_mapping()
Message-Id: <20191209191346.5197-4-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191209191346.5197-1-logang@deltatee.com>
In-Reply-To: <20191209191346.5197-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>

In prepartion to support a pgprot_t argument for arch_add_memory().

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 arch/powerpc/include/asm/book3s/64/hash.h  |  3 ++-
 arch/powerpc/include/asm/book3s/64/radix.h |  3 ++-
 arch/powerpc/include/asm/sparsemem.h       |  3 ++-
 arch/powerpc/mm/book3s64/hash_utils.c      |  5 +++--
 arch/powerpc/mm/book3s64/pgtable.c         |  7 ++++---
 arch/powerpc/mm/book3s64/radix_pgtable.c   | 18 +++++++++++-------
 arch/powerpc/mm/mem.c                      |  5 +++--
 7 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 2781ebf6add4..6fc4520092c7 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -251,7 +251,8 @@ extern int __meminit hash__vmemmap_create_mapping(unsigned long start,
 extern void hash__vmemmap_remove_mapping(unsigned long start,
 				     unsigned long page_size);
 
-int hash__create_section_mapping(unsigned long start, unsigned long end, int nid);
+int hash__create_section_mapping(unsigned long start, unsigned long end,
+				 int nid, pgprot_t prot);
 int hash__remove_section_mapping(unsigned long start, unsigned long end);
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/powerpc/include/asm/book3s/64/radix.h b/arch/powerpc/include/asm/book3s/64/radix.h
index d97db3ad9aae..46799f3c3d1d 100644
--- a/arch/powerpc/include/asm/book3s/64/radix.h
+++ b/arch/powerpc/include/asm/book3s/64/radix.h
@@ -289,7 +289,8 @@ static inline unsigned long radix__get_tree_size(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int radix__create_section_mapping(unsigned long start, unsigned long end, int nid);
+int radix__create_section_mapping(unsigned long start, unsigned long end,
+				  int nid, pgprot_t prot);
 int radix__remove_section_mapping(unsigned long start, unsigned long end);
 #endif /* CONFIG_MEMORY_HOTPLUG */
 #endif /* __ASSEMBLY__ */
diff --git a/arch/powerpc/include/asm/sparsemem.h b/arch/powerpc/include/asm/sparsemem.h
index 3192d454a733..c89b32443cff 100644
--- a/arch/powerpc/include/asm/sparsemem.h
+++ b/arch/powerpc/include/asm/sparsemem.h
@@ -13,7 +13,8 @@
 #endif /* CONFIG_SPARSEMEM */
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-extern int create_section_mapping(unsigned long start, unsigned long end, int nid);
+extern int create_section_mapping(unsigned long start, unsigned long end,
+				  int nid, pgprot_t prot);
 extern int remove_section_mapping(unsigned long start, unsigned long end);
 
 #ifdef CONFIG_PPC_BOOK3S_64
diff --git a/arch/powerpc/mm/book3s64/hash_utils.c b/arch/powerpc/mm/book3s64/hash_utils.c
index 6c123760164e..f7a9fe86a367 100644
--- a/arch/powerpc/mm/book3s64/hash_utils.c
+++ b/arch/powerpc/mm/book3s64/hash_utils.c
@@ -781,7 +781,8 @@ int resize_hpt_for_hotplug(unsigned long new_mem_size)
 	return 0;
 }
 
-int hash__create_section_mapping(unsigned long start, unsigned long end, int nid)
+int hash__create_section_mapping(unsigned long start, unsigned long end,
+				 int nid, pgprot_t prot)
 {
 	int rc;
 
@@ -791,7 +792,7 @@ int hash__create_section_mapping(unsigned long start, unsigned long end, int nid
 	}
 
 	rc = htab_bolt_mapping(start, end, __pa(start),
-			       pgprot_val(PAGE_KERNEL), mmu_linear_psize,
+			       pgprot_val(prot), mmu_linear_psize,
 			       mmu_kernel_ssize);
 
 	if (rc < 0) {
diff --git a/arch/powerpc/mm/book3s64/pgtable.c b/arch/powerpc/mm/book3s64/pgtable.c
index 75483b40fcb1..b60c18d2e5c9 100644
--- a/arch/powerpc/mm/book3s64/pgtable.c
+++ b/arch/powerpc/mm/book3s64/pgtable.c
@@ -171,12 +171,13 @@ void mmu_cleanup_all(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int __meminit create_section_mapping(unsigned long start, unsigned long end, int nid)
+int __meminit create_section_mapping(unsigned long start, unsigned long end,
+				     int nid, pgprot_t prot)
 {
 	if (radix_enabled())
-		return radix__create_section_mapping(start, end, nid);
+		return radix__create_section_mapping(start, end, nid, prot);
 
-	return hash__create_section_mapping(start, end, nid);
+	return hash__create_section_mapping(start, end, nid, prot);
 }
 
 int __meminit remove_section_mapping(unsigned long start, unsigned long end)
diff --git a/arch/powerpc/mm/book3s64/radix_pgtable.c b/arch/powerpc/mm/book3s64/radix_pgtable.c
index 6ee17d09649c..328ed8669b6f 100644
--- a/arch/powerpc/mm/book3s64/radix_pgtable.c
+++ b/arch/powerpc/mm/book3s64/radix_pgtable.c
@@ -252,7 +252,7 @@ static unsigned long next_boundary(unsigned long addr, unsigned long end)
 
 static int __meminit create_physical_mapping(unsigned long start,
 					     unsigned long end,
-					     int nid)
+					     int nid, pgprot_t _prot)
 {
 	unsigned long vaddr, addr, mapping_size = 0;
 	bool prev_exec, exec = false;
@@ -288,7 +288,7 @@ static int __meminit create_physical_mapping(unsigned long start,
 			prot = PAGE_KERNEL_X;
 			exec = true;
 		} else {
-			prot = PAGE_KERNEL;
+			prot = _prot;
 			exec = false;
 		}
 
@@ -332,7 +332,7 @@ static void __init radix_init_pgtable(void)
 
 		WARN_ON(create_physical_mapping(reg->base,
 						reg->base + reg->size,
-						-1));
+						-1, PAGE_KERNEL));
 	}
 
 	/* Find out how many PID bits are supported */
@@ -707,8 +707,10 @@ static int __meminit stop_machine_change_mapping(void *data)
 
 	spin_unlock(&init_mm.page_table_lock);
 	pte_clear(&init_mm, params->aligned_start, params->pte);
-	create_physical_mapping(__pa(params->aligned_start), __pa(params->start), -1);
-	create_physical_mapping(__pa(params->end), __pa(params->aligned_end), -1);
+	create_physical_mapping(__pa(params->aligned_start),
+				__pa(params->start), -1, PAGE_KERNEL);
+	create_physical_mapping(__pa(params->end), __pa(params->aligned_end),
+				-1, PAGE_KERNEL);
 	spin_lock(&init_mm.page_table_lock);
 	return 0;
 }
@@ -865,14 +867,16 @@ static void __meminit remove_pagetable(unsigned long start, unsigned long end)
 	radix__flush_tlb_kernel_range(start, end);
 }
 
-int __meminit radix__create_section_mapping(unsigned long start, unsigned long end, int nid)
+int __meminit radix__create_section_mapping(unsigned long start,
+					    unsigned long end, int nid,
+					    pgprot_t prot)
 {
 	if (end >= RADIX_VMALLOC_START) {
 		pr_warn("Outside the supported range\n");
 		return -1;
 	}
 
-	return create_physical_mapping(__pa(start), __pa(end), nid);
+	return create_physical_mapping(__pa(start), __pa(end), nid, prot);
 }
 
 int __meminit radix__remove_section_mapping(unsigned long start, unsigned long end)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index be941d382c8d..22525d8935ce 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -94,7 +94,8 @@ int memory_add_physaddr_to_nid(u64 start)
 }
 #endif
 
-int __weak create_section_mapping(unsigned long start, unsigned long end, int nid)
+int __weak create_section_mapping(unsigned long start, unsigned long end,
+				  int nid, pgprot_t prot)
 {
 	return -ENODEV;
 }
@@ -114,7 +115,7 @@ int __ref arch_add_memory(int nid, u64 start, u64 size,
 	resize_hpt_for_hotplug(memblock_phys_mem_size());
 
 	start = (unsigned long)__va(start);
-	rc = create_section_mapping(start, start + size, nid);
+	rc = create_section_mapping(start, start + size, nid, PAGE_KERNEL);
 	if (rc) {
 		pr_warn("Unable to create mapping for hot added memory 0x%llx..0x%llx: %d\n",
 			start, start + size, rc);
-- 
2.20.1
