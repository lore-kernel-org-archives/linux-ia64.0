From: Duraid Madina <duraid@octopus.com.au>
Date: Mon, 12 Jul 2004 21:49:35 +0000
Subject: Re: Consistency problem on IPF
Message-Id: <40F3076F.7040507@octopus.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F2562C.10208@inria.fr>
In-Reply-To: <40F2562C.10208@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Erich Focht wrote:
> On Monday 12 July 2004 13:12, Duraid Madina wrote:
> 
>>For the record, on HP-UX 11.23 the standard deviation is down around 
>>0.1s for NP0, 512. For N24, it's basically zero. This is on a 2-way 
>>1.5G/6M system.
> 
> 
> Which page-size was the testcode using?

Doesn't matter too much, but clamping the page size to 4K (the smallest 
possible) increases the standard deviation to ~0.5sec (for a +O0 
program, see below). 8K improves that somewhat and beyond 8K, the values 
are basically what I reported before. There's no need for truly large 
pages on this small example..

> HPUX is more flexible here due
> to different usage of the TLB.

Ain't that the truth! I *wish* Linux could do the same thing - problems 
like Marc's would disappear (not to mention that performance for many 
big numerical codes out there would increase significantly). But no, 
thanks to Oracle, we are forced to deal with junk like hugetlbfs..

> What compiler?

HP aC++/ANSI C B3910B A.05.56 [June 09 2004] [aCC6_beta]

> The initial mail sounded like gcc has been used. I'd
> expect a reasonable (i.e. optimizing) compiler to recognize the
> trivial matrix-matrix multiply pattern and replace it by highly
> optimized code. Which would reduce the problems...

The deviation seemed to stay the same when using +O0 (which slowed the 
program by more than a factor of 10, so I'm pretty sure it's not using 
highly optimized code now.)

>>Linux has a way to go yet...
> 
> 
> Might be, but one should check whether comparing apples with apples
> ;-)

I thought the G5 was the fastest computer on earth? ;)

	Duraid
