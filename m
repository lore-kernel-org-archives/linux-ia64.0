From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 29 Mar 2006 07:16:12 +0000
Subject: RE: Prefetch mmap_sem in ia64_do_page_fault()
Message-Id: <Pine.LNX.4.64.0603282311150.20328@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 28 Mar 2006, Chen, Kenneth W wrote:

> > +	/* mmap_sem is performance critical.... */
> > +	prefetchw(&mm->mmap_sem);
> > +
> 
> I would say push that a couple of lines down after checking !mm
> 
>         if (in_atomic() || !mm)
>                 goto no_context;

I initially also thought that would be better.
 
> If you insist on prefetching mmap_sem at the very beginning of the
> function, then use speculative load, it will "nat" right away with
> null pointer without generating any exception at all.  It is super
> fast because of nat page.

I saw David Mosberger's patch from last year

http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;hE8f935527372499b714bf4f8e646a68bb0f52e3

and it seems that he implemented fast handling of these NULL cases?

mm = NULL is very rare so I think we can try to prefetch as 
early as possible.
