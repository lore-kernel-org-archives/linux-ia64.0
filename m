From: Joshua Aas <josha@sgi.com>
Date: Wed, 14 Jul 2004 22:06:44 +0000
Subject: clean up comments in arch/ia64/mm/init.c
Message-Id: <40F5AE74.10308@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While working on another patch in arch/ia64/mm/init.c, I found a comment that doesn't seem to make sense and one that just has a minor whitespace problem. The problem with the comment after setup_gate() is that boot memory seems to have already been freed a few lines earlier in the function and nothing else happens in mem_init() after the call to setup_gate() (unless compiling for IA32).

If there aren't any objections, it would be nice to have this patch applied so as not to confuse people in the future.

Signed-off-by: Josh Aas <josha@sgi.com>

----------------------------------------
--- a/arch/ia64/mm/init.c    2004-06-16 00:19:22.000000000 -0500
+++ b/arch/ia64/mm/init.c       2004-07-14 16:50:59.000000000 -0500
@@ -169,7 +169,7 @@ free_initrd_mem (unsigned long start, un
 {
        struct page *page;
        /*
-        * EFI uses 4KB pages while the kernel can use 4KB  or bigger.
+        * EFI uses 4KB pages while the kernel can use 4KB or bigger.
         * Thus EFI and the kernel may have different page sizes. It is
         * therefore possible to have the initrd share the same page as
         * the end of the kernel (given current setup).
@@ -580,7 +580,7 @@ mem_init (void)
                if (!fsyscall_table[i] || nolwsys)
                        fsyscall_table[i] = sys_call_table[i] | 1;
        }
-       setup_gate();   /* setup gate pages before we free up boot memory... */
+       setup_gate();
 
 #ifdef CONFIG_IA32_SUPPORT
        ia32_boot_gdt_init();

----------------------------------------

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068
