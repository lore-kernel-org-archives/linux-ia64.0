From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 17 Oct 2003 23:25:10 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106643319318503@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 17 October 2003 4:50 pm, Andrew Morton wrote:
> Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> >
> > Old behavior:
> > 
> >     # dd if=/dev/mem of=/dev/null
> >     <unrecoverable machine check>
> 
> I recently fixed this for ia32 by changing copy_to_user() to not oops if
> the source address generated a fault.  Similarly copy_from_user() returns
> an error if the destination generates a fault.
> 
> In other words: drivers/char/mem.c requires that the architecture's
> copy_*_user() functions correctly handle faults on either the source or
> dest of the copy.

If we really believe copy_*_user() must correctly handle *all* faults,
isn't the "p >= __pa(high_memory)" test superfluous?

I don't know how ia32 handles a read to non-existent physical memory.
Are you saying that copy_*_user() can deal with that just like it does
a garden-variety TLB fault?

On ia64, a read to non-existent physical memory causes the processor
to time out and take a machine check.  I'm not sure it's even possible
to recover from that.

Bjorn

