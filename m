From: David Hildenbrand <david@redhat.com>
Date: Tue, 09 Apr 2019 10:01:48 +0000
Subject: [PATCH v1 4/4] mm/memory_hotplug: Make __remove_pages() and arch_remove_memory() never fail
Message-Id: <20190409100148.24703-5-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190409100148.24703-1-david@redhat.com>
In-Reply-To: <20190409100148.24703-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Stefan Agner <stefan@agner.ch>, Nicholas Piggin <npiggin@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Vasily Gorbik <gor@linux.ibm.com>, Arun KS <arunks@codeaurora.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Rob Herring <robh@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>, Mathieu Malaterre <malat@debian.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org

All callers of arch_remove_memory() ignore errors. And we should really
try to remove any errors from the memory removal path.
No more errors are reported from __remove_pages(). BUG() in s390x code
in case arch_remove_memory() is triggered. We may implement that properly
later. WARN in case powerpc code failed to remove the section mapping,
which is better than ignoring the error completely right now.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Stefan Agner <stefan@agner.ch>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Rob Herring <robh@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-sh@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/ia64/mm/init.c            | 11 +++--------
 arch/powerpc/mm/mem.c          | 11 ++++-------
 arch/s390/mm/init.c            |  5 +++--
 arch/sh/mm/init.c              | 11 +++--------
 arch/x86/mm/init_32.c          |  5 +++--
 arch/x86/mm/init_64.c          | 10 +++-------
 include/linux/memory_hotplug.h |  8 ++++----
 mm/memory_hotplug.c            |  5 ++---
 8 files changed, 25 insertions(+), 41 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 379eb1f9adc9..d28e29103bdb 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -682,20 +682,15 @@ int arch_add_memory(int nid, u64 start, u64 size,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
+void arch_remove_memory(int nid, u64 start, u64 size,
+			struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
-	int ret;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
-	if (ret)
-		pr_warn("%s: Problem encountered in __remove_pages() as"
-			" ret=%d\n", __func__,  ret);
-
-	return ret;
+	__remove_pages(zone, start_pfn, nr_pages, altmap);
 }
 #endif
 #endif
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 76deaa8525db..cc9425fb9056 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -131,8 +131,8 @@ int __meminit arch_add_memory(int nid, u64 start, u64 size,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int __meminit arch_remove_memory(int nid, u64 start, u64 size,
-					struct vmem_altmap *altmap)
+void __meminit arch_remove_memory(int nid, u64 start, u64 size,
+				  struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -147,14 +147,13 @@ int __meminit arch_remove_memory(int nid, u64 start, u64 size,
 	if (altmap)
 		page += vmem_altmap_offset(altmap);
 
-	ret = __remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
-	if (ret)
-		return ret;
+	__remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
 
 	/* Remove htab bolted mappings for this section of memory */
 	start = (unsigned long)__va(start);
 	flush_inval_dcache_range(start, start + size);
 	ret = remove_section_mapping(start, start + size);
+	WARN_ON_ONCE(ret);
 
 	/* Ensure all vmalloc mappings are flushed in case they also
 	 * hit that section of memory
@@ -162,8 +161,6 @@ int __meminit arch_remove_memory(int nid, u64 start, u64 size,
 	vm_unmap_aliases();
 
 	resize_hpt_for_hotplug(memblock_phys_mem_size());
-
-	return ret;
 }
 #endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index f5db961ad792..31b1071315d7 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -234,14 +234,15 @@ int arch_add_memory(int nid, u64 start, u64 size,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
+void arch_remove_memory(int nid, u64 start, u64 size,
+			struct vmem_altmap *altmap)
 {
 	/*
 	 * There is no hardware or firmware interface which could trigger a
 	 * hot memory remove on s390. So there is nothing that needs to be
 	 * implemented.
 	 */
-	return -EBUSY;
+	BUG();
 }
 #endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 168d3a6b9358..5aeb4d7099a1 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -429,20 +429,15 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
+void arch_remove_memory(int nid, u64 start, u64 size,
+			struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
-	int ret;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
-	if (unlikely(ret))
-		pr_warn("%s: Failed, __remove_pages() = %d\n", __func__,
-			ret);
-
-	return ret;
+	__remove_pages(zone, start_pfn, nr_pages, altmap);
 }
 #endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 755dbed85531..075e568098f2 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -860,14 +860,15 @@ int arch_add_memory(int nid, u64 start, u64 size,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
+void arch_remove_memory(int nid, u64 start, u64 size,
+			struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	return __remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(zone, start_pfn, nr_pages, altmap);
 }
 #endif
 #endif
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index db42c11b48fb..20d14254b686 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1141,24 +1141,20 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	remove_pagetable(start, end, true, NULL);
 }
 
-int __ref arch_remove_memory(int nid, u64 start, u64 size,
-				struct vmem_altmap *altmap)
+void __ref arch_remove_memory(int nid, u64 start, u64 size,
+			      struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct page *page = pfn_to_page(start_pfn);
 	struct zone *zone;
-	int ret;
 
 	/* With altmap the first mapped page is offset from @start */
 	if (altmap)
 		page += vmem_altmap_offset(altmap);
 	zone = page_zone(page);
-	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
-	WARN_ON_ONCE(ret);
+	__remove_pages(zone, start_pfn, nr_pages, altmap);
 	kernel_physical_mapping_remove(start, start + size);
-
-	return ret;
 }
 #endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index d0a145ffa4fe..9d0efac902ec 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -112,10 +112,10 @@ static inline bool movable_node_is_enabled(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-extern int arch_remove_memory(int nid, u64 start, u64 size,
-				struct vmem_altmap *altmap);
-extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
-	unsigned long nr_pages, struct vmem_altmap *altmap);
+extern void arch_remove_memory(int nid, u64 start, u64 size,
+			       struct vmem_altmap *altmap);
+extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
+			   unsigned long nr_pages, struct vmem_altmap *altmap);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 17a60281c36f..52fef4a81e4c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -548,8 +548,8 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
-		 unsigned long nr_pages, struct vmem_altmap *altmap)
+void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
+		    unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long i;
 	unsigned long map_offset = 0;
@@ -580,7 +580,6 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	}
 
 	set_zone_contiguous(zone);
-	return 0;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-- 
2.17.2
