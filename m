From: Richard Hirst <rhirst@linuxcare.com>
Date: Fri, 31 Aug 2001 00:05:56 +0000
Subject: [Linux-ia64] kernel bug in mmap
Message-Id: <marc-linux-ia64-105590698805108@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
  Attempts to mmap an empty file result in the file being left busy,
such that the file system cannot be unmounted.  Fix below.

Richard


--- linux/arch/ia64/kernel/sys_ia64.cold	Fri Aug 31 01:37:58 2001
+++ linux/arch/ia64/kernel/sys_ia64.c	Fri Aug 31 01:38:43 2001
@@ -194,7 +194,7 @@
 	 */
 	len = PAGE_ALIGN(len);
 	if (len = 0)
-		return addr;
+		goto out;
 
 	/* don't permit mappings into unmapped space or the virtual page table of a region: */
 	roff = rgn_offset(addr);
@@ -208,7 +208,7 @@
 	down_write(&current->mm->mmap_sem);
 	addr = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	up_write(&current->mm->mmap_sem);
-
+out:
 	if (file)
 		fput(file);
 	return addr;

