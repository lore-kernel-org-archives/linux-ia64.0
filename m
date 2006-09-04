From: Horms <horms@verge.net.au>
Date: Mon, 04 Sep 2006 07:56:50 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <20060904075648.GA20330@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 04, 2006 at 03:43:35AM -0400, Jes Sorensen wrote:
> >>>>> "Horms" = Horms  <horms@verge.net.au> writes:
> 
> Horms> Hi, I'm trying to build a non-NUMA (HP_SIM) config, and I am
> Horms> running into trouble because there are serveral places where
> Horms> NODE_DATA is used. It seems to me that this makes little sense
> Horms> as NODE_DATA needs the node_data element of struct
> Horms> cpuinfo_ia64, which doesn't exist without CONFIG_NUMA.
> 
> Horms> Is CONFIG_NUMA mandatory or is this just an oversight?
> 
> I haven't looked at the details, given you don't say where it breaks,
> but it would make sense to me that a non-NUMA system is treated as a
> single node system, eg. NODE_DATA(0) ought to be valid.

I think it might actually be a config issue. Further experimentation
has found that arch/ia64/configs/sim_defconfig does compile.

For the record, I'm using Tony Luck's test tree, updated earlier today
to changest c8228f2cc1f1231620d09fd07f3d2324bfdebdcc with the config
I posted a little earlier. The first breakage I see is:

  CC      arch/ia64/kernel/asm-offsets.s
In file included from include/linux/slab.h:14,
                 from include/linux/percpu.h:4,
                 from include/linux/rcupdate.h:41,
                 from include/linux/pid.h:4,
                 from include/linux/sched.h:70,
                 from arch/ia64/kernel/asm-offsets.c:9:
include/linux/gfp.h: In function `alloc_pages_node':
include/linux/gfp.h:119: warning: implicit declaration of function
`NODE_DATA'
include/linux/gfp.h:119: error: invalid type argument of `->'

Which I believe is because nodedata.h is not included, as per
~line 83 of include/asm/processor.h

#ifdef CONFIG_NUMA
#include <asm/nodedata.h>
#endif

Including nodedata.h doesn't seem appropriate, as it does seem to
be numa-specific. I wasn't able to find an alternate definition of
CONFIG_NUMA

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/


-- 
VGER BF report: U 0.580115
