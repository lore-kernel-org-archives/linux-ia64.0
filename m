From: Jeff Mahoney <jeffm@suse.com>
Date: Thu, 24 Feb 2011 22:23:09 +0000
Subject: [PATCH] ia64/mca: Fix cast from integer to pointer warning
Message-Id: <4D66DA4D.4020609@suse.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>

 ia64_mca_cpu_init has a void *data local variable that is assigned
 the value from either __get_free_pages() or mca_bootmem(). The problem
 is that __get_free_pages returns an unsigned long and mca_bootmem, via
 alloc_bootmem(), returns a void *. format_mca_init_stack takes the void *,
 and it's also used with __pa(), but that casts it to long anyway.

 This results in the following build warning:

 arch/ia64/kernel/mca.c:1898: warning: assignment makes pointer from
 integer without a cast

 This patch casts the return of __get_free_pages to a void * to avoid
 the warning.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 arch/ia64/kernel/mca.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1859,7 +1859,8 @@ ia64_mca_cpu_init(void *cpu_data)
 			data = mca_bootmem();
 			first_time = 0;
 		} else
-			data = __get_free_pages(GFP_KERNEL, get_order(sz));
+			data = (void *)__get_free_pages(GFP_KERNEL,
+							get_order(sz));
 		if (!data)
 			panic("Could not allocate MCA memory for cpu %d\n",
 					cpu);
-- 
Jeff Mahoney
SUSE Labs
