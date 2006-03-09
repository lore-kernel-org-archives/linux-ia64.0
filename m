From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 09 Mar 2006 18:09:52 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <44106F70.1000901@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> [...]
> 
> Hmm.... maybe I am missing something. What do you mean by "global"? I do 
> not have too much experience here. Just looking at the Intel manual. It 
> seems that global refers to ptc broadcasting purges to all processors.

The term "globally performed" does not always mean that some info goes
out of a CPU.
A store is globally performed (in cached mode) when the new data is in the
(local) L2 and its status is set accordingly. I.e. any external demand will
find the freshly stored value and the correct cache status response.
If the cache line is in "E" state, then a transition to "M" will not be seen
from external agents, unless they explicitly ask for the data.

I consider an "itc" as globally performed if any external demand (purge)
will not miss our new translation and the HW responds accordingly (see TND#).

If the term "globally performed" is not well chosen, I can use this
longer phrase from the Intel book:
"visibility of the itc instruction to generated purges" is guaranteed.

>>1. "itc.d r25" is issued.
>>   It is not globally performed (an external purge request would miss it).
> 
> Right this only affects this processor. itc.d never has a global effect as 
> far as I can see.

Let's say: the visibility of "itc" to generated purges is not guaranteed
at this point.

>>2. "ld8 r18=[r17]" is executed - we read back the good value.
>>   (Even an L3 cache miss can be quickly prepared on multi core / threaded
>>   processors by a cache intervention.)
> 
> 
> Thats fine.

The problem is here: the algorithm requires that our new translation be
able to catch the external purge request *before* we issue "ld".

As far as I can see, the ";;" dos not delays this "ld" to guarantee that
the TLB entries involved all correctly updated (L1D invalidated, etc.).

>>3. Someone tears down the same PTE: s/he clears it, then
>>4. s/he issues a global purge - we miss it, because our "itc.d r25" still
>>   has not been globally performed.
> 
> 
> itc.d is not globally performed at all. We could theorize that we may miss 
> the purge because this processor may perform the itc.d immediately after 
> getting the purge broadcast from another processor.

Let's say: the visibility of "itc" to generated purges is still
not guaranteed at this point.

> There is this cryptic sentence on page 3:127
> 
> "The visibility of the itc instruction to generated purges (ptc.g, ptc.ga) 
> must occur before subsequent memory operations. From a software 
> perspective, this is similar to acquire semantics. Serialization is still 
> required to observe the side-effects of the translation being present."
> 
> What does this exactly mean? Guess we need some more details on how these 
> purge broadcasts work.

As far as I can see, we have to avoid to feed the memory / cache queues and
the TLB look up unit with new demands until the visibility of the itc
instruction to generated purges can be guaranteed.
In our case, "srlz.d" stalls the exec. pipeline.
This is why a ";;" is not enough.

>>5. Finally "itc.d r25" is globally performed (e.g. it is in our DTLB1).
> 
> 
> The global is throwing me off again here.

I mean the visibility of the itc instruction to generated purges is O.K.

>>6. "cmp" compares a stale value in r18 and our freshly inserted translation
>>   has missed the purge.
> 
> 
> Maybe.

In short: unless we use "srlz.d", how to make sure:
- the visibility of the "itc" instruction to generated purges is
  guaranteed first
- issuing "ld" goes after ?

Thanks,

Zoltan


