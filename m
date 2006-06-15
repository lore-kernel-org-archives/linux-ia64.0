From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 15 Jun 2006 16:46:29 +0000
Subject: Re: light weight counters: race free through local_t?
Message-Id: <44918EE5.2060302@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0606092212200.4875@schroedinger.engr.sgi.com> <449033B0.1020206@bull.net> <Pine.LNX.4.64.0606140928500.4030@schroedinger.engr.sgi.com> <44915110.2050100@bull.net> <Pine.LNX.4.64.0606150855410.9137@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606150855410.9137@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:

> Good to know. But we would run into trouble if the atomic counters would 
> be contended.

Why do you think an atomic operation is more expensive in a contended case?

Let's take the following assumption:
Every time when a CPU wants to increment the counter, it's cache line is
in someone other's cache.

Case of an atomic operation:

1. Issuing an atomic operation (apparently can be absorbed)
2. Goes down by the OzQ of the L2 (no L1 action)
   (assuming the queue is "sufficiently empty")
3. L2 miss
4. Fetching data, obtaining exclusivity - very long
5. L2 is ready - do the atomic operation to the L2 entry - modified state
   (min 5 clock cycles for normal L2 access + 5 for the atomic operation)

Case of __get_per_cpu(var)++:

1. Issuing an "ld4" can be absorbed
2. Goes down by the OzQ of the L2 (L1 miss)
   (assuming the queue is "sufficiently empty")
3. L2 miss
4. Fetching data, shared state - very long
5. L2 is ready - copy to L1 - into rx
   (min 5 clock cycle due to the L2)
6. Increment (1 cycle)
7. Post store to the OzQ of the L2 (L1 updated)
   (assuming the queue is "sufficiently empty")
8. L2 hit - obtain exclusivity - moderately long
9. L2 is ready - update it - modified state
   (min 5 clock cycles)

Please note
- the additional bus operation (address only) in step 8
- a 3rd CPU can kill our data between steps 5 - 8
  (very low probability)

(In case of strong contention, efforts have to be made to avoid cache
line sharing with other frequently used data - as usually...)

> Hmm... What about side effects such as pipeline stalls? fetchadd is 
> semaphore operation. Typically we use acquire semantics for volatiles. 
> Here the fetchadd has release semantics.

> If we would use release semantics then the fetchadd would require all 
> prior accesses to be complete.

... or ".rel".
Yes, it is a one-direction barrier.
However, if there is not too many stuff in the OzQ, it has not too much
impact.
(It is very difficult to fill in the OzQ: SW pipe-line, N independent
loads / stores without ";;" - not very much frequent in the kernel)

> Acquire semantics may be easier. But the best would be a fetchadd without 
> any serialization that would be like the inc/dec memory on i386, which 
> does not exist in the IA64 instruction set.

A second though about the case of __get_per_cpu(var)++:

If it is coded by hand, I can use "ld4.bias" to obtain immediately
the exclusivity - no need for step 8.
However, you cannot avoid the cost of the protection around this
incitement.

I still prefer the atomic operations.

Regard,

Zoltan


