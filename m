From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 26 Apr 2006 01:19:13 +0000
Subject: Re: [PATCH 1/1] ia64: enable dumps to capture second page of kernel
Message-Id: <444ECA91.4020207@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060425154748.GA29493@sgi.com>
In-Reply-To: <20060425154748.GA29493@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cliff Wickman wrote:

>In SLES10 (2.6.16) crash dumping (in my experience, LKCD) is unable to
>capture the second page of the 2-page task/stack allocation.
>This is particularly troublesome for dump analysis, as the stack traceback
>cannot be done.
>  (A similar convention is probably needed throughout the kernel to make
>   kernel multi-page allocations detectable for dumping)
>
>Multi-page kernel allocations are represented by the single page structure
>associated with the first page of the allocation.  The page structures
>associated with the other pages are unintialized.
>
>If the dumper is selecting only kernel pages it has no way to identify
>any but the first page of the allocation.
>
>The fix is to make the task/stack allocation a compound page.
>
>Diffed against 2.6.16
>
>Signed-off-by: Cliff Wickman <cpw@sgi.com>
>---
>
>---
> include/asm-ia64/thread_info.h |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>Index: linux/include/asm-ia64/thread_info.h
>=================================>--- linux.orig/include/asm-ia64/thread_info.h
>+++ linux/include/asm-ia64/thread_info.h
>@@ -74,7 +74,7 @@ struct thread_info {
> #define end_of_stack(p) (unsigned long *)((void *)(p) + IA64_RBS_OFFSET)
> 
> #define __HAVE_ARCH_TASK_STRUCT_ALLOCATOR
>-#define alloc_task_struct()	((task_t *)__get_free_pages(GFP_KERNEL, KERNEL_STACK_SIZE_ORDER))
>+#define alloc_task_struct()	((task_t *)__get_free_pages(GFP_KERNEL | __GFP_COMP, KERNEL_STACK_SIZE_ORDER))
> #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
> 
> #endif /* !__ASSEMBLY */
>
>---------
>
>Nick,
>
>  You had copied me on a reply on this subject earlier:
>    Date: Sat, 22 Apr 2006 13:56:12 +1000
>    From: Nick Piggin <nickpiggin@yahoo.com.au>
>    Yeah, we're moving toward compound pages for all these types of things
>    (including nommu). So making those pages compound pages should be the
>    right thing to do.
>
>  Still agree?
>

Does the dumper actually _crash_ without this patch? Or does it have some
page_count test that means it doesn't even attempt to take a ref to the 2nd
page?

Either way, I don't think your patch is a problem. If it works, I think it
should go in. Maybe a little comment there would be helpful.

Thanks,
Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 
