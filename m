From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 14 Jun 2006 16:33:09 +0000
Subject: Re: light weight counters: race free through local_t?
Message-Id: <Pine.LNX.4.64.0606140928500.4030@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0606092212200.4875@schroedinger.engr.sgi.com>
 <449033B0.1020206@bull.net>
In-Reply-To: <449033B0.1020206@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: akpm@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 14 Jun 2006, Zoltan Menyhart wrote:

> > On IA64 we we would trade an interrupt disable/ load / add / store
> > /interrupt enable against one fetchadd instruction with this patch. How
> > bad/good a trade is that?
> 
> On one hand, switching to local counters can be a good idea if they are not
> evicted from the caches by the usual NRU/LRU cache replacement...
> 
> On the other hand, I do not think the ia64's fetchadd instruction is
> expensive.
> If your data is in L2, then it takes 11 clock cycles.
> 
> I do not think the counters have got much chance to stay in L1.
> Anyway, L1 is write through, you'll need to copy the updated value
> back into L2.
> As the shortest L2 access takes 5 clock cycles...
> You need 2 of them. (Assuming a counter is always in L2.)
> And add interrupt disable/enable time...

Could you do a clock cycle comparision of an 

atomic_inc(__get_per_cpu(var))
(the fallback of local_t on ia64)

vs.

local_irq_save(flags)
__get_per_cpu(var)++
local_irq_restore(flags)
(ZVC like implementation)

vs.

get_per_cpu(var)++
put_cpu()
(current light weight counters)
