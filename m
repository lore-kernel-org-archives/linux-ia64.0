From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 00:07:50 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601270007.k0R07og20144@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Prarit Bhargava wrote on Thursday, January 26, 2006 3:44 PM
> diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
> --- a/include/asm-ia64/processor.h
> +++ b/include/asm-ia64/processor.h
> @@ -50,7 +50,8 @@
>  #define IA64_THREAD_PM_VALID	(__IA64_UL(1) << 2)	/* performance registers valid? */
>  #define IA64_THREAD_UAC_NOPRINT	(__IA64_UL(1) << 3)	/* don't log unaligned accesses */
>  #define IA64_THREAD_UAC_SIGBUS	(__IA64_UL(1) << 4)	/* generate SIGBUS on unaligned acc. */
> -							/* bit 5 is currently unused */
> +#define IA64_THREAD_MIGRATION	(__IA64_UL(1) << 5)	/* require migration
> +							   sync at ctx sw */
>  #define IA64_THREAD_FPEMU_NOPRINT (__IA64_UL(1) << 6)	/* don't log any fpswa faults */
>  #define IA64_THREAD_FPEMU_SIGFPE  (__IA64_UL(1) << 7)	/* send a SIGFPE for fpswa faults */
>  
> diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
> --- a/include/asm-ia64/system.h
> +++ b/include/asm-ia64/system.h
> @@ -244,6 +244,13 @@ extern void ia64_load_extra (struct task
>  		__ia64_save_fpu((prev)->thread.fph);				\
>  	}									\
>  	__switch_to(prev, next, last);						\
> +	/* "next" in old context is "current" in new context */			\
> +	if (unlikely((current->thread.flags & IA64_THREAD_MIGRATION) &&	       \
> +		     (task_cpu(current) !=				       \
> +		      		      task_thread_info(current)->last_cpu))) { \
> +		platform_migrate(current);				       \
> +		task_thread_info(current)->last_cpu = task_cpu(current);       \
> +	}								       \
>  } while (0)
>  #else
>  # define switch_to(prev,next,last)	__switch_to(prev, next, last)


80-column religious sometime is just pure annoying.  I personally find
this looked worse than having the lines spilled over 80 column, in these
two particular instances.

- Ken

