From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 23 Mar 2007 03:21:29 +0000
Subject: [PATCH][2/2] double stack limit (rfc)
Message-Id: <20070323122129.555a87fd.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: "tony.luck@intel.com" <tony.luck@intel.com>, "dmosberger@gmail.com" <dmosberger@gmail.com>, surinder.kumar@oracle.com, LKML <linux-kernel@vger.kernel.org>

Now, ia64's hard-stack-size (rlimit.max) is sum of register-stack size and
memory-stack size. But soft-stack-size (rlimit.cur) accounitng is not sum..
they are accounted independently. This is inconsistent.

I hear some people says that "When I set stack-size-limit to 32M,
I want to use 32M of memory stack..." and register-stack expansion can
fail because stack is used up by memory-stack.

This patch moves register-stack's base address to lower address.
By this patch, meaning of hard-stack-size can be equal to soft-stack-size and
we can avoid the case "register-backing store cannot be expanded because the
memory stack uses the whole stack".

How about this ?

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.21-rc4/arch/ia64/mm/init.c
=================================--- linux-2.6.21-rc4.orig/arch/ia64/mm/init.c
+++ linux-2.6.21-rc4/arch/ia64/mm/init.c
@@ -152,7 +152,7 @@ inline void
 ia64_set_rbs_bot (void)
 {
 	unsigned long stack_size = current->signal->rlim[RLIMIT_STACK].rlim_max & -16;
-
+	stack_size *= 2;
 	if (stack_size > MAX_USER_STACK_SIZE)
 		stack_size = MAX_USER_STACK_SIZE;
 	current->thread.rbs_bot = PAGE_ALIGN(current->mm->start_stack - stack_size);

