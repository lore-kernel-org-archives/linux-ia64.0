From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Aug 2010 16:31:41 +0000
Subject: [PATCH] guard page for stacks that grow upwards
Message-Id: <4c73f3ed34663af90@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org

pa-risc and ia64 have stacks that grow upwards. Check that
they do not run into other mappings.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

Updated to match the new code - still not tested on pa-risc.
The #ifdefs are ugly - suggestions welcome on how to make
the code prettier.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 709f672..089d135 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1330,7 +1330,7 @@ unsigned long ra_submit(struct file_ra_state *ra,
 
 /* Do stack extension */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
-#ifdef CONFIG_IA64
+#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
 extern int expand_upwards(struct vm_area_struct *vma, unsigned long address);
 #endif
 extern int expand_stack_downwards(struct vm_area_struct *vma,
diff --git a/mm/memory.c b/mm/memory.c
index 2ed2267..5127b1c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2760,29 +2760,43 @@ out_release:
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
-	address &= PAGE_MASK;
-	if ((vma->vm_flags & VM_GROWSDOWN) && address = vma->vm_start) {
-		struct vm_area_struct *prev = vma->vm_prev;
+	if (vma->vm_flags & VM_GROWSDOWN) {
+		address &= PAGE_MASK;
+		if (address = vma->vm_start) {
+			struct vm_area_struct *prev = vma->vm_prev;
 
-		/*
-		 * Is there a mapping abutting this one below?
-		 *
-		 * That's only ok if it's the same stack mapping
-		 * that has gotten split..
-		 */
-		if (prev && prev->vm_end = address)
-			return prev->vm_flags & VM_GROWSDOWN ? 0 : -ENOMEM;
+			/*
+			 * Is there a mapping abutting this one below?
+			 *
+			 * That's only ok if it's the same stack mapping
+			 * that has gotten split..
+			 */
+			if (prev && prev->vm_end = address)
+				return prev->vm_flags & VM_GROWSDOWN ? 0 : -ENOMEM;
 
-		expand_stack(vma, address - PAGE_SIZE);
+			expand_stack(vma, address - PAGE_SIZE);
+		}
+	}
+#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
+	else if (vma->vm_flags & VM_GROWSUP) {
+		address = PAGE_ALIGN(address + 1);
+		if (address = vma->vm_end) {
+			struct vm_area_struct *next = vma->vm_next;
+
+			/* As VM_GROWSDOWN but s/below/above/ */
+			if (next && next->vm_start = address)
+				return next->vm_flags & VM_GROWSUP ? 0 : -ENOMEM;
+
+			expand_upwards(vma, address);
+		}
 	}
+#endif
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
