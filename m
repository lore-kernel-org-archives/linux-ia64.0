From: Paul Mundt <lethal@linux-sh.org>
Date: Wed, 30 Aug 2006 10:20:10 +0000
Subject: Re: [RFC][PATCH 02/10] conditionally define generic get_order() (ARCH_HAS_GET_ORDER)
Message-Id: <20060830102010.GB10629@localhost.internal.ocgnet.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829201934.47E63D1F@localhost.localdomain> <20060829201935.9954D4F2@localhost.localdomain>
In-Reply-To: <20060829201935.9954D4F2@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, rdunlap@xenotime.net

On Tue, Aug 29, 2006 at 01:19:35PM -0700, Dave Hansen wrote:
> This is very greppable.  If you grep and see foo() showing up in
> asm-generic/foo.h, it is *obvious* that it is a generic version.  If you
> see another version in asm-i386/foo.h, it is also obvious that i386 has
> (or can) override the generic one.
> 
[snip]
> So, is _this_ patch disgusting?

The only problem I see with sticking this in mm/Kconfig is that it's not
immediately apparent from poking through asm-<arch> what is specially
provided by the architecture to override the generic fallback (though
some might even consider this a benefit). One has to first find the
symbol of interest in asm-generic, figure out the config option guarding
it, and then grep the rest of the Kconfig hierarchy to figure out which
architectures actually use the thing, or stick purely with symbol
lookup.

From a .config point of view, this is certainly far more readable
compared to asm-<arch> lookups, though I'm not entirely convinced that
this really buys us much in the greppability or reduced complexity
department.

If the new trend is to forego any future HAVE_ARCH_xxx definitions, then
I suppose this is the way to go.
