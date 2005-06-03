From: Andrew Morton <akpm@osdl.org>
Date: Fri, 03 Jun 2005 07:22:10 +0000
Subject: Re: periodically-drain-non-local-pagesets-fix.patch added to -mm
Message-Id: <20050603002210.3c548f4a.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050602231057.580dcaa3.akpm@osdl.org>
In-Reply-To: <20050602231057.580dcaa3.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> wrote:
>
> Does this fix the problem?  Compiled but not tested.
> 
>  Index: linux/include/asm-ia64/processor.h
>  =================================>  --- linux.orig/include/asm-ia64/processor.h	2005-06-03 13:05:48.421839027 +1000
>  +++ linux/include/asm-ia64/processor.h	2005-06-03 17:10:43.911784989 +1000
>  @@ -407,15 +407,18 @@ extern void ia64_setreg_unknown_kr (void
>   #define ia64_is_local_fpu_owner(t)								\
>   ({												\
>   	struct task_struct *__ia64_islfo_task = (t);						\
>  -	(__ia64_islfo_task->thread.last_fph_cpu = smp_processor_id()				\
>  +	int ret = (__ia64_islfo_task->thread.last_fph_cpu = get_cpu()				\
>   	 && __ia64_islfo_task = (struct task_struct *) ia64_get_kr(IA64_KR_FPU_OWNER));	\
>  +	put_cpu();										\
>  +	ret;											\
>   })
>   
>   /* Mark task T as owning the fph partition of the CPU we're running on. */
>   #define ia64_set_local_fpu_owner(t) do {						\
>   	struct task_struct *__ia64_slfo_task = (t);					\
>  -	__ia64_slfo_task->thread.last_fph_cpu = smp_processor_id();			\
>  +	__ia64_slfo_task->thread.last_fph_cpu = get_cpu();				\
>   	ia64_set_kr(IA64_KR_FPU_OWNER, (unsigned long) __ia64_slfo_task);		\
>  +	put_cpu();									\
>   } while (0)
>   
>   /* Mark the fph partition of task T as being invalid on all CPUs.  */

Well it'll make the warning go away but I think there's a more fundamental
problem, in that:

	get_cpu();
	cond = something_which_uses_smp_processor_id();
	put_cpu();

	/* `cond' can become false at any time from here */

