From: david mosberger <dmosberger@gmail.com>
Date: Fri, 29 Jul 2005 01:58:36 +0000
Subject: Re: Change ia64 prefetch to use lfetch.fault
Message-Id: <ed5aea430507281858377ea50a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507282153.j6SLr0g01028@unix-os.sc.intel.com>
In-Reply-To: <200507282153.j6SLr0g01028@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No, it doesn't --- it actually hurt performance last time I measured
it.  Basically, Linux uses prefetch() too often with bad/NULL
pointers, IIRC.  Check my earlier mails where I fixed the IVT code to
properly handle lfetch.fault (from a couple of months ago).

  --david

On 7/28/05, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> I don't remember whether this has been discussed earlier, won't
> it make sense to use the fault variant of lfetch for prefetch()
> and prefetchw()?  After all, the caller has high confidence that
> the cache line will be used in the future.
> 
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> --- linux-2.6.12/include/asm-ia64/processor.h.orig      2005-07-28 14:46:26.629519713 -0700
> +++ linux-2.6.12/include/asm-ia64/processor.h   2005-07-28 14:48:17.037721485 -0700
> @@ -682,13 +682,13 @@ ia64_imva (void *addr)
>  static inline void
>  prefetch (const void *x)
>  {
> -        ia64_lfetch(ia64_lfhint_none, x);
> +       ia64_lfetch_fault(ia64_lfhint_none, x);
>  }
> 
>  static inline void
>  prefetchw (const void *x)
>  {
> -       ia64_lfetch_excl(ia64_lfhint_none, x);
> +       ia64_lfetch_fault_excl(ia64_lfhint_none, x);
>  }
> 
>  #define spin_lock_prefetch(x)  prefetchw(x)
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
