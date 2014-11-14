From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 14 Nov 2014 16:47:19 +0000
Subject: Re: [PATCH 09/11] x86, mpx: on-demand kernel allocation of bounds tables
Message-Id: <alpine.DEB.2.11.1411141743230.3935@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <20141114151816.F56A3072@viggo.jf.intel.com> <20141114151829.AD4310DE@viggo.jf.intel.com>
In-Reply-To: <20141114151829.AD4310DE@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <dave@sr71.net>
Cc: hpa@zytor.com, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, dave.hansen@linux.intel.com

On Fri, 14 Nov 2014, Dave Hansen wrote:
>  * move mm init-time #ifdef to mpx.h

> +static inline void arch_bprm_mm_init(struct mm_struct *mm,
> +		struct vm_area_struct *vma)
> +{
> +	mpx_mm_init(mm);
> +#ifdef CONFIG_X86_INTEL_MPX
> +	mm->bd_addr = MPX_INVALID_BOUNDS_DIR;
> +#endif

So we have a double init now :)

> +++ b/arch/x86/kernel/setup.c	2014-11-14 07:06:23.941684394 -0800
> @@ -959,6 +959,13 @@ void __init setup_arch(char **cmdline_p)
>  	init_mm.end_code = (unsigned long) _etext;
>  	init_mm.end_data = (unsigned long) _edata;
>  	init_mm.brk = _brk_end;
> +#ifdef CONFIG_X86_INTEL_MPX
> +	/*
> +	 * NULL is theoretically a valid place to put the bounds
> +	 * directory, so point this at an invalid address.
> +	 */
> +	init_mm.bd_addr = MPX_INVALID_BOUNDS_DIR;
> +#endif

And this one wants mpx_mm_init() replacement as well.
  
Thanks,

	tglx
