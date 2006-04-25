From: Grant Grundler <iod00d@hp.com>
Date: Tue, 25 Apr 2006 23:20:58 +0000
Subject: Re: I/O read, write implementation questions
Message-Id: <20060425232058.GC27658@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444E2EA6.8000604@bull.net>
In-Reply-To: <444E2EA6.8000604@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 25, 2006 at 05:20:49PM +0200, Zoltan Menyhart wrote:
> David Mosberger-Tang wrote:
> 
> >>Why do not "readb()" ... "writeb()" include "mf.a"-s?
> >
> >Again, acceptance is not normally needed by readX/writeX and mf.a is
> >extremely expensive (on the order of 1,000 cycles).  If you want
> >ordering, you need to use explicit barriers (or rely on the effect of
> >"volatile" in ia64-specific code).

MMIO reads cost between 1000-3000 cycles anyway depending on the
configuration. "mmio_test" on gnumonks.org/svn/mmio_test (roughly)
will help people measure the exact cost.

> Assuming a device driver uses memory mapped I/O, what is the architecture
> independent way to make sure that the I/O reads - writes are accepted ?
> (I cannot use "__ia64_mf_a()".)

I think it depends on your definition of "accepted".
I tried addressing this question before:
    http://iou.parisc-linux.org/porting_zx1/4_4MMIO_Write_Ordering.html

I believe for mmio writes, the section on "Posted MMIO Writes" in
the same paper answers your question.
The CPU will stall for MMIO reads and thus only needs mb() or wmb()
depending on what ordering is required.

> What is the difference between "readb_relaxed()" and "readb()"?
> Were not they defined to provide both strict and weak (relaxed)
> I/O ordering?

This is a hack added for SGI Altix. The "_relaxed()" in this
case refers to PCI ordering rules that could be violated by
SGI HW (and the violation causes no harm). Use google for read_relaxed
(or was it write_relaxed?) discussion between Jesse Barnes
and myself about 2 years ago.

hth,
grant
