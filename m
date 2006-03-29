From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 07:31:42 +0000
Subject: RE: Prefetch mmap_sem in ia64_do_page_fault()
Message-Id: <200603290730.k2T7Uug04138@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Tuesday, March 28, 2006 11:16 PM
> > If you insist on prefetching mmap_sem at the very beginning of the
> > function, then use speculative load, it will "nat" right away with
> > null pointer without generating any exception at all.  It is super
> > fast because of nat page.
> 
> I saw David Mosberger's patch from last year
> 
> http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;hE8f935527372499b714bf4f8e646a68bb0f52e3
> 
> and it seems that he implemented fast handling of these NULL cases?

I know about that patch and I'm referring in the context of that commit:

ld8.s r1=[r0]      - immediate nat generation, no fault
lfetch.fault [r0]  - generate nat page consumption because lfetch is not
                     considered as a speculative access.

The nat page consumption fault handler should be rather quick, though cpu
still have to fault into the handler, muck around with ipsr.ed bit and
then rfi.  What I'm saying is there is an even *faster* way of doing
prefetch.

> mm = NULL is very rare so I think we can try to prefetch as 
> early as possible.

Yeah, sure. Looks good!

- Ken
