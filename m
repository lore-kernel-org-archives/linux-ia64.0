From: domen@coderock.org
Date: Sat, 19 Mar 2005 13:19:06 +0000
Subject: [patch 1/1] printk : arch/ia64/kernel/smp.c
Message-Id: <20050319131906.E934A1F245@trashy.coderock.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



printk() calls should include appropriate KERN_* constant.

Signed-off-by: Christophe Lucas <clucas@rotomalug.org>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/arch/ia64/kernel/smp.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/kernel/smp.c~printk-arch_ia64_kernel_smp arch/ia64/kernel/smp.c
--- kj/arch/ia64/kernel/smp.c~printk-arch_ia64_kernel_smp	2005-03-18 20:05:41.000000000 +0100
+++ kj-domen/arch/ia64/kernel/smp.c	2005-03-18 20:05:41.000000000 +0100
@@ -269,7 +269,7 @@ smp_call_function_single (int cpuid, voi
 	int me = get_cpu(); /* prevent preemption and reschedule on another processor */
 
 	if (cpuid = me) {
-		printk("%s: trying to call self\n", __FUNCTION__);
+		printk(KERN_INFO "%s: trying to call self\n", __FUNCTION__);
 		put_cpu();
 		return -EBUSY;
 	}
_
