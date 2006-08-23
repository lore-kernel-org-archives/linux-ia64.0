From: Horms <horms@verge.net.au>
Date: Wed, 23 Aug 2006 02:38:43 +0000
Subject: Re: Increase default nodes shift to 10
Message-Id: <20060823023843.GA21369@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 22, 2006 at 12:31:07PM -0700, Christoph Lameter wrote:
> 
> On Tue, 22 Aug 2006, Luck, Tony wrote:
> 
> > > Could we set these limits consitently to the largest IA64 configuration to 
> > > make sure that a generic IA64 kernel is able to run on all machines?
> > 
> > We could ... but Horms has a good point that we might not
> > want to do this if the cost is high.  Can you estimate how
> > much memory will be allocated in these NR_CPUS and MAX_NUMNODES
> > sized arrays.  If it is only[1] a couple of hundred Kbytes, then
> > it might be worth it (even little IA-64 systems have 1GB, so
> > 100K is 0.01%).
> 
> Worst case is probably the slab allocator.
> 
> The kmem_cache struct has pointer arrays per node and per cpu. If a 
> corresponding cpu / node is not up then no further structures will be 
> allocated.
> 
> pointers to per cpu caches array cache = NR_CPUS * sizeof(void *) = 8k.
> 	up from 64* sizeof(void *) = 512 byte.
> 
> pointers to per node l3 array = MAX_NUMNODES * sizeof(void *) = 8k.
> 	again up from currently 2k.
> 
> So additional overhead per slab is around 13k.  About 40 slabs. That 
> results in ~520k additional overhead.

I will thrown an additional 2c worth in here and say that that really
doesn't seem to be that bad. And thus I think that increasing the
default to 10, as you suggested, is quite reasonable. In the unlikely
case where a smaller system really carse about this ammount of ram it
they could always reduce the value at configure time. Which seems
altogether more agreeable than having larger systems fail to boot.

Actually, given the ammount of memory that is involves, it does
beg the question of if it needs to be configurable at all.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

