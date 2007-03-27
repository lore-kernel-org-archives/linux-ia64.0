From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Mar 2007 22:32:16 +0000
Subject: RE: [PATCH] - Optional method to purge the TLB on SN systems
Message-Id: <617E1C2C70743745A92448908E030B2A0148393E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327193925.GA8615@sgi.com>
In-Reply-To: <20070327193925.GA8615@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> FWIW, slab.c has a "struct array_cache *new[NR_CPUS]" on the
> stack.

I don't think so.  That line is part of the "struct ccupdate_struct"
definition.  We only declare a pointer to one of those on the stack.

> Also, net/core/utils.c has "unsigned long seed[NR_CPUS]".

I don't see this one either (in Linus 2.6.21-rc5). Looking at
the history Suresh Siddha zapped it last August specifically
because of worries about stack overflow on 1024 cpu systems.

I do see:
kernel/sched.c: 	int ints[NR_CPUS], i;

> I'm only adding 1/4 as much space. Can I get away with it or
> should I allocate a node-local chunk of memory & keep a pointer to
> it in per-cpu data?

Debugging kernel stack overflow is no fun at all, so you might
want to take the better-safe-than-sorry approach here.

-Tony
