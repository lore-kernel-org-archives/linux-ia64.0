From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 31 Jul 2007 10:17:49 +0000
Subject: Re: [PATCH] flush icache before set_pte take6. [4/4] optimization
Message-Id: <20070731191749.0709c56e.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
	<20070731114155.5785123c.kamezawa.hiroyu@jp.fujitsu.com>
	<ed5aea430707302115h484620f1le51fc054436b273a@mail.gmail.com>
	<46AEF518.4000002@bull.net>
In-Reply-To: <46AEF518.4000002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: David Mosberger-Tang <dmosberger@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

On Tue, 31 Jul 2007 10:38:48 +0200
Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> David Mosberger-Tang wrote:
> > This seems crazy to me.  Flushing should occur according to the
> > *architecture*, not model-by-model.  Even if we happen to get "lucky"
> > on pre-Montecito CPUs, that doesn't justify such ugly hacks.  Or you
> > really want to debug this *again* come next CPU?
> > 
> >   --david
> 
> O.K. let's say we flush by default: the global flag is set.
> 
> We can have a (short) list of the CPU models which do not require
> this flush.
> 
> If all of the CPUs are on the list then clear the global flag. And:
> 
> static inline void sync_icache_dcache(pte_t pte) {
>        if (pte_exec(pte) && global_flag)
>                __sync_icache_dcache(pte);
> }
> 

Could we discuss this in other thread as "optimization for some cpus" and
push bug-fix patches first ?

If take5 or part of take6(patch 1,2) are not acceptable, I'll continue this
work on -rc2.

Thanks,
-Kame

