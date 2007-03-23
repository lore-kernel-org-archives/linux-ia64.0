From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 23 Mar 2007 03:17:46 +0000
Subject: [PATCH][ia64][1/2] bugfix stack layout upside-down
Message-Id: <20070323121746.4925a639.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: "tony.luck@intel.com" <tony.luck@intel.com>, dmosberger@gmail.com, surinder.kumar@oracle.com, LKML <linux-kernel@vger.kernel.org>

ia64 expects following vm layout
=
[register-stack]
[memory-stack]
=
But, when ulimit -s is used  and stack-base-address-randomization works,
vm layout is sometimes following.
=
[memory-stack]
[register-stack]
=

If this happens,  register-stack cannot be expanded.

This patch fixes this bug by adjusting register-stack.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.21-rc4/arch/ia64/mm/init.c
=================================--- linux-2.6.21-rc4.orig/arch/ia64/mm/init.c
+++ linux-2.6.21-rc4/arch/ia64/mm/init.c
@@ -155,7 +155,7 @@ ia64_set_rbs_bot (void)
 
 	if (stack_size > MAX_USER_STACK_SIZE)
 		stack_size = MAX_USER_STACK_SIZE;
-	current->thread.rbs_bot = STACK_TOP - stack_size;
+	current->thread.rbs_bot = PAGE_ALIGN(current->mm->start_stack - stack_size);
 }
 
 /*

