From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Jun 2005 17:40:56 +0000
Subject: Re: [PATCH 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <17064.32552.507932.62892@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com>
	<42A83CF2.90304@jp.fujitsu.com>
In-Reply-To: <42A83CF2.90304@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Hidetoshi,

>>>>> On Thu, 09 Jun 2005 21:58:26 +0900, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> said:

  Hidetoshi> +/*
  Hidetoshi> + * Some I/O bridges may poison the data read, instead of
  Hidetoshi> + * signaling a BERR.  The consummation of poisoned data
  Hidetoshi> + * triggers a local, imprecise MCA.
  Hidetoshi> + * Note that the read operation by itself does not consume
  Hidetoshi> + * the bad data, you have to do something with it, e.g.:
  Hidetoshi> + *
  Hidetoshi> + *	ld.8	r9=[r10];;	// r10 = I/O address
  Hidetoshi> + *	add.8	r8=r9,r9;;	// fake operation
  Hidetoshi> + */
  Hidetoshi> +#define ia64_poison_check(val)					\
  Hidetoshi> +{	register unsigned long gr8 asm("r8");			\
  Hidetoshi> +	asm volatile ("add %0=%1,r0" : "=r"(gr8) : "r"(val)); }
  Hidetoshi> +
  Hidetoshi> #endif /* CONFIG_IOMAP_CHECK  */

I have only looked that this briefly and I didn't see off hand where you get
the "r9=[r10]" sequence from --- I hope you're not relying on the compiler
happening to generate this sequence!

More importantly: please avoid inline "asm" and use the intrinsics
defined by gcc_intrin.h instead (if you need something new, we can add
that), but I think ia64_getreg() will do much of what you want already.

Thanks,

	--david

