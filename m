From: Andrew Morton <akpm@osdl.org>
Date: Sat, 18 Oct 2003 02:01:04 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106644250424554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> wrote:
>
> >>>>> On Fri, 17 Oct 2003 17:49:55 -0700, Andrew Morton <akpm@osdl.org> said:
> 
>   Andrew> We _want_ to be able to read mmio ranges via /dev/mem, don't
>   Andrew> we?  I guess it has never come up because everyone uses
>   Andrew> kmem.
> 
> I just don't see how making a "dd if=/dev/mem" safe and allowing
> access to arbitrary physical memory can go to together.  Given that
> /dev/mem _is_ being used for accessing mmio space, is it really worth
> bothering trying to make such a "dd" safe?

Possibly not.  I thought that simply oopsing the kernel was a bit rude, and
fixing ia32 to not do that was relatively simple.

We should, within reason, handle it as gracefully as possible, yes?

>   Andrew> If the hardware doesn't give the system programmer a choice
>   Andrew> then the hardware is poorly designed, surely?
> 
> Emh, we're talking about _physical_ memory accesses here.  AFAIK,
> failures on physical memory accesses are never signaled with
> synchronous faults (not on any reasonably modern high performance
> architecture, at least).  Loads probably _could_ be signalled
> synchronously, but consider stores: would you really want to wait with
> retiring a store until it has made it all the way to some slow ISA
> device?  I think not (IN/OUT do that).  No, modern CPUs check the
> TLB/page-table and if that check passes, they'll _assume_ the memory
> access will complete without errors.  If it doesn't, they signal an
> asynchronous failure (e.g., via an MCA).

If the not-present memory is marked cacheable and/or writeback then yes,
but that would be an odd thing to do, wouldn't it?

It the memory is mapped noncacheable then a synchronous error on a read
sounds reasonable.  A synchronous error on a write would assume that the
noncacheability affects the write buffers and IIRC that usually doesn't
happen(?).

