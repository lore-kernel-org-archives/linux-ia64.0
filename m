From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 20 Oct 2003 15:17:10 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106666338406789@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 17 October 2003 6:21 pm, David Mosberger wrote:
> What about memory-mapped device registers?  Isn't all memory
> physically contiguous on x86 and that's why the "p >> __pa(high_memory)" test saves you from that?

As others have mentioned, using read/write on /dev/mem to get at
memory-mapped registers is unlikely to work on ia64 anyway, because
read/write use cacheable mappings.  Using mmap does work (using
uncacheable mappings), and my patch doesn't change that path.

>   >> On ia64, a read to non-existent physical memory causes the processor
>   >> to time out and take a machine check.  I'm not sure it's even possible
>   >> to recover from that.
> 
>   Andrew> ick.  That would be very poor form.
> 
> Reasonable people can disagree on that.  One philosophy states that if
> your kernel touches random addresses, it's better to signal a visible
> error (machine-check) than to risk silent data corruption.

It occurred to me over the weekend that part of this confusion is
related to the fact that ia64 doesn't have page tables for the
kernel identity-mapped segments.  (We're talking about reading
physical memory, but read/write_mem() actually convert the address
using __va() before doing the copy.)

I bet that ia32 does have page tables for this case, and that
an attempt to read non-existent physical memory will cause a TLB
miss from which copy_*_user() can easily recover.

On ia64, the same TLB miss would occur, but since there are no page
tables, the miss handler assumes the kernel knows what it is doing
and happily synthesizes a mapping that points nowhere.

Bjorn

