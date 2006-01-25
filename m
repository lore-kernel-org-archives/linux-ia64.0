From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Jan 2006 09:24:54 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601250924.k0P9Otg22689@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Tuesday, January 24, 2006 3:29 PM
> Take 4.  Moved "really migrated?" check as late as possible in
> __switch_task(), and moved thread_info last_cpu field closer to
> flags and cpu fields.  Some nomenclature changes as well.

diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
>  #define __switch_to(prev,next,last) do {							 \
>  	if (IA64_HAS_EXTRA_STATE(prev))								 \
>  		ia64_save_extra(prev);								 \
>  	if (IA64_HAS_EXTRA_STATE(next))								 \
>  		ia64_load_extra(next);								 \
>  	ia64_psr(task_pt_regs(next))->dfh = !ia64_is_local_fpu_owner(next);			 \
> +	arch_migrate(next);									 \
>  	(last) = ia64_switch_to((next));							 \
>  } while (0)

Thought everyone agreed to call the sync function with the new task context,
(after ia64_switch_to). Something changed which made you changed your mind?

 
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
> @@ -46,6 +47,7 @@ struct thread_info {
>  	.exec_domain	= &default_exec_domain,	\
>  	.flags		= 0,			\
>  	.cpu		= 0,			\
> +	.last_cpu	= 0,			\
>  	.addr_limit	= KERNEL_DS,		\
>  	.preempt_count	= 0,			\
>  	.restart_block = {			\

Looked spurious, init_task has static initializer, which will have zero
initial value automatically.

- Ken

