From: Marc Gonzalez-Sigler <marc.gonzalez-sigler@inria.fr>
Date: Mon, 12 Jul 2004 12:01:15 +0000
Subject: Re: Consistency problem on IPF
Message-Id: <40F27D8B.6010202@inria.fr>
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
>> For the record, on HP-UX 11.23 the standard deviation is down around
>> 0.1s for NP0, 512. For N24, it's basically zero. This is on a 2-way
>> 1.5G/6M system.
> 
> Which page-size was the testcode using? HPUX is more flexible here due
> to different usage of the TLB.
> 
> What compiler? The initial mail sounded like gcc has been used. I'd
> expect a reasonable (i.e. optimizing) compiler to recognize the
> trivial matrix-matrix multiply pattern and replace it by highly
> optimized code. Which would reduce the problems...

(For the record, I tried gcc-3.3.4 and orcc-2.1)

Perhaps I was not clear enough. I used matrix-matrix multiply only as an 
example. My real problem is the non-deterministic behavior.

Say I tile the main loop nest. I want to compare the execution time of 
the original, untiled program and the execution time of the modified, 
tiled program.

If the original version completes in 1 second 80% of the time, and the 
modified version completes in 0.5 seconds 80% of the time, but 2 seconds 
20% of the time, then, if I am unlucky, I might eliminate an excellent 
candidate. This is why I need the execution times of a given program to 
be consistent.

I have looked at /usr/src/linux/Documentation/vm/hugetlbpage.txt and I 
will try it if there are no better solutions.

-- 
Regards, Marc

