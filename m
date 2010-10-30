From: Jesper Juhl <jj@chaosbits.net>
Date: Sat, 30 Oct 2010 19:35:58 +0000
Subject: [PATCH] IA64 perfmon: Change vmalloc to vzalloc and drop memset.
Message-Id: <alpine.LNX.2.00.1010302131050.1572@swampdragon.chaosbits.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Stephane Eranian <eranian@hpl.hp.com>, David Mosberger-Tang <davidm@hpl.hp.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>

Hi,

vzalloc() nicely zeroes memory for us, so we don't have to do a vmalloc() 
and then manually memset() the returned memory when all we want is for it 
to be zero. Patch changes this for pfm_rvmalloc().


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
Untested patch since I have neither the hardware nor tools to even compile 
this.

 perfmon.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 39e534f..3aee09d 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -829,10 +829,9 @@ pfm_rvmalloc(unsigned long size)
 	unsigned long addr;
 
 	size = PAGE_ALIGN(size);
-	mem  = vmalloc(size);
+	mem  = vzalloc(size);
 	if (mem) {
 		//printk("perfmon: CPU%d pfm_rvmalloc(%ld)=%p\n", smp_processor_id(), size, mem);
-		memset(mem, 0, size);
 		addr = (unsigned long)mem;
 		while (size > 0) {
 			pfm_reserve_page(addr);

-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

