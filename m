From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 12 Mar 2008 07:42:26 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <47D78962.1040106@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:

> Depends on what you mean by _independent_.  I have a lot of experience
> with _cascading_ MCAs, where there is a root cause failure quickly
> followed by other MCAs as a side effect of the initial failure all
> occuring as one MCA event.  In those cases capturing all the MCA
> information and sorting through to reconstruct the events is vital
> to find the root cause.  Whether the MCAs are due to one root cause
> or multiple causes is not clear until after the analysis.

Independent: there is no single root cause.

Let's say: the number of the buffers has to be adapted (e.g. at
the boot time) to the particularity of the platform, to the
probability of multiple events, to the mean length of cascading
MCAs.

I prefer to have a default number of buffers that allows:
- to run small / moderate sized boxes
- to "survive" the install process on large systems. You
   calculate the number of buffers during the install process.

... even if you stay with the actual code.

> Multiple CPUs going through MCA at the same time is not an abstract
> scenario.  It is not uncomon to have many processes accessing
> the same shared memory and hitting the same bad memory.  That is
> why I have test cases for those scenarios.

This is definitely not a case of independent events.
How much more information are there in the additional logs?

>>If the MCAs are the consequences of the same error event, then
>>you can find out what they are, where they are from 2 or 3 logs.
> 
> Easier said than done in real life.

You may be right => platform dependent number of buffers.

> In the case of two processes consuming the same bad data, it
> is often the second processes that calls up to OS_MCA first.
> The reason is in SAL, the first CPU into MCA tries to rendezvou
> the others.  The second one in (beating the rendezvou) sees
> the first is doing the rendezvou so he immediately call into
> linux OS_MCA.  So the second CPU shows up in OS_MCA before
> the first.  There is no guarantee that the first error
> in hardware wins the race to be the first in linux OS_MCA.

I can agree with your explanation.
Yet you said: the same bad data.
All of the logs will indicate the same bad memory.

> Another recent example of multiple CPUs going into MCA at
> the same time was a hot lock on a large system with enough
> contention to cause memory timeouts.  It was by looking at
> the MCA records that we were able to identify the hot lock
> and fix the code.

... platform dependent number of buffers.

Thanks,

Zoltan

