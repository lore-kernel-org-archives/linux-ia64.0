From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 16 Mar 2005 10:58:17 +0000
Subject: Re: flush_icache_range
Message-Id: <42381149.9010006@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>   Zoltan> Apparently, the function flush_icache_range() flushes the
>   Zoltan> caches 32 by 32 bytes.
>   Zoltan> According to some measures on a Tiger box, an "fc" instruction
>   Zoltan> costs 200 nanosec. if no other CPU has the line its cache,
>   Zoltan> there is no traffic on the bus, everything is ideal.
>   Zoltan> If all the others CPUs have the line in their caches, they post
>   Zoltan> bus transactions, then the cost of an "fc" instruction is 5
>   Zoltan> microsec.
>   Zoltan> To flush a full page of 64 Kbytes, it can take 400 microsec. to
>   Zoltan> 10 millisec.
> 
>   Zoltan> Cannot we test at the boot time the characteristics of the
>   Zoltan> CPUs and select the optimal flush_icache_range() ? E.g.:
>   Zoltan> - if the CPU has 64 bytes / L1 lines =>
>   Zoltan> flush by use of 64 byte steps
>   Zoltan> - if the CPU implements the "fc.i" instruction =>
>   Zoltan> flush the I-caches only
> 
> Does it actually make any difference?  The expensive part of "fc" is
> when it's causing write-backs and you end up being memory-bandwidth
> limited.  With a 64-byte stride, the CPU would do less work, but you'd
> still be bottlenecked by the write-back speed.

I ran flush_icache_range() for 1000 times for the same page
(i.e. the "fc" has really nothing to do).
The other CPUs were idle. No traffic on the bus.
I simply took the ITC value before and after...
Here are the values (average for the 1000 runs):

With a 64-byte stride:	110143 nsec 187218 cycles
With a 32-byte stride:	225606 nsec 383477 cycles

processor  : 7
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 2
revision   : 1
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 1699.762994
itc MHz    : 1699.762994
BogoMIPS   : 2541.74

I think the CPU sends out the snoop requests anyway.
I guess it can send out a second snoop request before the first
one is acknowledged, this is why it is somewhat quicker than the 400
microsec., as I wrote before.
I think saving more than 100 microsec. / page and reducing the bus
traffic can be interesting.

Thanks,

Zoltan


