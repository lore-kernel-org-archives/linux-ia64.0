From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Mon, 03 Dec 2001 22:38:43 +0000
Subject: [Linux-ia64] mmap bug fix for IA-32 apps
Message-Id: <marc-linux-ia64-105590698805593@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We found a bug with the mmap code in support of IA-32 apps. That bug was
exposed in a multi-threaded environment, and malloc(2), for example, was
causing a segmentation fault because of it.
Basically, the current code always saves and restores the user area that is
not part of the range specified by mmap(2) but on the native (i.e. IA-64)
page(s) affected by mmap() (because of the page-size difference between
IA-32 and IA-64), when it changes the protection.

Since such a user area can already have write protection, it's possible it
can cause data corruption when the kernel restores the saved (old) data. 

We tested several IA-32 applications, including Netscape.

Thanks,
Jun

diff -Nu arch/ia64/ia32/sys_ia32.c.orig arch/ia64/ia32/sys_ia32.c 
--- arch/ia64/ia32/sys_ia32.c.orig      Fri Nov 16 13:07:10 2001
+++ arch/ia64/ia32/sys_ia32.c   Fri Nov 30 13:17:55 2001
@@ -285,7 +285,16 @@
        if (!page)
                return -ENOMEM;
 
-       if (old_prot)
+       if (old_prot & VM_WRITE) {
+               if (flags & MAP_ANONYMOUS) {
+                       if (clear_user((void *) start, end - start)) {
+                               ret = -EFAULT;
+                               goto out;
+                       }
+                       goto out;
+               } else
+                       goto skip_mmap;
+       } else if (old_prot)
                copy_from_user(page, (void *) PAGE_START(start), PAGE_SIZE);
 
        down_write(&current->mm->mmap_sem);
@@ -306,6 +315,7 @@
                        copy_to_user((void *) end, page + PAGE_OFF(end),
                                     PAGE_SIZE - PAGE_OFF(end));
        }
+skip_mmap:
        if (!(flags & MAP_ANONYMOUS)) {
                /* read the file contents */
                inode = file->f_dentry->d_inode;




