From: mita@miraclelinux.com (Akinobu Mita)
Date: Thu, 02 Feb 2006 01:37:11 +0000
Subject: Re: [patch 41/44] make thread_info.flags an unsigned long
Message-Id: <20060202013711.GA7143@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0595DB4D@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0595DB4D@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-ia64@vger.kernel.org, linuxsh-dev@lists.sourceforge.net, Andi Kleen <ak@suse.de>

On Wed, Feb 01, 2006 at 10:17:43AM -0800, Luck, Tony wrote:
>  
> --- 2.6-git.orig/include/asm-ia64/thread_info.h
> +++ 2.6-git/include/asm-ia64/thread_info.h
> @@ -24,7 +24,7 @@
>  struct thread_info {
>  	struct task_struct *task;	/* XXX not really needed, except for dup_task_struct() */
>  	struct exec_domain *exec_domain;/* execution domain */
> -	__u32 flags;			/* thread_info flags (see TIF_*) */
> +	unsigned long flags;		/* thread_info flags (see TIF_*) */
>  	__u32 cpu;			/* current CPU */
>  	mm_segment_t addr_limit;	/* user-level address space limit */
>  	int preempt_count;		/* 0=premptable, <0=BUG; will also serve as bh-counter */
> 
> This leaves a useless hole in the structure.  Tell me again why
> this is a good thing?

This patch stops warning message introduced by the "[patch 25/44]
ia64: use generic bitops" which replaces __set_bit() family to
generic one.

But I realize that I can't replace to generic one for ia64.
Because __set_bit() family are using the pointer to __u32, but
generic __set_bit() family are using the pointer to unsigned long.

So the patch 25/44 is wrong and the change above is unnessesary.
Thanks
