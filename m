From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Feb 2007 18:00:15 +0000
Subject: RE: [PATCH] Hook up getcpu system call for IA64
Message-Id: <617E1C2C70743745A92448908E030B2A0117C714@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070206000757.GA32026@linux-os.sc.intel.com>
In-Reply-To: <20070206000757.GA32026@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Andi Kleen used to lecture me every so often why it is important to
> have fast vgetcpu on x86-64 (I don't think ia64 is excluded from
> that).  His lecture is also all over the lkml mailing list.

I dug though that thread ... it isn't ever explicitly stated, but
it does appear that the intent is that a NUMA aware application
would use a malloc() library that called getcpu() on every memory
allocation.  If that is the usage model, then I'll agree that
getcpu() does need to be fast.

One possible way to achieve that on ia64 would be to make use of the
fact that the ar.k* registers are readable by applications, and
specifically ar.k3 contains a per-cpu value (physical address of the
kernel percpu area).  *IF* (and that is a BIG IF) we were to guarantee
to maintain ar.k3 as a per-cpu unique value, then we could implement
a very fast (even faster than fsys.S) getcpu() as:

#define __NR_getcpu                     1304

int
getcpu(unsigned *cpup, unsigned *nodep, void *cachep)
{
	static unsigned cpu = ~0, node = ~0;
	static unsigned long save_ar_k3;
	unsigned long ar_k3;

	asm volatile ("mov %0=ar.k3" : "=r" (ar_k3));
	if (cpu = ~0 || ar_k3 != save_ar_k3) {
		if (syscall(__NR_getcpu, &cpu, &node, 0) = -1)
			return -1;
		save_ar_k3 = ar_k3;
	}
	*cpup = cpu;
	*nodep = node;

	return 0;
}


Too ugly for words?  Or worth serious consideration?

-Tony
