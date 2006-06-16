From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 16 Jun 2006 09:14:52 +0000
Subject: Re: light weight counters: race free through local_t?
Message-Id: <4492768C.1010703@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0606092212200.4875@schroedinger.engr.sgi.com> <449033B0.1020206@bull.net> <Pine.LNX.4.64.0606140928500.4030@schroedinger.engr.sgi.com> <44915110.2050100@bull.net> <Pine.LNX.4.64.0606150855410.9137@schroedinger.engr.sgi.com> <44918EE5.2060302@bull.net> <Pine.LNX.4.64.0606151110100.9618@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606151110100.9618@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Let's put it in another way:
Do the statistics need to be absolutely precise?
I guess they do not.
By the time you can display them, they have already been changed.

Let's take an example:

zone_statistics(struct zonelist *zonelist, struct zone *z)
{
...
//	local_irq_save(flags);		// No IRQ lock out
	cpu = smp_processor_id();	// Can become another CPU
	p = &z->pageset[cpu];		// Can count for someone else
	if (pg = orig) {
		stat_incr(&z->pageset[cpu].numa_hit);	// Unsafe
	} else {
...
//	local_irq_restore(flags);
}

Where "stat_incr()" is arch. dependent and possibly unsafe routine.

For IA64:

// Unsafe statistics
static inline void stat_incr(int *addr){
        int tmp;

	// Obtain immediately the cache line exclusivity, do not touch L1
        asm volatile ("ld4.bias.nt1 %0=[%1]" : "=r"(tmp) : "r" (addr));
        tmp++;
        asm volatile ("st4 [%1] = %0" :: "r"(tmp), "r"(addr) : "memory");
}

It takes 10 clock cycles.

Regards,

Zoltan
