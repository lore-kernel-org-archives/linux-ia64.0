From: Manik Raina <manik@cisco.com>
Date: Fri, 21 Jun 2002 05:51:09 +0000
Subject: [Linux-ia64] Re: [Trivial Patch] : (2.5 latest) More __builtin_expect() cleanup in
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------C5BF9AC5EF26E9EF16E8F0D6"
Message-Id: <marc-linux-ia64-105590701905695@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------C5BF9AC5EF26E9EF16E8F0D6
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


	There you are Rusty, i've made the changes as suggested, verified it
	patches with -p1 . Patch attached.


Rusty Russell wrote:
> 
> In message <3D117C53.2B4F7C53@cisco.com> you write:
> >       Copying Rusty as well.
> >
> >       Changed files in the include/asm-ia64 directory to get rid of
> >       __builtin_expect() in favour of likely/unlikely.
> 
> Hi Manik,
> 
>         You got a reject because these patches do not apply with -p1
> (diffs should be taken from one level, furthur down as Linux norm).
> 
> The other issue is:
> > -     if (!__builtin_expect (current->mm->dumpable, 1)) {
>                         \
> > +     if (!likely (current->mm->dumpable)) {
> 
> if (unlikely(!current->mm->dumpable)), please!
> 
> Thanks,
> Rusty.
> --
>   Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
--------------C5BF9AC5EF26E9EF16E8F0D6
Content-Type: text/plain; charset=us-ascii;
 name="rusty.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rusty.patch"

diff -u -r linux-2.5.22/include/asm-ia64/delay.h real/include/asm-ia64/delay.h
--- linux-2.5.22/include/asm-ia64/delay.h	Mon Jun 17 08:01:23 2002
+++ real/include/asm-ia64/delay.h	Fri Jun 21 10:39:34 2002
@@ -15,6 +15,7 @@
 #include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
+#include <linux/compiler.h>
 
 #include <asm/processor.h>
 
@@ -52,7 +53,7 @@
 
 	__asm__ __volatile__("mov %0=ar.itc" : "=r"(result) :: "memory");
 #ifdef CONFIG_ITANIUM
-	while (__builtin_expect ((__s32) result == -1, 0))
+	while (unlikely((__s32) result == -1)
 		__asm__ __volatile__("mov %0=ar.itc" : "=r"(result) :: "memory");
 #endif
 	return result;
diff -u -r linux-2.5.22/include/asm-ia64/pgalloc.h real/include/asm-ia64/pgalloc.h
--- linux-2.5.22/include/asm-ia64/pgalloc.h	Mon Jun 17 08:01:23 2002
+++ real/include/asm-ia64/pgalloc.h	Fri Jun 21 10:43:09 2002
@@ -17,6 +17,7 @@
 
 #include <linux/mm.h>
 #include <linux/threads.h>
+#include <linux/compiler.h>
 
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
@@ -37,7 +38,7 @@
 {
 	unsigned long *ret = pgd_quicklist;
 
-	if (__builtin_expect(ret != NULL, 1)) {
+	if (likely(ret != NULL)) {
 		pgd_quicklist = (unsigned long *)(*ret);
 		ret[0] = 0;
 		--pgtable_cache_size;
@@ -52,9 +53,9 @@
 	/* the VM system never calls pgd_alloc_one_fast(), so we do it here. */
 	pgd_t *pgd = pgd_alloc_one_fast(mm);
 
-	if (__builtin_expect(pgd == NULL, 0)) {
+	if (unlikely(pgd == NULL)) {
 		pgd = (pgd_t *)__get_free_page(GFP_KERNEL);
-		if (__builtin_expect(pgd != NULL, 1))
+		if (likely(pgd != NULL))
 			clear_page(pgd);
 	}
 	return pgd;
@@ -80,7 +81,7 @@
 {
 	unsigned long *ret = (unsigned long *)pmd_quicklist;
 
-	if (__builtin_expect(ret != NULL, 1)) {
+	if (likely(ret != NULL)) {
 		pmd_quicklist = (unsigned long *)(*ret);
 		ret[0] = 0;
 		--pgtable_cache_size;
@@ -93,7 +94,7 @@
 {
 	pmd_t *pmd = (pmd_t *) __get_free_page(GFP_KERNEL);
 
-	if (__builtin_expect(pmd != NULL, 1))
+	if (likely(pmd != NULL))
 		clear_page(pmd);
 	return pmd;
 }
@@ -125,7 +126,7 @@
 {
 	struct page *pte = alloc_pages(GFP_KERNEL, 0);
 
-	if (__builtin_expect(pte != NULL, 1))
+	if (likely(pte != NULL))
 		clear_page(page_address(pte));
 	return pte;
 }
@@ -135,7 +136,7 @@
 {
 	pte_t *pte = (pte_t *) __get_free_page(GFP_KERNEL);
 
-	if (__builtin_expect(pte != NULL, 1))
+	if (likely(pte != NULL))
 		clear_page(pte);
 	return pte;
 }
diff -u -r linux-2.5.22/include/asm-ia64/processor.h real/include/asm-ia64/processor.h
--- linux-2.5.22/include/asm-ia64/processor.h	Mon Jun 17 08:01:30 2002
+++ real/include/asm-ia64/processor.h	Fri Jun 21 10:43:48 2002
@@ -16,6 +16,7 @@
 #include <linux/config.h>
 
 #include <linux/percpu.h>
+#include <linux/compiler.h>
 
 #include <asm/ptrace.h>
 #include <asm/kregs.h>
@@ -283,7 +284,7 @@
 	regs->loadrs = 0;									\
 	regs->r8 = current->mm->dumpable;	/* set "don't zap registers" flag */		\
 	regs->r12 = new_sp - 16;	/* allocate 16 byte scratch area */			\
-	if (!__builtin_expect (current->mm->dumpable, 1)) {					\
+	if (unlikely(!current->mm->dumpable)) {					\
 		/*										\
 		 * Zap scratch regs to avoid leaking bits between processes with different	\
 		 * uid/privileges.								\
diff -u -r linux-2.5.22/include/asm-ia64/softirq.h real/include/asm-ia64/softirq.h
--- linux-2.5.22/include/asm-ia64/softirq.h	Mon Jun 17 08:01:35 2002
+++ real/include/asm-ia64/softirq.h	Fri Jun 21 10:44:05 2002
@@ -13,7 +13,7 @@
 #define local_bh_enable()								\
 do {											\
 	__local_bh_enable();								\
-	if (__builtin_expect(local_softirq_pending(), 0) && really_local_bh_count() == 0)	\
+	if (unlikely(local_softirq_pending()) && really_local_bh_count() == 0)	\
 		do_softirq();								\
 } while (0)
 

--------------C5BF9AC5EF26E9EF16E8F0D6--


