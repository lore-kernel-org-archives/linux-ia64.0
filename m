From: domen@coderock.org
Date: Mon, 20 Jun 2005 21:49:43 +0000
Subject: [patch 1/1] printk : arch/ia64/kernel/smp.c
Message-Id: <20050620214942.822812000@nd47.coderock.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050319131906.E934A1F245@trashy.coderock.org>
In-Reply-To: <20050319131906.E934A1F245@trashy.coderock.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Christophe Lucas <clucas@rotomalug.org>



printk() calls should include appropriate KERN_* constant.

Signed-off-by: Christophe Lucas <clucas@rotomalug.org>
Signed-off-by: Domen Puncer <domen@coderock.org>
---
 smp.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: quilt/arch/ia64/kernel/smp.c
=================================--- quilt.orig/arch/ia64/kernel/smp.c
+++ quilt/arch/ia64/kernel/smp.c
@@ -269,7 +269,7 @@ smp_call_function_single (int cpuid, voi
 	int me = get_cpu(); /* prevent preemption and reschedule on another processor */
 
 	if (cpuid = me) {
-		printk("%s: trying to call self\n", __FUNCTION__);
+		printk(KERN_INFO "%s: trying to call self\n", __FUNCTION__);
 		put_cpu();
 		return -EBUSY;
 	}

--
