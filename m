From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 28 Jul 2005 09:19:01 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050728091901.GA26419@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <10613.1122538148@kao2.melbourne.sgi.com> <42E897FD.6060506@yahoo.com.au> <20050728083544.GA22740@elte.hu> <42E89BE6.6040304@yahoo.com.au> <20050728091638.GA25846@elte.hu>
In-Reply-To: <20050728091638.GA25846@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> next->mm we might want to prefetch, but it's probably not worth it 
> because we are referencing it too soon, in context_switch(). (while 
> the kernel stack itself wont be referenced until the full 
> context-switch is done) But might be worth trying - but even then, it 
> should be done from the generic code, like the thread_info and 
> kernel-stack prefetching.

the patch below adds next->mm prefetching too, ontop of the previous 
patch.

	Ingo

------

cache-prefetch next->mm too.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

 kernel/sched.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c
+++ linux/kernel/sched.c
@@ -2866,10 +2866,11 @@ go_idle:
 
 	/*
 	 * Cache-prefetch crutial memory areas of the next task,
-	 * its thread_info and its kernel stack:
+	 * its thread_info, its kernel stack and mm:
 	 */
 	prefetch(next->thread_info);
 	prefetch(kernel_stack(next));
+	prefetch(next->mm);
 
 	if (!rt_task(next) && next->activated > 0) {
 		unsigned long long delta = now - next->timestamp;
