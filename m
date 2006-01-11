From: jes@trained-monkey.org (Jes Sorensen)
Date: Wed, 11 Jan 2006 12:13:09 +0000
Subject: [patch] sem2mutex sys_ia32.c
Message-Id: <17348.63061.396088.428841@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This one is relative to Linus' git tree as of this morning, but I assume
it should apply to any recent tree that has the mutex code included.

Cheers,
Jes


Migrate arch/ia64/ia32/sys_ia32 to using a mutex for mmap protection.

Signed-off-by: Jes Sorensen <jes@sgi.com>

----

 arch/ia64/ia32/sys_ia32.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

Index: linux-2.6.15-rc7-quilt/arch/ia64/ia32/sys_ia32.c
=================================--- linux-2.6.15-rc7-quilt.orig/arch/ia64/ia32/sys_ia32.c
+++ linux-2.6.15-rc7-quilt/arch/ia64/ia32/sys_ia32.c
@@ -51,9 +51,9 @@
 #include <linux/compat.h>
 #include <linux/vfs.h>
 #include <linux/mman.h>
+#include <linux/mutex.h>
 
 #include <asm/intrinsics.h>
-#include <asm/semaphore.h>
 #include <asm/types.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -85,7 +85,7 @@
  * while doing so.
  */
 /* XXX make per-mm: */
-static DECLARE_MUTEX(ia32_mmap_sem);
+static DEFINE_MUTEX(ia32_mmap_mutex);
 
 asmlinkage long
 sys32_execve (char __user *name, compat_uptr_t __user *argv, compat_uptr_t __user *envp,
@@ -894,11 +894,11 @@
 	prot = get_prot32(prot);
 
 #if PAGE_SHIFT > IA32_PAGE_SHIFT
-	down(&ia32_mmap_sem);
+	mutex_lock(&ia32_mmap_mutex);
 	{
 		addr = emulate_mmap(file, addr, len, prot, flags, offset);
 	}
-	up(&ia32_mmap_sem);
+	mutex_unlock(&ia32_mmap_mutex);
 #else
 	down_write(&current->mm->mmap_sem);
 	{
@@ -999,11 +999,9 @@
 	if (start >= end)
 		return 0;
 
-	down(&ia32_mmap_sem);
-	{
-		ret = sys_munmap(start, end - start);
-	}
-	up(&ia32_mmap_sem);
+	mutex_lock(&ia32_mmap_mutex);
+	ret = sys_munmap(start, end - start);
+	mutex_unlock(&ia32_mmap_mutex);
 #endif
 	return ret;
 }
@@ -1055,7 +1053,7 @@
 	if (retval < 0)
 		return retval;
 
-	down(&ia32_mmap_sem);
+	mutex_lock(&ia32_mmap_mutex);
 	{
 		if (offset_in_page(start)) {
 			/* start address is 4KB aligned but not page aligned. */
@@ -1079,7 +1077,7 @@
 		retval = sys_mprotect(start, end - start, prot);
 	}
   out:
-	up(&ia32_mmap_sem);
+	mutex_unlock(&ia32_mmap_mutex);
 	return retval;
 #endif
 }
@@ -1123,11 +1121,9 @@
 	old_len = PAGE_ALIGN(old_end) - addr;
 	new_len = PAGE_ALIGN(new_end) - addr;
 
-	down(&ia32_mmap_sem);
-	{
-		ret = sys_mremap(addr, old_len, new_len, flags, new_addr);
-	}
-	up(&ia32_mmap_sem);
+	mutex_lock(&ia32_mmap_mutex);
+	ret = sys_mremap(addr, old_len, new_len, flags, new_addr);
+	mutex_unlock(&ia32_mmap_mutex);
 
 	if ((ret >= 0) && (old_len < new_len)) {
 		/* mremap expanded successfully */
