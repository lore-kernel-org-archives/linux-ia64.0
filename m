From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 08 Mar 2002 10:26:33 +0000
Subject: Re: [Linux-ia64] VHPT performance
Message-Id: <marc-linux-ia64-105590701905240@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


David Mosberger schrieb:

> >>>>> On Fri, 08 Mar 2002 08:50:15 +0100, Christian Hildner <christian.hildner@hob.de> said:
>
>   Christian> Could you please try with my test program to verify what
>   Christian> I found (compile with -O). The pointer increment is half
>   Christian> the page size, so TLB hit and TLB miss are changing.
>
> I think it's your program: I suspect you're measuring cache misses
> more than anything else.  Try touching a set of pages repeatedly and
> try to touch different words, such that there are no cache misses.
>
>         --david

Ok that's true. I changed my program so that before the measuring loop there comes the same loop
for filling the cache. Also I had to increase the memory size to a minimum of 128 pages because
for itanium there are 32 entries for L1-DTLB and 96 entries for L2-DTLB. Now I get values of 42
cycles with VHPT enabled and 180 cycles with VHPT disabled. This values are coming near to the
ones you found.

Christian


