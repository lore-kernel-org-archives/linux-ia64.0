From: Takanori Kawano <t-kawano@ebina.hitachi.co.jp>
Date: Thu, 28 Jun 2001 03:02:48 +0000
Subject: [Linux-ia64] [PATCH] free_initrd_mem() need to be correct
Message-Id: <marc-linux-ia64-105590693005795@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I tried to boot kernel using 'memQ2m' option on Bigsur 
with 1GB memory, it failed and displayed the following message.

           .
           .
    Freeing initrd memory: 746KB freed.
    kernel BUG at page_alloc.c:86!

On our investigation, the cause is that:
(1) When 'mem=xxx' is used, it is possible that the page corresponds to
    the memory used by initrd is not made because initrd is loaded into 
    high address region by bootloader.
(2) free_initrd_mem() frees the memory used by initrd even if its 
    corresponding page was not exist.

The following patch corrects this problem.

--- ./arch/ia64/mm/init.c       Thu Jun 28 10:16:45 2001
+++ ./arch/ia64/mm/init.c.new   Thu Jun 28 09:57:58 2001
@@ -141,10 +141,12 @@
                printk ("Freeing initrd memory: %ldkB freed\n", (end - start) >>
 10);

        for (; start < end; start += PAGE_SIZE) {
-               clear_bit(PG_reserved, &virt_to_page(start)->flags);
-               set_page_count(virt_to_page(start), 1);
-               free_page(start);
-               ++totalram_pages;
+               if (VALID_PAGE(virt_to_page(start))) {
+                       clear_bit(PG_reserved, &virt_to_page(start)->flags);
+                       set_page_count(virt_to_page(start), 1);
+                       free_page(start);
+                       ++totalram_pages;
+               }
        }
 }

---
Takanori Kawano
Hitachi Ltd,
Internet Systems Platform Division
t-kawano@ebina.hitachi.co.jp



