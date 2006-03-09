From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 09 Mar 2006 16:23:51 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <Pine.LNX.4.64.0603090756150.15975@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 9 Mar 2006, Zoltan Menyhart wrote:

> I think is not safe enough.
> The ";;" orders dependencies like R-A-W only, not the relatively slow cache
> & tlb coherency operations, like "itc".
> This is why I think we need my (first) patch.

Hmm.... maybe I am missing something. What do you mean by "global"? I do 
not have too much experience here. Just looking at the Intel manual. It 
seems that global refers to ptc broadcasting purges to all processors.
 
> I can imagine the following scenario:
> 
> 1. "itc.d r25" is issued.
>    It is not globally performed (an external purge request would miss it).

Right this only affects this processor. itc.d never has a global effect as 
far as I can see.
 
> 2. "ld8 r18=[r17]" is executed - we read back the good value.
>    (Even an L3 cache miss can be quickly prepared on multi core / threaded
>    processors by a cache intervention.)

Thats fine.
 
> 3. Someone tears down the same PTE: s/he clears it, then
> 4. s/he issues a global purge - we miss it, because our "itc.d r25" still
>    has not been globally performed.

itc.d is not globally performed at all. We could theorize that we may miss 
the purge because this processor may perform the itc.d immediately after 
getting the purge broadcast from another processor.

There is this cryptic sentence on page 3:127

"The visibility of the itc instruction to generated purges (ptc.g, ptc.ga) 
must occur before subsequent memory operations. From a software 
perspective, this is similar to acquire semantics. Serialization is still 
required to observe the side-effects of the translation being present."

What does this exactly mean? Guess we need some more details on how these 
purge broadcasts work.
 
> 5. Finally "itc.d r25" is globally performed (e.g. it is in our DTLB1).

The global is throwing me off again here.

> 6. "cmp" compares a stale value in r18 and our freshly inserted translation
>    has missed the purge.

Maybe.
 
> BTW cannot take we this good opportunity to make the code somewhat more
> readable?
> (See my second patch.)

The coding style used throughout seems to not use tabs. Your patch would 
make this piece of code deviate in style. If you want to do this then we 
would need to have agreement on the coding style change and then all asm 
code would have to be changed.

