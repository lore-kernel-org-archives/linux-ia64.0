From: Andrew Morton <akpm@osdl.org>
Date: Sat, 18 Oct 2003 00:49:55 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106643841722114@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> wrote:
>
> >>>>> On Fri, 17 Oct 2003 16:55:43 -0700, Andrew Morton <akpm@osdl.org> said:
> 
>   >> If we really believe copy_*_user() must correctly handle *all* faults,
>   >> isn't the "p >= __pa(high_memory)" test superfluous?
> 
>   Andrew> This code was conceived before my time and I don't recall seeing much
>   Andrew> discussion, so this is all guesswork..
> 
>   Andrew> I'd say that the high_memory test _is_ superfluous and that
>   Andrew> if anyone cared, we would remove it and establish a
>   Andrew> temporary pte against the address if it was outside the
>   Andrew> direct-mapped area.  But nobody cares enough to have done
>   Andrew> anything about it.
> 
> What about memory-mapped device registers?  Isn't all memory
> physically contiguous on x86 and that's why the "p >> __pa(high_memory)" test saves you from that?

We _want_ to be able to read mmio ranges via /dev/mem, don't we?  I guess
it has never come up because everyone uses kmem.

>   >> On ia64, a read to non-existent physical memory causes the processor
>   >> to time out and take a machine check.  I'm not sure it's even possible
>   >> to recover from that.
> 
>   Andrew> ick.  That would be very poor form.
> 
> Reasonable people can disagree on that.

nah ;)

> One philosophy states that if
> your kernel touches random addresses, it's better to signal a visible
> error (machine-check) than to risk silent data corruption.

An access to an illegal address should generate a fault, period.  This puts
the processing into the hands of software.  If software chooses to silently
ignore the fault (ie: "silent data corruption") then it is poorly designed.

If the hardware doesn't give the system programmer a choice then the
hardware is poorly designed, surely?

