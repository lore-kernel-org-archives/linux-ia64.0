From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 27 Feb 2004 21:27:40 +0000
Subject: RE: [Patch] speed up interrupt handling
Message-Id: <16447.46668.692114.578048@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Fri, 27 Feb 2004 18:44:38 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:
>>>>> "Scott" = Scott Feldman <Feldman> writes:

>>>> Is this related to NAPI?

>>>> I'll assume "the gigabit" card is e1000:

Peter> Nope, DP83820.  I'm benchmarking a driver that runs in
Peter> userspace against the in-kernel driver; both benefit from the
Peter> interrupt speedup.

David> So why is irq enabling/disabling on the critical path for this
David> driver?

Because IRQs are disabled for every hardware interrupt, and enabled after each
interrupt returns.  So the latency between hardware interrupt and the
driver seeing the interrupt *was* (prepatch) around 5 microseconds;
minimum latency between interrupts was around 10 microseconds.
This is time on a busy system to run out of receive buffers (you can
get a new packet every 640ns with minimum-sized packets, and it takes
time to process each packet)

With the patch minimum time between interrupts should drop to around 2us,
but I need to measure it again.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
