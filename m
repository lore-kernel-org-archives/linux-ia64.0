From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Mar 2004 23:25:00 +0000
Subject: Re: [PATCH] 2.4.25: BUG(): Use guard page instead of page 0
Message-Id: <200403041625.00584.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040218221302.GA87364@dragonfly.csd.sgi.com>
In-Reply-To: <20040218221302.GA87364@dragonfly.csd.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 18 February 2004 6:14 pm, David Mosberger wrote:
> >>>>> On Wed, 18 Feb 2004 14:13:03 -0800, Jason Uhlenkott <jasonuhl@sgi.com> said:
> 
>   Jason> The ia64 BUG macro deliberately writes to address 0 in order to
>   Jason> trigger a page fault and an Oops.  This won't work if the process has
>   Jason> mapped something into page zero:  We'll just print the "kernel BUG"
>   Jason> message and continue (after having stomped on whatever user memory was
>   Jason> at address 0).
> 
>   Jason> A solution is to write to the guard page in region 5, which is
>   Jason> guaranteed to trigger a page fault.
> 
> The 2.6 kernel uses __builtin_trap(), which is even better (when available).

How about the following?  I like the idea of using the guard page
instead of address 0, but I sort of hate to add another magic number
(though I guess you could argue that "0" is almost as magic as
"0xa000000000000000").  And I would think most people would be
using gcc 3.x or better by now.

=== include/asm-ia64/page.h 1.9 vs edited ==--- 1.9/include/asm-ia64/page.h	Tue Jan 20 13:44:48 2004
+++ edited/include/asm-ia64/page.h	Thu Mar  4 16:20:00 2004
@@ -120,7 +120,13 @@
 #define is_invalid_hugepage_range(addr, len) 0
 #endif
 
-#define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); *(int *)0=0; } while (0)
+#if (__GNUC__ > 3) || (__GNUC__ = 3 && __GNUC_MINOR__ >= 1)
+# define ia64_abort()	__builtin_trap()
+#else
+# define ia64_abort()	(*(volatile int *) 0 = 0)
+#endif
+
+#define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); ia64_abort(); } while (0)
 #define PAGE_BUG(page) do { BUG(); } while (0)
 
 static __inline__ int

