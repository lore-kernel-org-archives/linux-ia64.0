From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 26 Oct 2004 16:23:24 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <200410260923.24663.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, October 26, 2004 12:48 am, David Mosberger wrote:
>   Bjorn> I heard a rumor that ioreadX() on PIO cookies is supposed to
>   Bjorn> have looser semantics than inX() on the port, so we might be
>   Bjorn> able to get away without the memory fence in inb().  But I
>   Bjorn> can't substantiate that, so this keeps the generic behavior
>   Bjorn> of ioreadX() and inX() having identical semantics for PIO.
>
> Can somebody confirm?  Dropping the mf.a from ioreadX() for I/O port
> accesses would save lots of cycles.  Though I guess most
> high-performance devices are smart enough to stay away from I/O port
> space nowadays, so perhaps it doesn't matter in reality.

I'm pretty sure this is the case.  In fact when I last discussed this with 
Linus he indicated that an ioread shouldn't guarantee DMA completion either, 
which would mean we could reuse the read_relaxed stuff to implement it.

Jesse
