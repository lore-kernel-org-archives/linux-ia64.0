From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 20 Mar 2006 14:22:07 +0000
Subject: Re: [PATCH] Add SA_PERCPU_IRQ flag support
Message-Id: <20060320142207.GG8980@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317003114.GA1735@sgi.com> <20060317152645.52112021.akpm@osdl.org> <20060318014900.65889f69.akpm@osdl.org> <20060320141747.GA27114@sgi.com>
In-Reply-To: <20060320141747.GA27114@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hch@infradead.org, clameter@sgi.com, jes@sgi.com

On Mon, Mar 20, 2006 at 08:17:47AM -0600, Dimitri Sivanich wrote:
> On Sat, Mar 18, 2006 at 01:49:00AM -0800, Andrew Morton wrote:
> > Andrew Morton <akpm@osdl.org> wrote:
> > >
> > > +#ifdef ARCH_HAS_IRQ_PER_CPU
> > >  +	if (new->flags & SA_PERCPU_IRQ)
> > >  +		desc->status |= IRQ_PER_CPU;
> > >  +#endif
> > 
> > OK, five architectures define ARCH_HAS_IRQ_PER_CPU but only one of them
> > defines SA_PERCPU_IRQ.    Giving up.
> 
> Could we do the following (at least for now)?:
> 
> +#if defined(ARCH_HAS_IRQ_PER_CPU) && defined(SA_PERCPU_IRQ)
> +	if (new->flags & SA_PERCPU_IRQ)
> +		desc->status |= IRQ_PER_CPU;
> +#endif

Why not just

#ifdef SA_PERCPU_IRQ
	if (new->flags & SA_PERCPU_IRQ)
		desc->status |= IRQ_PER_CPU;
#endif
