From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 06 Dec 2000 00:40:42 +0000
Subject: [Linux-ia64] ia64 patch breaks ix86 compile
Message-Id: <marc-linux-ia64-105590678205795@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

linux-2.4.0-test10-ia64-001115.diff includes this patch which breaks
ix86 compiles from the same source tree, no definition for
pgprot_writecombine.  Anybody care to fix this for ix86?

Index: 0-test11.1/drivers/char/mem.c
--- 0-test11.1/drivers/char/mem.c Wed, 15 Nov 2000 12:00:34 +1100 kaos (linux-2.4/N/b/49_mem.c 1.3.1.5 644)
+++ 0-test11.13(w)/drivers/char/mem.c Mon, 20 Nov 2000 16:50:00 +1100 kaos (linux-2.4/N/b/49_mem.c 1.3.1.6 644)
@@ -198,8 +198,12 @@ static int mmap_mem(struct file * file, 
 	 * through a file pointer that was marked O_SYNC will be
 	 * done non-cached.
 	 */
-	if (noncached_address(offset) || (file->f_flags & O_SYNC))
+	if (noncached_address(offset) || (file->f_flags & O_SYNC)
+	    || vma->vm_flags & VM_NONCACHED)
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+
+	if (vma->vm_flags & VM_WRITECOMBINED)
+		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 
 	/*
 	 * Don't dump addresses that are not real memory to a core file.


