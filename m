From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 09 Dec 2009 18:22:52 +0000
Subject: Re: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <1260382972.5489.1122.camel@laptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
	 <20090828062212.GB11552@elte.hu>
	 <3877989d0912032329u7c05a761wfdd5c7000b43218d@mail.gmail.com>
	 <4BDB13256095B24D9644F65379E604265C12@orsmsx505.amr.corp.intel.com>
	 <3877989d0912041919i458300d7ydce73cf77979dad3@mail.gmail.com>
	 <3877989d0912062156v7ba2a192y726f45b550ba50e@mail.gmail.com>
	 <12c511ca0912071335i1a805c2eudb6ecb8f726f6a80@mail.gmail.com>
	 <3877989d0912080425o4bf9e2beuf573e47930fd707f@mail.gmail.com>
	 <3877989d0912082245m3ee1ea14y3b3c8aca99e9f378@mail.gmail.com>
	 <3877989d0912090052v79fdce6aqb507639143b5d71e@mail.gmail.com>
	 <12c511ca0912091011g1d6308c4if7684adf9b0c5baf@mail.gmail.com>
In-Reply-To: <12c511ca0912091011g1d6308c4if7684adf9b0c5baf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Luming Yu <luming.yu@gmail.com>, Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>

On Wed, 2009-12-09 at 10:11 -0800, Tony Luck wrote:
> On Wed, Dec 9, 2009 at 12:52 AM, Luming Yu <luming.yu@gmail.com> wrote:
> > Commenting out the change make -32 Lockdep kernel boot.
> >
> > Tony, please let me know whether you can reproduce..
> 
> Yes.  Commenting this out makes the system bootable for me.
> 
> > kernel/lockdep.c
> > static int save_trace(struct stack_trace *trace)
> > {
> >        trace->nr_entries = 0;
> >        trace->max_entries = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
> >        trace->entries = stack_trace + nr_stack_trace_entries;
> >
> >        trace->skip = 3;
> >
> >        save_stack_trace(trace);
> > #if 0
> >
> >        /*
> >         * Some daft arches put -1 at the end to indicate its a full trace.
> >         *
> >         * <rant> this is buggy anyway, since it takes a whole extra entry so a
> >         * complete trace that maxes out the entries provided will be reported
> >         * as incomplete, friggin useless </rant>
> >         */
> >        if (trace->entries[trace->nr_entries-1] = ULONG_MAX)
> >                trace->nr_entries--;
> > #endif
> 
> This happens because ia64 save_stack_trace() is currently an empty stub, so it
> doesn't set trace->nr_entries.
> 
> Options:
> 1) Add trace->nr_entries = 1; to ia64 stub.
> 2) Change the generic code to defend against an unexpected failure in
> save_stack_trace()
> 
>        if (trace->nr_entries > 0 &&
>            trace->entries[trace->nr_entries-1] = ULONG_MAX)
>                trace->nr_entries--;
> 3) Delete the code in the "daft"[1] architectures, and drop this hunk
> from the generic code.

I'm thinking 2 and 3 together sound like a plan :-)

