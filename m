From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 14 May 2006 21:15:55 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64.patch added to -mm tree
Message-Id: <20060514211555.GA25945@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147632661.2551.5.camel@shinybook.infradead.org>
In-Reply-To: <1147632661.2551.5.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, May 14, 2006 at 07:51:00PM +0100, David Woodhouse wrote:
> On Sun, 2006-05-14 at 10:54 -0700, akpm@osdl.org wrote:
> > diff -puN include/asm/gcc_intrin.h~git-hdrcleanup-vs-git-klibc-on-ia64
> > include/asm/gcc_intrin.h
> > ---
> > 25/include/asm/gcc_intrin.h~git-hdrcleanup-vs-git-klibc-on-ia64     Mon May 15 01:33:00 2006
> > +++ 25-akpm/include/asm/gcc_intrin.h    Mon May 15 01:33:00 2006
> > @@ -24,7 +24,9 @@
> >  extern void ia64_bad_param_for_setreg (void);
> >  extern void ia64_bad_param_for_getreg (void);
> >  
> > +#ifdef __KERNEL__
> >  register unsigned long ia64_r13 asm ("r13") __attribute_used__;
> > +#endif 
> 
> There's more than just that in asm-ia64/intrinsics.h that shouldn't be
> visible to userspace. In fact I'm not entirely sure how much of
> intrinsics.h _does_ make sense for userspace at all.
> 
> What does asm-ia64/byteorder.h include it for?

Using byte swizzling instrincts I supposed.  On the other hand asm/byteorder.h
really shouldn't be user-exposed to start with.

