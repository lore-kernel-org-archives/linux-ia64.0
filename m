From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Wed, 30 Jan 2008 16:31:28 +0000
Subject: zx1 PCI DMA
Message-Id: <20080130163128.GA26457@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi folks,

I'm trying to track down a PCI performance problem - part of my
never-ending thesis troubles - and one thing I'm finding is that my HP
zx1-based Itaniums are taking surprisingly long to satisfy PCI DMA
reads.

On a 66Mhz PCI bus it seems to be taking about 60-75 bus cycles, i.e.
~1000ns, to initiate a read targetting a cache line that was previously
owned by a processor.  Even cache lines that have recently been accessed
by the PCI device, without being touched by a processor, seem to be
taking of the order of 50 bus cycles.

This is a big surprise to me, since I know that zx1 performs really well
CPU<->memory (order of 100ns).

Does anyone know what the achievable DMA latency should be, and what I
can tune on the zx1 chipset or PCI card?

Thanks,
Matt

