From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 31 Jul 2007 08:38:48 +0000
Subject: Re: [PATCH] flush icache before set_pte take6. [4/4] optimization
Message-Id: <46AEF518.4000002@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>	 <20070731114155.5785123c.kamezawa.hiroyu@jp.fujitsu.com> <ed5aea430707302115h484620f1le51fc054436b273a@mail.gmail.com>
In-Reply-To: <ed5aea430707302115h484620f1le51fc054436b273a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <dmosberger@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

David Mosberger-Tang wrote:
> This seems crazy to me.  Flushing should occur according to the
> *architecture*, not model-by-model.  Even if we happen to get "lucky"
> on pre-Montecito CPUs, that doesn't justify such ugly hacks.  Or you
> really want to debug this *again* come next CPU?
> 
>   --david

O.K. let's say we flush by default: the global flag is set.

We can have a (short) list of the CPU models which do not require
this flush.

If all of the CPUs are on the list then clear the global flag. And:

static inline void sync_icache_dcache(pte_t pte) {
       if (pte_exec(pte) && global_flag)
               __sync_icache_dcache(pte);
}

Thanks,

Zoltan
