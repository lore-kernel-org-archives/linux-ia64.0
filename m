From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 26 Apr 2006 15:48:03 +0000
Subject: Re: I/O read, write implementation questions
Message-Id: <20060426102724.R18889@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444E2EA6.8000604@bull.net>
In-Reply-To: <444E2EA6.8000604@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 25 Apr 2006, Grant Grundler wrote:

> On Tue, Apr 25, 2006 at 05:20:49PM +0200, Zoltan Menyhart wrote:

> > Assuming a device driver uses memory mapped I/O, what is the architecture
> > independent way to make sure that the I/O reads - writes are accepted ?
> > (I cannot use "__ia64_mf_a()".)
> 
> I think it depends on your definition of "accepted".
> I tried addressing this question before:
>     http://iou.parisc-linux.org/porting_zx1/4_4MMIO_Write_Ordering.html
> 
> I believe for mmio writes, the section on "Posted MMIO Writes" in
> the same paper answers your question.
> The CPU will stall for MMIO reads and thus only needs mb() or wmb()
> depending on what ordering is required.

Note that wmb() is not sufficient for writes, at least on SGI Altix.
wmb() ensures that the write has issued from the processor, however
it does not ensure that the I/O device itself has seen the write.
The mmiowb() is the appropriate call to ensure that the write has
been seen.

Interested parties may want to read further for a description of
the Altix IO write ordering issues... everyone else can move along. :)

On Altix, an IO write may be cached by the CPU's local Shub ASIC
until another agent on the NUMAlink network indicates that the write
has been accepted.  This cacheing is necessary in order to handle
retries, network congestion, and other such conditions.  Shub will
guarantee the ordering of writes from the CPUs locally attached to it
(i.e. a single NUMA node).

Thus, wmb() only ensures that the Shub ASIC has seen the write, not
that the target device has seen the write.  If you can be sure that
all writes plus the next read (which will stall in the Shub until all
prior writes are accepted) to that device are all issued from a single
CPU, this can be sufficient to guarantee IO write ordering.

However, if you cannot guarantee that all IO writes to the device and
the next read will be issued from a single CPU (actually a single Shub),
then wmb() is insufficient, as seperate Shubs do not guarantee any
particular IO ordering with respect to one another.  In this case, an
mmiowb() call will ensure that the IO write has been accepted by the
target IO controller (typically a PCI bridge ASIC of some flavor).

For IA64 non-SN, mmiowb() is simply a wmb().  For SN, we poll a register
in the Shub ASIC which indicates the number of outstanding IO writes
until it indicates all writes have been accepted.  I can't speak to
the mmiowb() implementation outside of IA64, however for simpler
architectures such as PCs, I believe a wmb() is likely sufficient.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
