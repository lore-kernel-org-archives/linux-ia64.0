From: Grant Grundler <iod00d@hp.com>
Date: Mon, 23 Jun 2003 22:05:49 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105640604429987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 23, 2003 at 01:41:01PM -0700, David Mosberger wrote:
> Well, I'm not a disk person (if it doesn't fit in memory, you don't
> have enough of it! ;-), but the basic assumption is that it is
> worthwhile to spend a few CPU cycles on forming fewer, but larger disk
> requests whenever possible.

Yes - fewer interupts/timers/sleep/wakeup() calls.
Sometimes that also means fewer disk rotations too.

> Intuitively, that certainly makes sense
> to me, though I haven't seen any performance numbers on how much of a
> difference this can make.

It's substantial.
Same thing netperf tries to measure: CPU cost per KB of data transferred.

gsyprf3:~# for i in 2 4 8 16 32 64 128 ; do time sgp_dd if=/dev/sg10 of=/dev/null bpt=$i count 00000 ; done

	real          user       sys
1K	1m45.300s  0m1.120s  0m15.633s
2k	0m55.700s  0m4.399s  0m6.701s
4K	0m31.124s  0m0.830s  0m3.119s
8K	0m19.044s  0m0.511s  0m1.884s
16K	0m19.016s  0m0.175s  0m0.765s
32K	0m19.008s  0m0.089s  0m0.544s
64K	0m19.010s  0m0.050s  0m0.438s

vmstat reported 12% sys for 1k down to <2% for 32K blocks.
Context switches went from ~48K/s to 4130/s.

Oh...sg10 is a HW mirror'd device.
Here's a re-run with a ST336732LC (u320) disk:

	real          user     sys
1K	1m54.822s  0m2.828s  0m10.289s
2K	0m57.704s  0m1.386s  0m5.207s
4K	0m41.239s  0m0.736s  0m2.911s
8K	0m20.284s  0m0.373s  0m1.589s
16K	0m16.924s  0m0.192s  0m0.865s
32K	0m16.900s  0m0.088s  0m0.563s
64K	0m16.873s  0m0.057s  0m0.430s

Not too much different from sg10. ~44k context switches/second down
to ~4700 CS/s. Similar CPU utilization numbers.

> You'd certainly need a disk-heavy workload
> to see any difference.  Perhaps Rohit could try it on TPC-C (once the
> merging is working)?

AFAIK, TPC-C cares more about latency and CPU cycles/IO.
TPC/C is "random" IO.  My example above is sequential IO
but useful to measure the CPU cost of different block sizes
and raw disk throughput.

I'm skeptical TPC/C will see the benefit of block merging,
just the cost of trying to do it. That's why I don't want
to make block merging too smart. The rest of us using buffered
IO (eg file system) and have read-ahead will benefit from block merging.

> The decision has to be split across BIO and I/O MMU: only the
> BIO-level knows what to do if merging _cannot_ take place and
> only the I/O MMU code knows how to map physically discontiguous
> pages linearly into I/O MMU space.

I understand the latter. Not the former.

It looks like blk_recount_segments() is only used to gather
stastics about how many segments are in the transaction.
I tracked back to fs/bio.c to find the consumer of this
information (# of segments) but didn't find it.
Anyone know off hand?

thanks,
grant
