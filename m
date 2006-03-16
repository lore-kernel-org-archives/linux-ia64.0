From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 16 Mar 2006 09:57:02 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <4419366E.5090707@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

> It is still not clear whether srlz.d is required or not, right?  Wording
> in SDM is vague.

We have quoted several times the SDM:

"The visibility of the itc instruction to generated purges (ptc.g, ptc.ga) must occur \
before subsequent memory operations. From a software perspective, this is similar to \
acquire semantics. Serialization is still required to observe the side-effects of the \
translation being present."

What do you think the statement "Serialization is still required..." means
if not a "srlz.d" (or "rfi") ?

> Through experiment, I've verified that itc instruction
> observe full instruction latency with respect to memory operation that
> immediately follows it.

Have you got a test to check it?
Could you please give us the test program?

Assuming you are right, do you think Intel guarantees that all the CPU
models (incl. the forthcoming ones) behave like that?

> It is pretty much in-line with what I think what
> the SDM is trying to say: it has implicit semi-serialization (next
> memory operation won't proceed until itc.d finishes).

Can you please indicate where it states that?

> Do you have any performance data showing that nta is a win?

I have already admitted that I cannot measure the difference.
(We do not hit very frequently these trap routines.)

Let us put the question in another way:

There is a sequence with "nta"-s.
This sequence is not longer than the one w/o "nta"-s.
According to the doc. it *may* run faster.
Why should not we use it?

Thanks,

Zoltan
