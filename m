From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Aug 2010 18:44:18 +0000
Subject: [PATCH v2] guard page for stacks that grow upwards
Message-Id: <4c7413025613b269c@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org

pa-risc and ia64 have stacks that grow upwards. Check that
they do not run into other mappings. By making VM_GROWSUP
0x0 on architectures that do not ever use it, we can avoid
some unpleasant #ifdefs in check_stack_guard_page().

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

Built, booted & tested on ia64
Built for x86_64 (but not booted or tested)
pa-risc - untested

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 709f672..77e6336 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -78,7 +78,11 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_MAYSHARE	0x00000080
 
 #define VM_GROWSDOWN	0x00000100	/* general info on the segment */
+#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
 #define VM_GROWSUP	0x00000200
+#else
+#define VM_GROWSUP	0x00000000
+#endif
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
@@ -1330,8 +1334,10 @@ unsigned long ra_submit(struct file_ra_state *ra,
 
 /* Do stack extension */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
-#ifdef CONFIG_IA64
+#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
 extern int expand_upwards(struct vm_area_struct *vma, unsigned long address);
+#else
+#define	expand_upwards(vma, address)
 #endif
 extern int expand_stack_downwards(struct vm_area_struct *vma,
 				  unsigned long address);
diff --git a/mm/memory.c b/mm/memory.c
index 2ed2267..6b2ab10 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2760,11 +2760,9 @@ out_release:
 }
 
 /*
- * This is like a special single-page "expand_downwards()",
- * except we must first make sure that 'address-PAGE_SIZE'
+ * This is like a special single-page "expand_{down|up}wards()",
+ * except we must first make sure that 'address{-|+}PAGE_SIZE'
  * doesn't hit another vma.
- *
- * The "find_vma()" will do the right thing even if we wrap
  */
 static inline int check_stack_guard_page(struct vm_area_struct *vma, unsigned long address)
 {
@@ -2783,6 +2781,15 @@ static inline int check_stack_guard_page(struct vm_area_struct *vma, unsigned lo
 
 		expand_stack(vma, address - PAGE_SIZE);
 	}
+	if ((vma->vm_flags & VM_GROWSUP) && address + PAGE_SIZE = vma->vm_end) {
+		struct vm_area_struct *next = vma->vm_next;
+
+		/* As VM_GROWSDOWN but s/below/above/ */
+		if (next && next->vm_start = address + PAGE_SIZE)
+			return next->vm_flags & VM_GROWSUP ? 0 : -ENOMEM;
+
+		expand_upwards(vma, address + PAGE_SIZE);
+	}
 	return 0;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 331e51a..6128dc8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1716,9 +1716,6 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
  * PA-RISC uses this for its stack; IA64 for its Register Backing Store.
  * vma is the last one with address > vma->vm_end.  Have to extend vma.
  */
-#ifndef CONFIG_IA64
-static
-#endif
 int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 {
 	int error;
