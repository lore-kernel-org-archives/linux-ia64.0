From: Linus Torvalds <torvalds@osdl.org>
Date: Tue, 26 Oct 2004 15:21:15 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <Pine.LNX.4.58.0410260807080.28839@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
 <200410251048.48249.bjorn.helgaas@hp.com> <16766.360.725296.4208@napali.hpl.hp.com>
In-Reply-To: <16766.360.725296.4208@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org



On Tue, 26 Oct 2004, David Mosberger wrote:
> 
>   Bjorn> I heard a rumor that ioreadX() on PIO cookies is supposed to
>   Bjorn> have looser semantics than inX() on the port, so we might be
>   Bjorn> able to get away without the memory fence in inb().  But I
>   Bjorn> can't substantiate that, so this keeps the generic behavior
>   Bjorn> of ioreadX() and inX() having identical semantics for PIO.
> 
> Can somebody confirm?  Dropping the mf.a from ioreadX() for I/O port
> accesses would save lots of cycles.

My personal opinion is (but I don't know that everybody will buy into
this) that the _CPU_ serialization of "io_read/io_write()" has to be
independent of whether the argument points to an IO port or memory-mapped
IO.

That's simply because I believe that we should encourage implementations
to be able to have a straight-line path in the accessor functions if the
hardware just supports it (ie there should be no need to check the type at
run-time unless the hardware _forces_ that check on you due to the
ioremap() phase not being able to do everything once-and-for-all).

So historically, on x86, an IO port access would be totally synchronous,
in that a outb() will actually _wait_ for the out to hit the bus. Quite
frankly, I don't think most other architectures ever implemented this even
for IO ports, and we should not even _try_ to do so for io_writeX().

HOWEVER. From a _bus_ standpoint, an IO port access is still very 
different from a memory-mapped IO access. In particular, we still have to 
guarantee that IO port accesses never get merged, and that they never get 
re-ordered. If the CPU needs to do those guarantees by hand, then they 
need to be there in the code. But I guess that those are really just the 
same guarantees as for a non-porefetchable MMIO region, so again this 
implies that the _software_ side should be the same for MMIO as for PIO.

And I don't know what "mf.a" means on ia64. Magic hardware.

I assume it's just a "total ordering", and no, I don't think we need it.  
As long as the page tables (or something else in the actual hardware)  
guarantees that reads and writes don't get re-ordered, I think we're fine.

If it's the old "ordering between CPU's" issue, then I think it's back to 
the CPU serialization side, and we should just say "if you use io_write(), 
you get the same CPU serialization for both IO ports and MMIO, and if you 
want inter-CPU ordering, you need to use a spinlock".

			Linus
