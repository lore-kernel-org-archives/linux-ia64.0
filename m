From: "Luming Yu" <luming.yu@gmail.com>
Date: Wed, 07 Nov 2007 06:50:33 +0000
Subject: Re: [PATCH] fix typo in per_cpu_offset
Message-Id: <3877989d0711062250g44e5d0ecq1e4b893fa2bad94a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0710230015x1640388aod98cae2fa3fc82c2@mail.gmail.com>
	 <20071030071513.GE5361@verge.net.au>
	 <20071030.003622.265888160.davem@davemloft.net>
	 <20071030085054.GE10635@verge.net.au>
	 <20071107064429.GC3571@verge.net.au>
In-Reply-To: <20071107064429.GC3571@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Arjan van de Ven <arjan@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@osdl.org>

NAK for now.

I'm trying to add lockdep , so please don't delete it until it could
be proved really useless...
Please don't hurry...

On 11/7/07, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Oct 30, 2007 at 05:50:56PM +0900, Simon Horman wrote:
> > On Tue, Oct 30, 2007 at 12:36:22AM -0700, David Miller wrote:
> > > From: Simon Horman <horms@verge.net.au>
> > > Date: Tue, 30 Oct 2007 16:15:13 +0900
> > >
> > > > Though curiuously with my config nothing uses per_cpu_offset()
> > > > (I added a bogus call to produce an error.) Is it actually
> > > > used on ia64?
> > >
> > > It is unused, and in that regard should probably be deleted.
> > >
> > > include/asm-generic/percpu.h defines a seemingly similarly
> > > unused per_cpu_offset() macro define as well
> >
> > It looks like they were both added by "[PATCH] lockdep: add per_cpu_offset()"
> > (a875a69f8b00a38b4f40d9632a4fc71a159f0e0d)
> >
> > Perhaps they were used at that time?
>
> I looked into this a little further:
>
> I'm pretty much convinced that the asm-ia64 version of per_cpu_offset()
> is unused as ia64 doesn't have lockdep. I will send a patch to get rid
> of it. The generic version might be used on mips, sh or arm with
> CONFIG_SMP, as these architectures have lockdep. I did managed to
> produce a compiler error on mips by removing the asm-generic version of
> per_cpu_offset().
>
> --
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
>
>
