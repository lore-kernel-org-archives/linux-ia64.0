From: Grant Grundler <grundler@parisc-linux.org>
Date: Thu, 31 Jan 2008 05:22:03 +0000
Subject: Re: zx1 PCI DMA
Message-Id: <20080131052203.GA6487@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130163128.GA26457@cse.unsw.EDU.AU>
In-Reply-To: <20080130163128.GA26457@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 30, 2008 at 10:04:17PM -0700, Matthew Wilcox wrote:
> On Thu, Jan 31, 2008 at 03:31:28AM +1100, Matthew Chapman wrote:
> > I'm trying to track down a PCI performance problem - part of my
> > never-ending thesis troubles - and one thing I'm finding is that my HP
> > zx1-based Itaniums are taking surprisingly long to satisfy PCI DMA
> > reads.
> > 
> > On a 66Mhz PCI bus it seems to be taking about 60-75 bus cycles, i.e.
> > ~1000ns, to initiate a read targetting a cache line that was previously
> > owned by a processor.

IIRC ~1000ns is a bit high - expect ~600ns or so on an idle bus.
But on a busy system, I don't think it's excessive.

> >   Even cache lines that have recently been accessed
> > by the PCI device, without being touched by a processor, seem to be
> > taking of the order of 50 bus cycles.

So that's around 800ns. Just means it's going to memory controller.

> > This is a big surprise to me, since I know that zx1 performs really well
> > CPU<->memory (order of 100ns).

Correct. DMA usually has a latency 3-5x higher than the CPU.
CPU is much more latency sensitive to memory than most PCI devices.
It's not surprising chipset designers make this tradeoff.

> > Does anyone know what the achievable DMA latency should be, and what I
> > can tune on the zx1 chipset or PCI card?

1000ns is a bit high but expect ~800ns or less.

> I just had a word with Grant Grundler.  He suggests looking at his OLS
> paper at http://iou.parisc-linux.org/ols_2003/ "DMA Hints on
> IA64/PARISC".

This paper looked at some of the available features from the ZX1 IOMMU.
There are more features in the chip than discussed in that paper and you
should get the Pluto ERS and track down any of the chip designers listed
in that if they still work for HP.

Things to look for are "Read Bus Current" (was disabled becuase of a bug
in Mckinley CPU), PRefetching of "streaming" data (IIRC default is 3
 cachelines), make sure the prefetching isn't thrashing the associative
cache - I think it's only got 16 entries and thus can't have more than
5 streams inflight without thrashing.

hth,
grant

ps thanks willy for adding me to CC - cheers!
