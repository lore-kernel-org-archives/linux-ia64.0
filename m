From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 30 Mar 2006 08:43:22 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <442B9A2A.7000306@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <65953E8166311641A685BDF71D865826A23D40@cacexc12.americas.cpqcorp.net> <Pine.LNX.4.64.0603291529160.26011@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603291529160.26011@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> Hmmm... Maybe we therefore need to add a mode to each bit operation in 
> the kernel?
> 
> With that we can also get rid of the __* version of bitops.
> 
> Possible modes are
> 
> NON_ATOMIC 	Do not perform any atomic ops at all.
> 
> ATOMIC		Atomic but unordered
> 
> ACQUIRE		Atomic with acquire semantics (or lock semantics)
> 
> RELEASE 	Atomic with release semantics (or unlock semantics)
> 
> FENCE		Atomic with full fence.
> 
> This would require another bitops overhaul.
> 
> Maybe we can preserve the existing code with bitops like __* mapped to 
> *(..., NON_ATOMIC) and * mapped to *(..., FENCE) and the gradually fix the 
> rest of the kernel.

Form semantical point of view, the forms:

	bit_foo(..., mode)
and
	bit_foo_mode(...)

are equivalent.

However, I do not think your implementation would be efficient due to
selecting the ordering mode at run time:

> +	switch (mode) {
> +	case MODE_NONE :
> +	case MODE_ACQUIRE :
> +		return cmpxchg_acq(m, old, new);
> +	case MODE_FENCE :
> +		smp_mb();
> +		/* Fall through */
> +	case MODE_RELEASE :
> +		return cmpxchg_rel(m, old, new);

> +	if (mode = ORDER_NON_ATOMIC) {
> +		*m |= bit;
> +		return;
> +	}

etc.

In addition, we may want to inline these primitives...

A compile-time selection of the appropriate code sequence would help.

Thanks,

Zoltan
