From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Thu, 08 May 2003 17:14:20 +0000
Subject: RE: [Linux-ia64] High fpu register corruption
Message-Id: <marc-linux-ia64-105590723705688@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

The save part in the context switch also needs to be fixed and we will
take a look at this.
Thanks,
Asit


> -----Original Message-----
> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
> Sent: Thursday, May 08, 2003 10:03 AM
> To: Andreas Schwab
> Cc: linux-ia64@linuxia64.org; Chris Mason
> Subject: Re: [Linux-ia64] High fpu register corruption
> 
> >>>>> On Thu, 08 May 2003 16:16:13 +0200, Andreas Schwab
<schwab@suse.de>
> said:
> 
>   Andreas> When a process clears the psr.mfh bit after using the high
>   Andreas> fpu registers and then starts using them again it can
>   Andreas> corrupt the fpu state of another process.  In order for
>   Andreas> this to happen there must be some context switches
>   Andreas> inbetween (thanks to Chris Mason for tracking this down):
> 
> Ah, _now_ it makes sense.  I got a similar bug report yesterday, but
> it claimed the _old_ (2.4.19) context switch was breaking and the
> new one (2.4.20) was fine.  When I looked at the old code, I couldn't
> find anythign wrong with it.
> 
>   Andreas> +	} else if (ia64_get_fpu_owner() != next)
\
>   Andreas> +		ia64_psr(ia64_task_regs(next))->dfh = 1;
\
> 
> I suspect what we really want to do here is something along the lines
> of:
> 
>   Andreas> +	ia64_psr(ia64_task_regs(next))->dfh =
> (ia64_get_fpu_owner() != next);		\
> 
> This expresses the invariant we're after: the next thread has DFH set
> unless it owns the FPH partition.  IIRC, this is what the UP code does
> already.
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

